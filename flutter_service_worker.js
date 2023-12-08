'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"drift_worker.js": "88186dcd226115406d397f5d5628d338",
"assets/assets/pages/privacy/v1.0_en.md": "cbee2ad1a511847e351dd3ece3e7b46f",
"assets/assets/pages/privacy/v1.1_en.md": "1b9ec959d886f01614689edc6eca54d7",
"assets/assets/pages/help/pairing_en.md": "6570e0c68770e91545fffa0f9b4806a6",
"assets/assets/pages/help/nickname_en.md": "935f8c062743c3a7b08341d03c08b153",
"assets/assets/pages/help/extended_en.md": "1af8859a289876a9612b2b0bfd57ccd3",
"assets/assets/pages/help/metadata_en.md": "bb8c8ae6626a4d3f892585626f111f20",
"assets/assets/pages/help/group_en.md": "1518fcdc3831b8860b1ddb354b70dc88",
"assets/assets/images/group-add-icon.svg": "9fe25052844e6b9b429c374ec9fcc48c",
"assets/assets/images/github-dark.svg": "4ac453ada040b84b3ccc18a283e2d6b4",
"assets/assets/images/identify-icon.svg": "8ae75ddd46d273c1a42e754f18241443",
"assets/assets/images/github-sponsors.svg": "d552884c986c1f9d435d7ac6057662c6",
"assets/assets/images/group-delete-icon.svg": "8012a3bf0fcde7a231f65721315fd67b",
"assets/assets/images/nickname-icon.svg": "f7a5bb1844a490314157bc3a44dc9c87",
"assets/assets/images/drawer-image.png": "8fec0be6b48e209e3f5499aea6b47f97",
"assets/assets/images/paypal.svg": "279458c895f57b7042dcded48da7ffc0",
"assets/assets/images/github-light.svg": "37e3300327739c58e3752fc0b59929e0",
"assets/assets/images/f-droid-logo.svg": "2d54fdd2088c56aedc715309490dbe83",
"assets/assets/images/app-icon.svg": "b57718e31f78c730fe9ae5425da04142",
"assets/assets/images/group-edit-icon.svg": "686fe3c780d7c3e1e68a32e493c6e997",
"assets/FontManifest.json": "3f768ae705296be001f7819d2895cc30",
"assets/packages/toast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/toast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/community_material_icon/fonts/materialdesignicons-webfont.ttf": "84c7bd136590da0a6ed2c21df180c354",
"assets/AssetManifest.bin": "c29493e6728468a053218ba6105feeb7",
"assets/NOTICES": "918051e4e8f1d54be486bc69330c938d",
"assets/AssetManifest.json": "0b101412204a0cd5e75ebcf059ae1865",
"assets/fonts/MaterialIcons-Regular.otf": "8362247fc0583d41c0af43cd4abf141a",
"assets/AssetManifest.bin.json": "3829fa1be870af3f2eb12ec14a6bf513",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"index.html": "f4a2093cf8d232308b531fc8c6283f5d",
"/lighthouse_pm/": "f4a2093cf8d232308b531fc8c6283f5d",
"favicon.ico": "876d3b7504fd4f4f9e58d35f226f13cf",
"browserconfig.xml": "517c3d288a007e4b4b811d5e55f99562",
"main.dart.js": "cc3972392dbe8831d153d2e153911552",
"favicon.png": "d32b512bfd66a116e675fe864db8eed4",
"manifest.json": "3de96449813f67b75ab73c0a480ebff4",
"sqlite3.wasm": "79a4cf7ac1cf1f9d5081474f5a7bb5ba",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"version.json": "8cf2d6d116faacaf43066487e8f75eb3",
"favicon-32.png": "d8105b6735f4aad87217ebc42b1cf658",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"icons/icon-512.png": "c662c0a7f2e6219873444b01d3e59878",
"icons/mstile-310x150.png": "f4c3653e2da6b580a09a88710a7ec1d4",
"icons/mstile-144.png": "b5a15b7858f85d3a7047f6c6128dd872",
"icons/mstile-70.png": "2c81f1c539a022e934e4de4e12504fea",
"icons/maskable_icon.png": "c8b04af1fded52277ce9bb614244444b",
"icons/safari-pinned-tab.svg": "cc7e7acbab749669f9b0cb7570812d22",
"icons/maskable_icon_x192.png": "06926a67e89d80c90b0d3615a8141adc",
"icons/mstile-310x310.png": "9419249e7e9e11e1fe7a1de190a8304d",
"icons/monochrome_icon.png": "9e0e39a5b73baa867c706c8a548995c1",
"icons/mstile-150.png": "7ef50e7d43fbb2edd3662c730fc59070",
"icons/icon-192.png": "9cab1d44b6bc9812d5ff5aa22b3b12ab",
"icons/apple-touch-icon.png": "e86b5eb5b5145405c39a34696a63f8a4",
"icons/maskable_icon_x512.png": "010d56d1358a90329637a7837a54dfc8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
