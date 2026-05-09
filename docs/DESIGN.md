---
name: Agri-Care Intelligence
colors:
  surface: '#faf9f5'
  surface-dim: '#dadad6'
  surface-bright: '#faf9f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f4f0'
  surface-container: '#eeeeea'
  surface-container-high: '#e9e8e4'
  surface-container-highest: '#e3e3df'
  on-surface: '#1a1c1a'
  on-surface-variant: '#424842'
  inverse-surface: '#2f312e'
  inverse-on-surface: '#f1f1ed'
  outline: '#727971'
  outline-variant: '#c2c8c0'
  surface-tint: '#47654d'
  primary: '#45634b'
  on-primary: '#ffffff'
  primary-container: '#5d7c62'
  on-primary-container: '#f7fff4'
  inverse-primary: '#adcfb1'
  secondary: '#75584d'
  on-secondary: '#ffffff'
  secondary-container: '#fed7ca'
  on-secondary-container: '#795c51'
  tertiary: '#7b5059'
  on-tertiary: '#ffffff'
  tertiary-container: '#966871'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c9ebcc'
  primary-fixed-dim: '#adcfb1'
  on-primary-fixed: '#03210e'
  on-primary-fixed-variant: '#304d36'
  secondary-fixed: '#ffdbce'
  secondary-fixed-dim: '#e4beb2'
  on-secondary-fixed: '#2b160f'
  on-secondary-fixed-variant: '#5b4137'
  tertiary-fixed: '#ffd9df'
  tertiary-fixed-dim: '#efb8c2'
  on-tertiary-fixed: '#311119'
  on-tertiary-fixed-variant: '#633b44'
  background: '#faf9f5'
  on-background: '#1a1c1a'
  surface-variant: '#e3e3df'
typography:
  headline-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 20px
    fontWeight: '400'
    lineHeight: 30px
  body-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  label-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.5px
  button-text:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  touch-target-min: 56px
  margin-mobile: 20px
  gutter: 16px
  stack-space: 24px
---

## Brand & Style

The brand personality of this design system is rooted in "Digital Stewardship"—a blend of modern agricultural precision and the comforting reliability of a seasoned farm hand. It is designed specifically to lower the cognitive load for elderly users and those with low digital literacy.

The visual style follows a **Modern Tactile** approach. It avoids the coldness of high-tech "cyberpunk" aesthetics in favor of a soft, organic interface that feels physical and dependable. We utilize high-contrast elements, large interactive zones, and a "WhatsApp-style" linear flow to ensure the user always knows their current location and their next step. The emotional response is one of calm, confidence, and growth.

## Colors

The palette is inspired by a thriving greenhouse at dawn.
- **Primary (Sage Green):** Used for navigation and main branding, evoking growth and stability.
- **Secondary (Earthy Brown):** Used for grounding elements and secondary actions, providing a sense of soil and nature.
- **Neutral (Crisp White & Slate):** The background is a very soft off-white to reduce screen glare, while text uses a deep slate rather than pure black to improve readability for aging eyes.
- **Status Colors:** These are highly saturated to ensure clarity. Emerald signifies "All is well," Amber suggests "Check soon," and Crimson indicates "Needs immediate attention."

## Typography

We have selected **Atkinson Hyperlegible Next** as the sole typeface for this design system. It was specifically designed for low-vision users, focusing on letterform distinction (e.g., differentiating 'I', 'l', and '1').

- **Scale:** Font sizes are oversized by standard UI benchmarks to accommodate age-related sight decline. 
- **Readability:** We maintain generous line heights to prevent text "crowding."
- **Contrast:** All typography must maintain a minimum contrast ratio of 7:1 against its background.

## Layout & Spacing

This design system uses a **Fluid Mobile-First Grid** optimized for single-column vertical scrolling.

- **The Thumb Zone:** Essential interactive elements are placed in the lower 60% of the screen.
- **Margins:** Wide 20px side margins prevent accidental touches on edge-to-edge screens.
- **Stacking:** We use a generous 24px vertical rhythm between cards to clearly separate different "thoughts" or "tasks."
- **Constraints:** Avoid multi-column layouts for data. Use simple, full-width rows to ensure clarity of information hierarchy.

## Elevation & Depth

Depth is used sparingly and functionally rather than decoratively.
- **Tonal Layers:** We use soft, tinted backgrounds for the main canvas and pure white for interactive cards to make them "pop."
- **Low-Contrast Shadows:** Cards use a soft, large-radius shadow tinted with the primary sage green (e.g., `rgba(93, 124, 98, 0.08)`) to create a sense of physical objects resting on a surface.
- **Active State:** When a button or card is pressed, it should visually "sink" (reduce shadow and slightly scale down) to provide immediate tactile feedback.

## Shapes

The shape language is "Friendly and Padded."
- **Radius:** A standard `16px` (rounded-lg) radius is used for all primary cards and buttons.
- **Icons:** Icons must have a `2.5px` or `3px` stroke weight with rounded caps and corners. Sharp points are strictly avoided.
- **Containment:** Interactive elements are always enclosed in a visible container to define their boundaries clearly.

## Components

- **Chunky Buttons:** Primary buttons are a minimum of 56px tall with a solid background and high-contrast white text. They should span the full width of their container for easy tapping.
- **Large Rounded Cards:** Content is grouped into white cards. Each card should focus on one single metric (e.g., "Water Level") or one single action (e.g., "Add Fertilizer").
- **Visual Status Chips:** Use large, pill-shaped chips with both an icon and text (e.g., a green checkmark + "Healthy") to ensure the status is understood regardless of color perception.
- **Thick-Stroke Icons:** Use 24px or 32px icons with heavy weights. Every icon must be accompanied by a text label.
- **Simple Inputs:** Text fields should have thick borders (2px) and include "helper text" that stays visible even when the user starts typing.
- **The "Assistant" Bar:** A persistent bottom navigation or floating action area that provides one-tap access to help or AI suggestions, mimicking the simplicity of a chat interface.