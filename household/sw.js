/* Get a Grip Household has moved to https://dmhmca.github.io/get-a-grip-household/ : this worker clears its old copies and removes itself */
self.addEventListener('install',function(){self.skipWaiting();});
self.addEventListener('activate',function(e){e.waitUntil(caches.keys().then(function(ks){return Promise.all(ks.filter(function(k){return k.indexOf('household-')===0;}).map(function(k){return caches.delete(k);}));}).then(function(){return self.registration.unregister();}).then(function(){return self.clients.matchAll();}).then(function(cs){cs.forEach(function(c){c.navigate(c.url);});}));});
