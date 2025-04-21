'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"drift_worker.js": "babb348cf72e6da955c4386f67316e28",
"assets/assets/pages/privacy/v1.0_en.md": "cbee2ad1a511847e351dd3ece3e7b46f",
"assets/assets/pages/privacy/v1.1_en.md": "1b9ec959d886f01614689edc6eca54d7",
"assets/assets/pages/privacy/v1.2_en.md": "3dc51dda3710c3c42ed27a5f9dd66586",
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
"assets/AssetManifest.bin": "04f9b2b2909a5ce2323761c091090044",
"assets/NOTICES": "6a2ce7b2cefeee44869d3887fdcf8ddb",
"assets/AssetManifest.json": "cfedf632405c490a8fbc931062f83206",
"assets/fonts/MaterialIcons-Regular.otf": "b40304d4a02396a1eb32cdf95cd70e50",
"assets/AssetManifest.bin.json": "2b7dd4bdb306fbeabbf2db1216858d72",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"index.html": "10f462bb91d7abcfe8b4b8448328b96d",
"/lighthouse_pm/": "10f462bb91d7abcfe8b4b8448328b96d",
"favicon.ico": "876d3b7504fd4f4f9e58d35f226f13cf",
"browserconfig.xml": "517c3d288a007e4b4b811d5e55f99562",
"main.dart.js": "ab4fd0bdd2677441b4155d55a80ce944",
"favicon.png": "d32b512bfd66a116e675fe864db8eed4",
"manifest.json": "3de96449813f67b75ab73c0a480ebff4",
"sqlite3.wasm": "d9fe0deaa4703e3ce03614741774735b",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"flutter_bootstrap.js": "cd4ffb3c17a27ec353246fb234aaf7fc",
"version.json": "15a551bfb025d9bd42216f752264a066",
"favicon-32.png": "d8105b6735f4aad87217ebc42b1cf658",
"flutter.js": "76f08d47ff9f5715220992f993002504",
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
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
