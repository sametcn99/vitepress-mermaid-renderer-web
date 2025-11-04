# Getting Started

## Prerequisites

- Node.js 18.0.0 or newer (aligned with VitePress 1.x support)
- An existing VitePress project (`npm create vitepress@latest`)
- No other Mermaid plugin running (remove older integrations to avoid duplicate renderers)

## Installation

Install the package using your preferred package manager:

::: code-group

```bash [npm]
npm install vitepress-mermaid-renderer
```

```bash [yarn]
yarn add vitepress-mermaid-renderer
```

```bash [pnpm]
pnpm add vitepress-mermaid-renderer
```

```bash [bun]
bun add vitepress-mermaid-renderer
```

:::

## Setup

1. **Wire up the renderer in your theme entry.** Update `.vitepress/config.ts` (or `.vitepress/theme/index.ts`) to match the structure below:

```typescript
import { h, nextTick, watch } from "vue";
import type { Theme } from "vitepress";
import { useData } from "vitepress";
import DefaultTheme from "vitepress/theme";
import { createMermaidRenderer } from "vitepress-mermaid-renderer";
import "vitepress-mermaid-renderer/dist/style.css";
import "./style.css";

export default {
 extends: DefaultTheme,
 Layout: () => {
  const { isDark } = useData();

  const initMermaid = () => {
   nextTick(() =>
    createMermaidRenderer({
     theme: isDark.value ? "dark" : "forest",
    }).initialize()
   );
  };

  // Initial render
  nextTick(() => initMermaid());

  // on theme change, re-render mermaid charts
  watch(
   () => isDark.value,
   () => {
    initMermaid();
   }
  );

  return h(DefaultTheme.Layout);
 },
} satisfies Theme;
```

2. **Understand the moving parts**
   - `nextTick` ensures Mermaid runs after VitePress finishes rendering the current page.
   - The `watch` on `isDark` re-renders diagrams when readers toggle light/dark mode.
   - `createMermaidRenderer()` centralizes Mermaid configuration.

3. **Start the docs in development mode** so you can confirm the toolbar appears and theme switching works:

```bash
npm run docs:dev
```

## Client-side Only Rendering

This plugin implements safeguards to prevent server-side rendering (SSR) issues:

- The initialization checks for browser environment before executing
- The rendering functions only operate in client-side context
- A safe wrapper function `createMermaidRenderer()` provides a no-op implementation during SSR

If you're encountering SSR-related errors, make sure you're using the `createMermaidRenderer()` function instead of directly using `MermaidRenderer.getInstance()`.

## Basic Usage

Create a code block with the language set to `mermaid`:

\`\`\`mermaid
flowchart TD
A[Start] --> B{Is it?}
B -->|Yes| C[OK]
B -->|No| D[NOT OK]
\`\`\`

This will render an interactive diagram with zoom, pan, reset view and fullscreen controls.

## Configuration

You can customize the Mermaid settings by passing a configuration object when getting the instance:

```ts
const mermaidRenderer = createMermaidRenderer({
  theme: "dark",
  sequence: {
    diagramMarginX: 50,
    diagramMarginY: 10,
  },
  // ... other Mermaid configuration options
});
```

For available configuration options, refer to the [Mermaid documentation](https://mermaid.js.org/config/configuration.html).

### Theme-specific overrides

Because the renderer re-initializes on theme changes, you can provide dynamic options:

```ts
const { isDark } = useData();

createMermaidRenderer({
  theme: isDark.value ? "dark" : "forest",
});
```

All calls merge with the default Mermaid config, so you only need to specify the keys you want to change.

## How This Plugin Differs from `vitepress-plugin-mermaid`

When evaluating Mermaid integrations for VitePress, you might come across the [`vitepress-plugin-mermaid`](https://emersonbottero.github.io/vitepress-plugin-mermaid/guide/getting-started.html) package. Both plugins enable Mermaid diagrams, but they target different needs:

- **Theme awareness:** This renderer reacts to VitePress theme changes out of the box. The alternative plugin renders diagrams with a fixed theme, so dark/light mode switches do not re-style existing diagrams without manual intervention.
- **Interactive controls:** Fullscreen mode, zoom in/out, pan, and reset view controls are bundled here. The comparison plugin renders static SVGs with no built-in viewport controls, which limits usability for large diagrams.
- **Mermaid configuration surface:** `createMermaidRenderer()` accepts the full Mermaid configuration object, letting you tweak themes, sequence diagram margins, font settings, or custom directives in one place. The other plugin exposes only a small subset of Mermaid options, so advanced chart tuning often requires custom scripting.

### Installation and setup trade-offs

- **`vitepress-plugin-mermaid`:** Installation is minimal—install the dependency and reference it in `config.ts`. If you only need basic Mermaid support under a single theme, this simplicity might be enough.
- **`vitepress-mermaid-renderer`:** Setup adds a few lines to hook into the VitePress layout and watch the current theme, but those extra steps unlock responsive theming, client-only safeguards, and richer interactive features. If you rely on presentation polish, dark/light parity, or fine-grained Mermaid config, the additional wiring pays off quickly.

## Feature highlights

- Toolbar with fullscreen, zoom, pan, and reset controls for every diagram
- Automatic dark/light theme sync using VitePress' built-in theme context
- Global Mermaid configuration plus per-page overrides through standard config objects
- Lazy, client-only rendering to keep SSR builds clean and fast
- Type-safe API (TypeScript definitions included) for confident customization
