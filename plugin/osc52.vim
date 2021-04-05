" https://blog.untan.xyz/neovim-tmuxnokuritsupubodolian-xi-osc-52
" https://qiita.com/gotchane/items/0e7e6e0d5c7fa9f55c1a
" NOTE: Could not copy over 5840 bytes. I don't know why.

if exists('g:loaded_osc52')
  finish
endif
let g:loaded_osc52 = 1

if !has('nvim')
  finish
endif

if (exists('$WAYLAND_DISPLAYD') && executable('wl-copy'))
  finish
endif

if (exists('$DISPLAY') && executable('xclip'))
      \   || (exists('$DISPLAY') && executable('xsel'))
  finish
endif

if (!exists('$SSH_CLIENT') && !exists('$SSH_TTY'))
  if !exists('$SSH_CONNECTION')
    finish
  endif
endif

if &clipboard !~# '\<unnamedplus\>'
  finish
endif

let s:max_bytes = 100000
let s:osc52_copy = {lines, regtype ->
      \ [
      \ execute('let s:buf = printf("\x1b]52;;%s\x1b\\", system("base64", join(lines, "\n")))'),
      \ strlen(string(s:buf)) > s:max_bytes ?
      \ execute('echoerr "[osc52.nvim] copy buffer is too large. Please reduce yanked buffer or use xclip or xsel"') :
      \ chansend(v:stderr, s:buf)
      \ ]}
let s:osc52_paste = {-> split(getreg('"'), '\n', 1)} " fallback

" neovim default tmux provider `:h provider-clipboard` can save tmux
" clipboard. But it does not copy to client(OSC52).
" So I always use this config
" if exists('$TMUX')
let g:clipboard = {
      \   'name': 'osc52',
      \   'copy': {
      \     '+': s:osc52_copy,
      \     '*': s:osc52_copy,
      \   },
      \   'paste': {
      \     '+': s:osc52_paste,
      \     '*': s:osc52_paste,
      \   },
      \   'cache_enabled': 1,
      \ }
" endif
