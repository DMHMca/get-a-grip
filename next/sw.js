const CACHE='get-a-grip-next-v18';
const CORE=['./','./index.html','./manifest.webmanifest','./icon-192.png','./icon-512.png','./icon-maskable-512.png','./apple-touch-icon.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting()));});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k.indexOf('get-a-grip-next-')===0&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',e=>{
  const req=e.request;
  if(req.method!=='GET')return;
  const url=new URL(req.url);
  const okHost=url.origin===location.origin||url.hostname==='fonts.googleapis.com'||url.hostname==='fonts.gstatic.com';
  if(!okHost)return;
  // the preview copy in /next/ has its own service worker and storage; never touch it from here
  if(url.origin===location.origin&&url.pathname.indexOf('/next/')>-1)return;
  if(req.mode==='navigate'){
    // the app: try the network first so updates arrive, fall back to the saved copy offline.
    // Other pages (such as the privacy page) are left alone and never replace the saved app.
    const root=new URL('./',location.href).pathname;
    const isApp=url.pathname===root||url.pathname===root+'index.html';
    if(!isApp)return;
    e.respondWith(fetch(req,{cache:'no-cache'}).then(r=>{const c=r.clone();caches.open(CACHE).then(x=>x.put('./index.html',c));return r;}).catch(()=>caches.match('./index.html')));
    return;
  }
  // everything else: serve the saved copy at once, refresh it in the background
  e.respondWith(caches.match(req).then(hit=>{
    const net=fetch(req).then(r=>{if(r&&(r.ok||r.type==='opaque')){const c=r.clone();caches.open(CACHE).then(x=>x.put(req,c));}return r;}).catch(()=>hit);
    return hit||net;
  }));
});
