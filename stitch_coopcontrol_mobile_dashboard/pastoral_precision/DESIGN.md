---
name: Pastoral Precision
colors:
  surface: '#f9faf7'
  surface-dim: '#d9dad7'
  surface-bright: '#f9faf7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f1'
  surface-container: '#edeeeb'
  surface-container-high: '#e7e8e6'
  surface-container-highest: '#e2e3e0'
  on-surface: '#191c1b'
  on-surface-variant: '#40493d'
  inverse-surface: '#2e312f'
  inverse-on-surface: '#f0f1ee'
  outline: '#707a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#1b6d24'
  primary: '#0d631b'
  on-primary: '#ffffff'
  primary-container: '#2e7d32'
  on-primary-container: '#cbffc2'
  inverse-primary: '#88d982'
  secondary: '#005faf'
  on-secondary: '#ffffff'
  secondary-container: '#54a0fe'
  on-secondary-container: '#003567'
  tertiary: '#774c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#986200'
  on-tertiary-container: '#ffeede'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f69c'
  primary-fixed-dim: '#88d982'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005312'
  secondary-fixed: '#d4e3ff'
  secondary-fixed-dim: '#a5c8ff'
  on-secondary-fixed: '#001c3a'
  on-secondary-fixed-variant: '#004786'
  tertiary-fixed: '#ffddb5'
  tertiary-fixed-dim: '#ffb957'
  on-tertiary-fixed: '#2a1800'
  on-tertiary-fixed-variant: '#643f00'
  background: '#f9faf7'
  on-background: '#191c1b'
  surface-variant: '#e2e3e0'
typography:
  headline-metric-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.03em
  headline-metric-lg-mobile:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  margin: 1rem
  margin-tablet: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style
The design system establishes a balance between pragmatic agricultural utility and refined modern digital instrumentation. Built for small-scale poultry stewards operating in harsh, dynamic outdoor environments, the interface evokes calm confidence, high visibility, and tactile reassurance.

The visual style blends **Modern Minimalism** with **Subtle Tactility**. Generous whitespace prevents visual clutter under bright sunlight or rapid glance conditions. Large physical metaphors—such as tank capacities, hopper weights, and ambient environmental metrics—are rendered through clean geometry, immediate semantic color indicators, and substantial touch zones. The aesthetic rejects decorative gradients and ornate glass effects, favoring crisp surfaces, grounded agricultural tones, and unequivocal clarity.

## Colors
The color palette prioritizes sunlight legibility, distinct semantic grouping, and low cognitive load:

- **Primary (Feed / Vitality):** `#2E7D32` (Farm Green) anchors primary controls, active operational states, and healthy feed levels. Deep shade `#1B5E20` provides high-contrast text and pressed states, paired with `#E8F5E9` for structural fills and positive metric containers.
- **Secondary (Water / Hydration):** `#1976D2` (Water Blue) distinguishes water infrastructure, hydration telemetry, and flow toggles, supported by `#E3F2FD` for sub-panels and tracking bars.
- **Tertiary / Warning:** `#F9A825` (Amber) signals low reserves, connectivity delays, and battery warnings, backed by `#FFF8E1`.
- **Critical / Hazard:** `#D32F2F` (Alert Red) indicates empty troughs, pump blockages, or urgent sensor cutoffs, nested in `#FFEBEE`.
- **Surfaces & Borders:** `#F6F7F4` (Muted Agricultural Neutral) serves as the canvas, preventing glare compared to pure white. Elevated cards use `#FFFFFF`, bounded by `#E2E4DE` for definition.
- **Typography:** `#1F2937` (Charcoal) guarantees an accessible contrast ratio exceeding 7:1 against neutral backgrounds; `#6B7280` provides supporting context for secondary captions.

## Typography
`Inter` drives the entire typographic hierarchy, chosen for its tall x-height, open apertures, and exceptional tabular numeric figures. This ensures metric values (percentages, liters, kilograms, and timestamps) remain scannable even at an arm’s length under bright daylight.

- **Status & Metric Displays:** The `headline-metric` roles use tighter negative letter spacing and heavyweight numeric rendering to anchor IoT gauge cards.
- **Hierarchy Enforcement:** Section titles use `headline-md` and `headline-sm`. Metadata, telemetry units, and operational thresholds use uppercase labels (`label-caps`) with deliberate tracking to distinguish field labels from sensor readings.
- **Tabular Figures:** All numeric readouts must enable `font-feature-settings: "tnum"` to prevent layout shifts as live telemetry streams update.

## Layout & Spacing
The layout follows a mobile-first, single-column fluid container system expanding into modular grid cards on larger screens.

- **Mobile Canvas:** Screen margins are set to `margin` (`16px`) with vertical stack spacing governed by `space-lg` (`24px`).
- **Touch Targets:** Any interactive node (steppers, manual flush toggles, schedule selectors, bottom tabs) enforces a mandatory minimum boundary of 48×48px.
- **Tablet / Large Formats (640px+):** Layout splits into a 2-column dashboard layout (Feed silo vs. Water reservoir) with `gutter-tablet` (`24px`) and `margin-tablet` (`32px`), preserving card-based telemetry units without horizontal stretching.
- **Bottom Clearance:** A persistent safe area padding (`space-xl` + 64px) ensures bottom tab navigation never overlaps dashboard data cards.

## Elevation & Depth
Elevation emphasizes daylight surface separation without relying on deep or muddy drop shadows.

- **Base Layer:** The outdoor neutral ground (`#F6F7F4`) sits at elevation 0.
- **Surfaces & Cards:** Metric cards and control modules rest at Elevation 1, relying on a solid 1px border (`#E2E4DE`) combined with a diffused, warm ambient shadow: `0px 2px 8px rgba(31, 41, 55, 0.04), 0px 1px 2px rgba(31, 41, 55, 0.06)`.
- **Interactive Modals & Overlays:** Drawer menus, dispensing confirmation sheets, and emergency action sheets sit at Elevation 2 with `0px 8px 24px rgba(31, 41, 55, 0.12)`, masked by a tinted neutral scrim (`#1F2937` at 40% opacity).
- **Physical Controls:** Toggle pills and segment switchers utilize an inset stroke paired with a 1px downward tactile shadow to signify pressable affordance.

## Shapes
A roundedness level of `2` provides an approachable, ergonomic feel while preserving structural card boundaries:

- **Cards & Data Modules:** Standardize on `rounded-lg` (`16px` to `20px` radius) to convey smooth, contained physical units.
- **Interactive Buttons & Badges:** Primary and secondary actions utilize `rounded-md` (`8px`) or full pill radii (`9999px`) for quick tactile distinction.
- **Input Fields & Toggles:** Base fields use `rounded-md` (`8px`) to ensure distinct interior click targets.

## Components

### 1. Primary & Secondary Buttons
- **Height & Target:** Minimum 48px height, full-width on mobile.
- **Primary:** Background `#2E7D32`, text `#FFFFFF`, label weight `600`. Active state darkens to `#1B5E20`.
- **Water Action:** Background `#1976D2`, text `#FFFFFF`. Used strictly for manual refilling or valve cycling.
- **Critical Action:** Background `#D32F2F`, text `#FFFFFF`. Reserved for override shutdowns and feed stops.
- **Secondary / Ghost:** 1px border `#E2E4DE`, surface `#FFFFFF`, text `#1F2937`.

### 2. Telemetry Gauge Cards
- **Structure:** Surface `#FFFFFF`, border 1px solid `#E2E4DE`, corner radius 18px, padding `space-lg` (`24px`).
- **Indicator Header:** Left-aligned icon and label in `label-caps` (`#6B7280`), right-aligned live status pill.
- **Metric Presentation:** `headline-metric-lg-mobile` (`#1F2937`) with immediate inline unit notation (e.g., `84%`, `12.4 kg`).
- **Fill Progress Rail:** Horizontal bar (height 12px, radius 6px) filled with contextual color (`#2E7D32` for healthy feed, `#1976D2` for water, `#F9A825` for threshold alerts) over neutral track `#F6F7F4`.

### 3. Status Badges & Chips
- **Success:** Background `#E8F5E9`, text `#1B5E20`, dot indicator `#2E7D32`.
- **Warning:** Background `#FFF8E1`, text `#B78103`, dot indicator `#F9A825`.
- **Critical:** Background `#FFEBEE`, text `#B71C1C`, dot indicator `#D32F2F`.
- **Dimensions:** Height 28px, padding horizontal 10px, radius 9999px, typography `label-md`.

### 4. Input Fields & Steppers
- **Text Inputs:** Height 48px, background `#FFFFFF`, border 1px solid `#E2E4DE`, focus border 2px solid `#2E7D32`.
- **Physical Stepper Controls (Feeding Schedule Quantities):** Split button module with oversized `+` and `-` segments (48×48px each) sandwiching high-contrast tabular body text.

### 5. Checkboxes, Radios & Switches
- **Form Controls:** Touch area 48×48px, visible control 24×24px.
- **Switches (Schedules/Automations):** Pill width 52px, height 32px. Active track `#2E7D32`, knob `#FFFFFF` with Elevation 1 shadow.

### 6. Three-Tab Bottom Navigation
- **Structure:** Fixed bottom position, background `#FFFFFF`, border-top 1px solid `#E2E4DE`, height 64px + safe area inset.
- **Tabs:** Three equally distributed slots: *Home* (Dashboard), *Schedule* (Dispense timings), *Alerts* (Log & Thresholds).
- **Active State:** Icon and label colored `#2E7D32` with a subtle top indicator dot.
- **Inactive State:** Icon and label colored `#6B7280`.

### 7. Alert List Item
- **Layout:** Horizontal card stack, radius 12px, border 1px solid `#E2E4DE`, left accent edge strip (4px solid) colored semantically by severity (`#D32F2F`, `#F9A825`, or `#1976D2`).
- **Typography:** Alert header in `label-lg`, relative timestamp in `label-md` (`#6B7280`).