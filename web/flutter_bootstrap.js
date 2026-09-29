{{flutter_js}}
{{flutter_build_config}}

// Встроенный service worker Flutter устарел — используем свой sw.js,
// который кеширует всё приложение для работы без интернета.
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    // Встраиваем в #app, чтобы учитывать вырез экрана и полоску «Домой».
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#app'),
    });
    await appRunner.runApp();
  },
});

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch((e) => {
      console.warn('Service worker не зарегистрирован:', e);
    });
  });
}
