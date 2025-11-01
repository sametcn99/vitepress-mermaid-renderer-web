import { h, nextTick, onMounted, watch } from "vue";
import type { Theme } from "vitepress";
import DefaultTheme from "vitepress/theme";
import "./style.css";
import { createMermaidRenderer } from "vitepress-mermaid-renderer";
import "vitepress-mermaid-renderer/dist/style.css";
import { useData } from "vitepress";

export default {
	extends: DefaultTheme,
	Layout: () => {
		const { isDark } = useData();
		const mermaidRenderer = createMermaidRenderer({
			theme: isDark.value ? "dark" : "forest",
		});

		const scheduleRender = () => {
			mermaidRenderer.setConfig({
				theme: isDark.value ? "dark" : "forest",
			});
			nextTick(() => {
				mermaidRenderer.renderMermaidDiagrams();
			});
		};

		// Delay initialization until after hydration completes
		onMounted(() => {
			mermaidRenderer.initialize();
			requestAnimationFrame(scheduleRender);
		});

		// on theme change, re-render mermaid charts
		watch(
			() => isDark.value,
			() => {
				scheduleRender();
			}
		);
		return h(DefaultTheme.Layout);
	},
} satisfies Theme;
