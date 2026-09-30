// Keep Spotify usable in narrow Hyprland tiles, independently of the theme.
(() => {
  const id = "omarchy-tiling-fit";
  document.getElementById(id)?.remove();
  const style = document.createElement("style");
  style.id = id;
  style.textContent = `
    @media (max-width: 799px) {
      body { min-width: 0 !important; }
      .Root__top-container {
        min-width: 0;
        grid-template-columns: auto minmax(0, 1fr) 0 !important;
      }
      .Root__main-view {
        min-width: 0;
        grid-area: main-view !important;
      }
      .Root__right-sidebar,
      .Root__right-sidebar-peek,
      .Root__right-sidebar-overlayWrapper { display: none !important; }
      .Root__now-playing-bar,
      .main-nowPlayingBar-container { min-width: 0 !important; }
      .main-nowPlayingBar-nowPlayingBar {
        display: grid !important;
        grid-template-columns: minmax(0, 1fr) auto;
        grid-template-areas: "track extras" "controls controls";
        gap: 8px 12px;
        height: auto !important;
        padding-block: 8px;
      }
      .main-nowPlayingBar-left {
        grid-area: track;
        width: 100% !important;
        min-width: 0 !important;
      }
      .main-nowPlayingBar-center {
        grid-area: controls;
        width: 100% !important;
        max-width: none !important;
        min-width: 0;
      }
      .main-nowPlayingBar-right {
        grid-area: extras;
        width: auto !important;
        min-width: 0 !important;
      }
    }
  `;
  document.head.appendChild(style);
})();
