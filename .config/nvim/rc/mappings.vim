"----------------------------------------------------------------------------------------
" Cursor move
nnoremap j gj
nnoremap k gk
nnoremap g; g;zz
nnoremap g, g,zz

"----------------------------------------------------------------------------------------
" Copy, Paste, Cut
nnoremap Y y$
nnoremap ,p ]p
nnoremap x "_x

"----------------------------------------------------------------------------------------
" Window
nnoremap <Space>w <C-w>

"----------------------------------------------------------------------------------------
" Undo behavior
inoremap <CR> <C-g>u<CR>
inoremap <C-w> <C-g>u<C-w>
inoremap <C-u> <C-g>u<C-u>

"----------------------------------------------------------------------------------------
" Emacs style command mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <C-h> <BS>
cnoremap <C-d> <Del>

"----------------------------------------------------------------------------------------
" Emacs style insert mode
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-h> <BS>
inoremap <C-d> <Del>

"----------------------------------------------------------------------------------------
" [,] Moving
nnoremap [q  :cprevious<CR>
nnoremap ]q  :cnext<CR>
nnoremap [l  :lprevious<CR>
nnoremap ]l  :lnext<CR>
nnoremap [b  :bprevious<CR>
nnoremap ]b  :bnext<CR>
nnoremap [t  :tabprevious<CR>
nnoremap ]t  :tabnext<CR>

nnoremap H   :bprevious<CR>
nnoremap L   :bnext<CR>

"----------------------------------------------------------------------------------------
" Search
noremap * g*N
noremap # g#n
noremap g* *N
noremap g# #n

"----------------------------------------------------------------------------------------
" Terminal
tnoremap <silent><ESC> <C-\><C-n>

"----------------------------------------------------------------------------------------
" Misc
"ファイル全体の内容を+レジスタにヤンク
nnoremap <Space>y :%y<CR>

"ファイル保存
nnoremap ,w :w<CR>

"改行の挿入
nnoremap <Space><CR> i<CR><ESC>

"open buffer list
nnoremap ,b :ls<CR>:<C-u>b 
