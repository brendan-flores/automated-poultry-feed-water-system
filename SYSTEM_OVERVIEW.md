# Automated Poultry Feed and Water Management System with Mobile Application Monitoring

**Working app name:** CoopControl
**Program:** BS Computer Engineering, 4th Year – H1
**Team:** Cañas, Harlie Khurt T. · Ebesa, Chucky Korbin D. · Flores, Brendan Emmanuel T.
**Adviser:** Engr. Mervin John C. Tampus

> **Status note.** This is a design overview, not a finished thesis manuscript or approved schematic.
> Hardware specifications are seller claims unless marked as tested. Only report what has been
> designed, built, and verified. Document measured results, not seller specifications.

---

## 1. What the system does

An ESP32-based IoT system that automates two routine poultry tasks and lets the farmer oversee them from a phone:

1. **Feeding:** dispenses a configured **weight** of feed at scheduled times using an auger, and stops when the load cells measure the target weight.
2. **Watering:** keeps a drinking trough filled from a reservoir using a pump and float switches.
3. **Monitoring:** tracks hopper feed level, feed weight, and water conditions, and reports them to a mobile app.
4. **Remote control:** the farmer configures schedules and target weights, triggers permitted manual actions, and receives alerts.

**Core principle:** essential safety logic runs **locally on the ESP32**. The mobile app and cloud only send *requests* and display status. They are never the only safety mechanism.

## 2. Problem addressed

Manual poultry management needs frequent physical presence to check feed and water. Basic automatic feeders often work offline with no remote feedback, no hopper inventory sensing (so empty hoppers go unnoticed and the motor runs needlessly), and no alerts. This project integrates weight-based dispensing, hopper-level sensing, automated water replenishment, and a mobile app in one system.

## 3. System at a glance

```
  Sensors ──────────┐
  (load cells/HX711,│        ┌───────────────┐   HTTPS    ┌──────────────────┐   Realtime   ┌───────────────┐
   HC-SR04, floats, ├──────► │     ESP32     │ ◄────────► │     Supabase     │ ◄──────────► │  Flutter app  │
   DS3231 RTC)      │        │ (local safety │            │ Postgres + Auth  │              │  (CoopControl)│
                    │        │  + control)   │            │ + RLS + Realtime │              └───────────────┘
  Actuators ◄───────┘        └───────────────┘            └──────────────────┘
  (auger motor, water pump via MOSFET drivers)
```

## 4. Hardware summary

| Function | Component |
|---|---|
| Controller | ESP32-WROOM-32 (38-pin dev board, 3.3 V logic) |
| Timekeeping | DS3231 RTC (I²C) |
| Feed weighing | 4 × 5 kg load cells, HX711 amplifier(s) |
| Hopper level | HC-SR04 ultrasonic sensor (5 V ECHO needs a voltage divider before the ESP32) |
| Water level | 2 float switches (reservoir and trough) |
| Feed actuator | SGM37-3530 12 V DC gear motor driving an auger |
| Water actuator | R385 12 V DC pump |
| Drivers | 2 × HW-548 MOSFET driver modules (topology still to be verified) |
| Power | 12 V 5 A supply (S-60-12), buck converter for the 5 V logic rail, KCD4 switch, blade fuses |

Open hardware items include the HW-548 topology and grounding, flyback protection, buck output voltage, four-load-cell bridge wiring, and fuse ratings. See the verification checklist in the master reference.

## 5. Feed subsystem

**Sequence**

1. RTC provides current time; ESP32 checks whether a schedule is due.
2. Hopper level is checked (HC-SR04).
3. Current platform weight is read (load cells).
4. If allowed, the auger motor starts.
5. Weight is monitored continuously; the motor stops at the target weight.
6. Final reading is checked and status is reported.

**Safety logic**

| Condition | Response |
|---|---|
| Schedule not due | Motor OFF |
| Hopper empty | Motor must not run; alert user |
| Ultrasonic reading invalid | Do not assume feed is present; lock out |
| Load-cell reading invalid | Stop weight-based dispensing |
| Target weight reached | Stop motor |
| Max motor runtime exceeded | Stop motor, report fault |
| ESP32 restarts mid-feed | Do not blindly resume |
| Restart after a completed feeding | Do not repeat the same scheduled feeding |

Maximum runtime is a *secondary* protection, not a substitute for weight measurement.

## 6. Water subsystem

| Reservoir | Trough | Response |
|---|---|---|
| Sufficient | Sufficient | Pump OFF |
| Sufficient | Low | Pump ON (subject to all checks) |
| Low | Low | Pump OFF; alert |
| Low | Sufficient | Pump OFF; alert as appropriate |
| Invalid sensor reading | Any | Safe response; do not run the pump blindly |

The pump never runs dry, has a maximum runtime, and stops immediately if the reservoir goes low.

## 7. Backend: Supabase only

Supabase is the only cloud service (no Firebase, no FCM).

**Planned tables:** `devices`, `device_state`, `schedules`, `commands`, `alerts`, optional `telemetry_log`.

**Data flow**

| Direction | What | How (proposed) |
|---|---|---|
| ESP32 → cloud | Latest state and heartbeat (`last_seen`) | REST upsert every ~10–30 s |
| ESP32 → cloud | Alerts | REST insert on events |
| Cloud → ESP32 | Pending commands | ESP32 polls every ~3–5 s, validates, executes, writes back status and reason |
| Cloud → ESP32 | Schedules | Fetched on boot and when changed; cached in flash so feeding continues offline |
| Cloud → app | Live state and alerts | Supabase Realtime subscriptions |
| App → cloud | Schedules and command requests | Authenticated writes protected by Row Level Security |

**Command lifecycle:** `pending` → `accepted` or `rejected` → `done` or `failed` (with a human-readable reason such as "Hopper empty").

**Offline detection:** the device is shown as offline if `last_seen` is older than roughly 60–90 s. A scheduled database job (`pg_cron`, availability to be confirmed) can also raise a "Device offline" alert.

**Security**

- Row Level Security on every table; users see only their own device.
- The ESP32 signs in as a dedicated device user with policies limited to its own rows. The `service_role` key is never placed on the device.
- Auth tokens are refreshed by the firmware before expiry.

**Free-tier note:** free Supabase projects pause after about a week of inactivity. Check the project is active before demos and the defense.

## 8. Mobile application

Flutter, three screens, intentionally minimal (plus a basic sign-in screen for authentication).

| Screen | Purpose |
|---|---|
| **Home / Status** | Feed weight, hopper status (Full/Low/Empty), reservoir and trough status (OK/Low), system state, connection status with last-updated time, **Feed Now** and **Refill Water** buttons (disabled with a short reason when not allowed) |
| **Feeding Schedule** | List of feeding times with target weights; add, edit, delete, on/off toggle |
| **Alerts** | Recent alerts with unread badge: hopper low/empty, reservoir low, feeding failed or timed out, pump runtime exceeded, sensor malfunction, device offline |

**Design rules**

- Status words and colors (green/amber/red) instead of raw numbers where possible.
- Manual controls only *request* actions; the ESP32 decides.
- Offline data is clearly labeled as last known.
- Invalid sensor readings display as "Sensor error", never as a fake "OK".

**Deliberately excluded:** calibration, raw sensor values, charts and history, multi-device or multi-user management, editable safety limits, complex settings.

**Notification behavior (Supabase-only limitation):** Supabase has no push service, so alerts arrive as in-app banners and local notifications while the app is open or running in the background (most reliable on Android). When the app is fully closed, missed alerts are loaded on next open. This limitation should be stated in the thesis.

## 9. Firmware (ESP32, PlatformIO, Arduino framework)

Suggested modules: RTC and schedule management · HX711/load-cell reading · hopper ultrasonic measurement · reservoir and trough float switches · feed motor control · water pump control · safety and fault management · Wi-Fi and Supabase communication · status and event reporting.

Requirements: non-blocking operation; validated readings; defined thresholds; no indefinite actuator operation; actuators stop when required sensor data is invalid; no duplicate feeding after restart; Wi-Fi loss must never compromise local safety.

## 10. Development stages

1. **Electrical Design and Preparation**
2. **Individual Component Testing**
3. **DC Power and Electrical Integration**
4. **Modular Control-Box Assembly**
5. **Software Integration and Complete System Validation**
6. **Mechanical Integration and Final Calibration**

Mechanical requirements must influence Stages 1–3, not wait for Stage 6.

## 11. Scope

**Covered:** time- and weight-based automated feeding, auger conveyance, load-cell weighing, hopper level monitoring, automated water replenishment, mobile monitoring/configuration/notifications/manual control, ESP32 control, wireless communication, prototype testing.

**Not covered:** temperature/humidity/ventilation control, disease diagnosis, medication dispensing, egg collection or grading, computer-vision counting, individual bird identification, per-bird feed adjustment, full-scale commercial deployment, mains installation by beginners (a qualified person handles AC wiring).

## 12. Evaluation plan (summary)

- **Feed:** schedule accuracy, weight accuracy, dispensing consistency, load-cell repeatability, hopper detection, motor lockout when feed is insufficient.
- **Water:** float-switch response, pump on/off behavior, fill response, level detection, cycle repeatability.
- **App and connectivity:** connection stability, telemetry sync, latency, notification delivery, schedule and target-weight configuration, manual commands.
- **Integrated:** overall stability, sensor-actuator response, cycle reliability, concurrent operation, recovery from temporary Wi-Fi loss, power-interruption recovery.

Log timestamps from the start so latency and reliability results are real measurements.
