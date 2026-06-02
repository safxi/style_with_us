---
name: Cyber-Luxury Stylist
colors:
  surface: '#0e1322'
  surface-dim: '#0e1322'
  surface-bright: '#343949'
  surface-container-lowest: '#090e1c'
  surface-container-low: '#161b2b'
  surface-container: '#1a1f2f'
  surface-container-high: '#25293a'
  surface-container-highest: '#2f3445'
  on-surface: '#dee1f7'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#dee1f7'
  inverse-on-surface: '#2b3040'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#ffafd3'
  on-tertiary: '#620040'
  tertiary-container: '#e364a7'
  on-tertiary-container: '#560038'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#ffd8e7'
  tertiary-fixed-dim: '#ffafd3'
  on-tertiary-fixed: '#3d0026'
  on-tertiary-fixed-variant: '#85145a'
  background: '#0e1322'
  on-background: '#dee1f7'
  surface-variant: '#2f3445'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
This design system embodies the intersection of high-end fashion and cutting-edge artificial intelligence. The aesthetic is **Cyber-Luxury**, a fusion of sophisticated minimalism and futuristic digital interfaces. It targets fashion-forward users and luxury brands who value precision, exclusivity, and technological innovation.

The visual language utilizes **Glassmorphism** to create a sense of depth and translucency, mimicking the refractive quality of premium retail displays and digital prisms. The UI should feel ethereal yet grounded, using heavy background blurs and micro-interactions to evoke a high-fidelity, "pro-grade" experience.

## Colors
The palette is rooted in a deep, nocturnal foundation to allow the content to radiate.
- **Backgrounds:** A mix of Deep Charcoal (#050505) for absolute depth and Midnight Navy (#0A0F1E) for layered surfaces.
- **Accents:** Electric Violet (#8B5CF6) serves as the primary action color, symbolizing the "AI spark." Cyber Cyan (#06B6D4) is used for data visualization, secondary highlights, and success states.
- **Glass Tint:** Semi-transparent white (10-15% opacity) is used for borders and surface overlays to define glass layers without muddying the dark background.

## Typography
The design system relies on **Inter** for its systematic, neutral, and highly legible characteristics. To maintain a luxury feel, we utilize a high-contrast hierarchy and generous whitespace between text blocks. 

Key headers should use tighter letter spacing to feel "locked" and architectural, while small labels use increased tracking and uppercase styling to denote metadata or AI-generated categories. Body text maintains a comfortable line height (1.5x) to ensure readability against dark, blurred backgrounds.

## Layout & Spacing
The layout follows a **Fluid Grid** model based on an 8px baseline. 
- **Mobile:** 4-column layout with 24px side margins. Elements reflow into a single-column stack for product feeds.
- **Desktop (Brand Portal):** 12-column layout with a fixed left-side navigation rail.
- **Rhythm:** Use a "Stack" philosophy for vertical spacing. Small components (label + input) use 8px; grouped items use 16px; distinct sections use 32px+. 

Margins are generous to prevent the UI from feeling "cramped," reinforcing the premium positioning of the brand.

## Elevation & Depth
Elevation is achieved through **Glassmorphism** rather than traditional drop shadows.
1. **The Base:** Midnight Navy or Charcoal background.
2. **The Glass Layer:** A surface with a `backdrop-filter: blur(20px)` and a background color of `rgba(255, 255, 255, 0.05)`.
3. **The Edge:** A 1px solid border with `rgba(255, 255, 255, 0.15)` on the top and left, and `rgba(255, 255, 255, 0.05)` on the bottom and right to simulate light hitting a glass edge.
4. **Soft Glow:** In place of shadows, use very low-opacity colored glows (using the accent colors) behind primary cards to indicate "active" or "AI-powered" status.

## Shapes
The shape language is modern and balanced. 
- **Standard UI Elements:** (Buttons, Input Fields) Use a 0.5rem (8px) radius. 
- **Glass Cards:** Use a 1rem (16px) radius to create a softer, more premium container.
- **AI Score Circles:** Must be perfectly circular (50% radius) to contrast against the rectangular grid.
- **Avatars:** Circular to maintain human-centric focus within a technical interface.

## Components

### Glassmorphic Cards
The primary container for product items and styling suggestions. Features a frosted glass background, subtle 1px white border, and a slight inner glow. Imagery within cards should have a subtle desaturation that returns to full color on hover.

### Circular Progress Indicators
Used for "AI Style Match" scores. These use a Cyber Cyan stroke with a gradient trail leading into Electric Violet. The center of the circle displays the percentage in `label-sm` uppercase typography.

### Shimmer Loading States
In place of static skeletons, use a directional shimmer with a 45-degree angle. The shimmer gradient moves from a dark charcoal to a slightly lighter navy, creating a "scanning" effect that feels intentional and technological.

### Sleek Navigation
- **User App:** A bottom navigation bar with a heavy backdrop blur. Icons use a "dual-tone" style: Cyber Cyan for the active state and 40% opacity white for inactive.
- **Brand Portal:** A vertical navigation rail (collapsed) or drawer (expanded) on the left. The rail uses a high-contrast border to separate the management tools from the visual workspace.

### Buttons
- **Primary:** Solid Electric Violet with white text. No shadow; instead, use a 4px outer glow of the same color on hover.
- **Secondary:** Glass-style with a Cyber Cyan border and no background fill.