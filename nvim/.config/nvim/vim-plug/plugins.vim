" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
    " File Explorer
    Plug 'francoiscabrol/ranger.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'jiangmiao/auto-pairs'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'gruvbox-community/gruvbox'
    Plug 'ThePrimeagen/vim-be-good'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'justinmk/vim-sneak'
" post install (yarn install | npm install) then load plugin only for editing supported files
    Plug 'prettier/vim-prettier', {
      \ 'do': 'npm install --frozen-lockfile --production',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
    Plug 'unblevable/quick-scope'
    Plug 'liuchengxu/vim-which-key'
Plug 'honza/vim-snippets'
    "nmap oo o<Esc>k (resp. nmap OO O<Esc>j

call plug#end()
