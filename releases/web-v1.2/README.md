# PokeRPG - Web build (v1.2)

Exportacao HTML5/WASM do jogo, gerada a partir do commit deste branch.

## Como rodar

Navegadores bloqueiam WASM/threads quando o `index.html` e aberto direto
como arquivo (`file://`), entao e preciso servir esta pasta por HTTP. A
forma mais simples:

```bash
cd releases/web-v1.2
python3 -m http.server 8000
```

Depois abra `http://localhost:8000/index.html` no navegador.

Qualquer outro servidor HTTP estatico (ex.: `npx serve`, extensao "Live
Server" do VS Code) tambem funciona - so nao abra o arquivo diretamente
pelo `file://`.
