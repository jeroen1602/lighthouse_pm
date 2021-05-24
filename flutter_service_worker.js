'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "sql-wasm.js": "8ffd545d7b00ab4de0b2d0492f555ac7",
"favicon.png": "d32b512bfd66a116e675fe864db8eed4",
"index.html": "e4d18202a1484bfaacda14622ea2812d",
"/lighthouse_pm/": "e4d18202a1484bfaacda14622ea2812d",
"version.json": "d90d62bccf2f343070fb1cd62edfd92e",
"icons/mstile-310x310.png": "9419249e7e9e11e1fe7a1de190a8304d",
"icons/mstile-310x150.png": "f4c3653e2da6b580a09a88710a7ec1d4",
"icons/safari-pinned-tab.svg": "cc7e7acbab749669f9b0cb7570812d22",
"icons/mstile-70.png": "2c81f1c539a022e934e4de4e12504fea",
"icons/mstile-144.png": "b5a15b7858f85d3a7047f6c6128dd872",
"icons/Icon-192.png": "9cab1d44b6bc9812d5ff5aa22b3b12ab",
"icons/apple-touch-icon.png": "e86b5eb5b5145405c39a34696a63f8a4",
"icons/mstile-150.png": "7ef50e7d43fbb2edd3662c730fc59070",
"icons/Icon-512.png": "c662c0a7f2e6219873444b01d3e59878",
"sql-wasm.wasm": "e96391fc594b5869546a3cdac4e76b10",
"main.dart.js": "94c37a24acf8e7b530fd07954c3f7fc8",
"assets/assets/images/github-dark.svg": "4ac453ada040b84b3ccc18a283e2d6b4",
"assets/assets/images/drawer-image.png": "8fec0be6b48e209e3f5499aea6b47f97",
"assets/assets/images/group-edit-icon.svg": "686fe3c780d7c3e1e68a32e493c6e997",
"assets/assets/images/github-light.svg": "37e3300327739c58e3752fc0b59929e0",
"assets/assets/images/group-delete-icon.svg": "8012a3bf0fcde7a231f65721315fd67b",
"assets/assets/images/nickname-icon.svg": "f7a5bb1844a490314157bc3a44dc9c87",
"assets/assets/images/identify-icon.svg": "8ae75ddd46d273c1a42e754f18241443",
"assets/assets/images/group-add-icon.svg": "9fe25052844e6b9b429c374ec9fcc48c",
"assets/assets/images/app-icon.svg": "b57718e31f78c730fe9ae5425da04142",
"assets/NOTICES": "43767043bf5dec2b445b8209506f26b7",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/packages/community_material_icon/fonts/materialdesignicons-webfont.ttf": "174c02fc4609e8fc4389f5d21f16a296",
"assets/FontManifest.json": "3f768ae705296be001f7819d2895cc30",
"assets/AssetManifest.json": "0f5dfac45ec27161ac678649c46a75f7",
"favicon-32.png": "d8105b6735f4aad87217ebc42b1cf658",
"favicon.ico": "876d3b7504fd4f4f9e58d35f226f13cf",
"manifest.json": "610dcc31ff3aa9c8c03ab6cbc0d402bc",
"browserconfig.xml": "517c3d288a007e4b4b811d5e55f99562"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/lighthouse_pm/",
"main.dart.js",
"index.html",
"assets/NOTICES",
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
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
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
