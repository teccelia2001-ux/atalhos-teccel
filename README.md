# Atalhos Teccel

Todos os sistemas e links de acesso num lugar só. Um toque abre no navegador.
Instalável no celular e no PC — instalado, abre sem barra de endereço e
funciona sem sinal.

## Como usar

- **＋ Novo** — guarda um link. Cole o endereço direto do navegador; sem o
  `https://` o app completa.
- **Grupo** — separa em seções (SESMT, Obras, Operação…). Em branco, cai em
  "Outros".
- **★ Fixar** — sobe o atalho para a primeira seção, a dos usados todo dia.
- **Reordenar** — arrastando, no PC; pelo menu ⋮ do cartão (mover para
  cima/baixo), no celular. Arrastar um cartão para dentro de outra seção
  também muda o grupo dele.
- **⋮ do topo** — exportar, importar, trazer os sistemas da Teccel de volta.

## Como instalar

- **Android / PC (Chrome, Edge):** o botão **⤓ Instalar** aparece sozinho no
  topo quando o navegador permite.
- **iPhone / iPad:** Compartilhar → *Adicionar à Tela de Início*. O iOS não
  oferece o botão automático.

## Onde ficam os atalhos

No próprio aparelho (`localStorage`), gravados pela página. **Não há login nem
banco de dados**: aqui não existe dado de ninguém, só endereço de site — o
mesmo que estaria nos favoritos do navegador. Login para guardar favorito seria
atrito sem ganho.

A troca é que a lista é *daquele* aparelho. Por isso existem:

- **Exportar / Importar** — leva a lista de um aparelho para outro num arquivo
  `.json`, e serve de backup. Importar junta com o que já existe e não repete
  endereço.
- **Lista de fábrica** — quem instala já encontra os sistemas da Teccel na
  tela, em vez de começar no vazio. Ela vale só na primeira abertura; depois
  manda o que estiver guardado. O menu ⋮ traz de volta a qualquer momento,
  acrescentando sem apagar o que a pessoa cadastrou.

Se o aparelho estiver com armazenamento cheio, ou em aba anônima, o app avisa
que o que foi mudado vale só até fechar — em vez de perder tudo em silêncio.

## Arquivos

| Arquivo | O que é |
|---|---|
| `index.html` | O app inteiro: tela, estilo e código |
| `manifest.webmanifest` | Nome, ícones e cores da instalação |
| `sw.js` | Service worker: instalação e funcionamento sem sinal |
| `icones/` | Ícones do app e o logo do cabeçalho |

Não tem build: é HTML, CSS e JavaScript direto, sem dependência externa além
da fonte Open Sans. Editar e publicar é `git commit` + `git push` — o GitHub
Pages republica sozinho em cerca de um minuto.

## Um detalhe de segurança

O endereço guardado passa por uma validação que aceita **só `http` e `https`**.
Um atalho `javascript:...` — vindo de um arquivo importado de outra pessoa, por
exemplo — rodaria código dentro do app no clique. E `new URL()` sozinho não
serve de validação: ele aceita `https://não é url` codificando os espaços, e
geraria um cartão que não abre lugar nenhum.
