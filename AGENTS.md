# LearnHub UI Contribution Guide

Before changing user-facing UI, read `DESIGN_SYSTEM.md` and inspect the shared JSP fragments in `src/main/webapp/WEB-INF/views/common/`.

## Stack and conventions

- The presentation layer is Java 17, Jakarta Servlet/JSP, and JSTL, packaged as a Maven WAR.
- Views live under `src/main/webapp/WEB-INF/views/`; shared page structure is provided by JSP includes.
- Styling currently uses Tailwind CSS through the CDN configured in `common/header.jsp`, with Inter and Font Awesome.
- Keep presentation changes in JSP, CSS, and existing frontend assets. Do not introduce a frontend framework or build pipeline for a routine UI change.

## UI rules

- Follow the palette, typography, spacing, radii, and responsive guidance in `DESIGN_SYSTEM.md`.
- Reuse existing shared includes and repeated UI patterns. If a pattern appears in multiple views, prefer a JSP include or tag file over copying divergent markup.
- Prefer named Tailwind theme colors and standard Tailwind scale utilities. Do not add arbitrary hex colors, one-off spacing values, or ad hoc typography when an existing token or utility fits.
- If the design genuinely needs a new token, explain why and update `DESIGN_SYSTEM.md` in the same change.
- Keep pages responsive and preserve semantic HTML, keyboard accessibility, visible focus states, and readable contrast.
- Keep user-facing copy consistent with the language already used by the target view; do not change application behavior while making a visual-only change.

## Before finishing a UI change

- Review the changed view alongside its shared header, navbar, and footer as applicable.
- Check the relevant desktop and mobile layouts when a preview environment is available.
- Summarize the views and shared patterns changed, and mention any visual behavior that could not be checked.
