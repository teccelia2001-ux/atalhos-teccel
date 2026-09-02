/* Service worker dos Atalhos Teccel.

   Serve para duas coisas: deixar o app instalável — instalado, ele abre sem a
   barra de endereço, no celular e no PC — e fazer abrir sem sinal. Um painel
   de atalhos que não abre offline perde metade da graça: a lista de links é a
   primeira coisa que se procura quando a internet está ruim.

   Mesma estratégia do app de inspeções, de propósito diferente por tipo:
   - a página e o código: REDE PRIMEIRO, com cache como rede de segurança.
     Assim uma correção publicada chega no próximo acesso com internet.
   - ícones e manifest: CACHE PRIMEIRO. Não mudam quase nunca.

   Os atalhos do usuário NÃO passam por aqui: ficam no armazenamento do
   próprio aparelho (localStorage), gravados pela página. Ver Guardados,
   no index.html. */

var VERSAO = "atalhos-v9";   // v9: icone do Citrix Workspace (02/09/2026)
var ESSENCIAIS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icones/icone-192.png",
  "./icones/icone-512.png",
  "./icones/icone-512-mascara.png",
  "./icones/icone-apple-180.png",
  "./icones/logo-teccel.png",
  "./icones/site-painel.png",
  "./icones/site-inspecoes.png",
  "./icones/site-analise.svg",
  "./icones/site-obras.svg",
  "./icones/site-leite.png",
  "./icones/site-detalhada.svg",
  "./icones/site-programacao.png",
  "./icones/site-citrix.png"
];

self.addEventListener("install", function (e) {
  e.waitUntil(
    caches.open(VERSAO)
      .then(function (c) { return c.addAll(ESSENCIAIS); })
      /* Um essencial que falhe não pode impedir a instalação: melhor o app
         instalado com cache parcial do que não instalado. */
      .catch(function () {})
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (nomes) {
      return Promise.all(nomes.map(function (n) {
        if (n !== VERSAO) return caches.delete(n);
      }));
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET") return;

  var url = new URL(req.url);
  /* Os sites de destino não são deste app: passam direto, sem cache. */
  if (url.origin !== self.location.origin) return;

  var ehEstatico = /\/icones\/|\.webmanifest$/.test(url.pathname);

  if (ehEstatico) {
    e.respondWith(
      caches.match(req).then(function (guardado) {
        return guardado || fetch(req).then(function (r) {
          var copia = r.clone();
          caches.open(VERSAO).then(function (c) { c.put(req, copia); });
          return r;
        });
      })
    );
    return;
  }

  /* Página e código: rede primeiro.

     cache:"no-cache" não é exagero. O GitHub Pages responde com
     Cache-Control: max-age=600, e um fetch comum — mesmo aqui dentro — é
     servido pelo cache HTTP do navegador durante esses 10 minutos. Sem isto,
     "rede primeiro" não chega à rede e o aparelho fica na versão antiga
     depois de publicar. Com no-cache o navegador revalida pelo ETag: se nada
     mudou vem 304, e não custa banda. */
  e.respondWith(
    fetch(req, { cache: "no-cache" }).catch(function () {
      return fetch(req);          // navegador antigo que ignore a opção
    }).then(function (r) {
      var copia = r.clone();
      caches.open(VERSAO).then(function (c) { c.put(req, copia); });
      return r;
    }).catch(function () {
      return caches.match(req).then(function (guardado) {
        return guardado || caches.match("./index.html");
      });
    })
  );
});
