# LearnHub Design System

This document defines the shared visual language for LearnHub's JSP interface. It reflects the current direction in the views: warm light surfaces, slate text, a green learning-focused accent, and occasional near-black promotional panels.

## Frontend context

- Java 17, Jakarta Servlet/JSP, and JSTL; Maven packages the application as a WAR.
- JSP views are under `src/main/webapp/WEB-INF/views/`.
- Tailwind CSS is currently loaded from its CDN in `common/header.jsp`; the Tailwind theme is configured there.
- Inter is the interface font and Font Awesome supplies the existing icon set.
- Shared page chrome lives in `common/header.jsp`, `common/navbar.jsp`, and `common/footer.jsp`.

Since Tailwind runs from a CDN, keep the configuration compatible with Tailwind's browser CDN configuration. Avoid assuming a Tailwind CLI, config file, or component framework exists.

## Design principles

1. Use green as the primary action and progress accent; reserve near-black for high-emphasis feature panels.
2. Use warm off-white for page backgrounds and white for cards and forms.
3. Use slate for readable text and borders; secondary information should remain legible.
4. Favor clear hierarchy, generous whitespace, consistent alignment, and responsive layouts.
5. Keep color meaning consistent: green for primary/positive, amber for caution, and red for destructive/error states.

## Color tokens

| Token | Value | Tailwind usage | Intended use |
|---|---|---|---|
| `brand-50` | `#ecfdf3` | `bg-brand-50`, `text-brand-50` | Subtle accent surface |
| `brand-100` | `#d1fae5` | `bg-brand-100`, `border-brand-100` | Accent borders and selected surfaces |
| `brand-500` | `#10b981` | `text-brand-500` | Decorative accent |
| `brand-600` | `#059669` | `bg-brand-600` | Secondary brand actions |
| `brand-700` | `#028446` | `bg-brand-700`, `text-brand-700` | Primary action and links |
| `brand-800` | `#026b3a` | `hover:bg-brand-800` | Primary action hover |
| `brand-900` | `#064e3b` | `text-brand-900` | Deep accent |
| `surface` | `#faf9f6` | `bg-surface` | Main warm page background |
| `surface-footer` | `#E7E2D9` | `bg-surface-footer` | Warm footer background, distinct from page content |
| `surface-card` | `#ffffff` | `bg-surface-card` | Cards, dialogs, and forms |
| `surface-inverse` | `#0a0a0a` | `bg-surface-inverse` | Dark feature panels |
| `text-primary` | `#0f172a` | `text-text-primary` | Headings and main content |
| `text-secondary` | `#64748b` | `text-text-secondary` | Supporting copy and metadata |
| `border-default` | `#e2e8f0` | `border-border-default` | Standard outlines and dividers |
| `status-success` | `#15803d` | `text-status-success` | Success feedback |
| `status-warning` | `#b45309` | `text-status-warning` | Warning feedback |
| `status-danger` | `#b91c1c` | `text-status-danger` | Error and destructive feedback |

These values are the target palette for new and touched UI. Existing views still contain legacy blue `brand` configuration, slate utilities, and hard-coded colors. Migrate touched areas to the tokens consistently; avoid broad unrelated restyling.

## Typography

- Font family: Inter, with a sans-serif fallback.
- Use Tailwind's standard text scale. Typical patterns: `text-sm` for metadata and controls, `text-base` for body copy, `text-xl`/`text-2xl` for section headings, and `text-3xl` or above for hero headings.
- Use `font-medium` for labels, `font-semibold` for controls and subheadings, and `font-bold` for page/section headings. Reserve `font-black` for rare display emphasis.
- Keep body copy at a readable line height; use `leading-tight` only for short headings.

## Spacing, layout, and responsive behavior

- Use Tailwind's standard spacing scale; do not introduce arbitrary spacing values unless a visual requirement cannot be met with the scale.
- Common rhythm: `gap-4`/`gap-6` inside components, `p-4`/`p-6` for cards, and `py-12`/`py-16` for major sections.
- Use a consistent centered content container, commonly `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8` for full-width pages.
- Build mobile-first with Tailwind breakpoints (`sm`, `md`, `lg`); prevent horizontal overflow and ensure forms and primary actions remain usable on small screens.

## Shape, borders, and elevation

- Controls: `rounded-lg`.
- Standard cards: `rounded-xl`.
- Hero panels and large feature surfaces: `rounded-2xl` or `rounded-3xl` when already established by the page.
- Prefer `border border-border-default` and subtle shadows such as `shadow-sm`; reserve stronger shadows for floating or featured elements.
- Use consistent focus-visible rings on interactive elements; never remove the keyboard focus indicator.

## Component guidance for JSP

- Use shared JSP includes for page-wide structure. Keep page-specific content in the corresponding view.
- Reuse established markup for primary/secondary buttons, form controls, cards, badges, and alerts. Extract a JSP fragment or tag file when the same pattern is repeated across views.
- Keep interactive elements semantic: use `<button>` for actions and `<a>` for navigation. Provide labels for form inputs and meaningful alternative text for informative images.
- Avoid clickable non-interactive containers when a link or button can represent the action accessibly.

## Tailwind CDN theme configuration

Keep the theme in `src/main/webapp/WEB-INF/views/common/header.jsp` aligned with the tokens above. Tailwind CDN supports `theme.extend.colors`; extend it with the brand and semantic surface/text/border/status colors. For token classes in the table, semantic keys should map to the matching hex values (for example `surface`, `text-primary`, `border-default`, and `status-success`). Do not define a second conflicting palette in an individual JSP.

## Change checklist

- Does the view use the shared palette and typography?
- Are spacing, radii, borders, and shadows consistent with this guide?
- Does the layout work at mobile and desktop widths?
- Are focus, contrast, labels, and semantic interactions preserved?
- If a token or shared pattern was added, is this document updated in the same change?
