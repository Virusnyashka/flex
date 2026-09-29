// Офлайн-кеш «Моя зарплата Flex».
// Версию и список файлов подставляет tool/build_pwa.sh после сборки.
const VERSION = '__VERSION__';
const FILES = __FILES__;
const CACHE = `flex-${VERSION}`;
const RUNTIME = 'flex-runtime';
const scope = self.registration.scope;
const indexUrl = new URL('index.html', scope).href;

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(FILES.map((f) => new URL(f, scope).href)))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== CACHE && k !== RUNTIME).map((k) => caches.delete(k)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);

  // Открытие приложения: свежая страница из сети, без сети — из кеша.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() => caches.match(indexUrl)),
    );
    return;
  }

  // Файлы приложения: из кеша текущей версии.
  if (url.origin === self.location.origin) {
    event.respondWith(
      caches.match(request, { ignoreSearch: true })
        .then((hit) => hit || fetch(request)),
    );
    return;
  }

  // Шрифты, которые движок Flutter подгружает с Google Fonts:
  // один раз из сети, дальше из кеша.
  if (url.hostname === 'fonts.gstatic.com' || url.hostname === 'fonts.googleapis.com') {
    event.respondWith(
      caches.open(RUNTIME).then((cache) =>
        cache.match(request).then((hit) => hit || fetch(request).then((response) => {
          if (response.ok) cache.put(request, response.clone());
          return response;
        })),
      ),
    );
  }
});
