{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ 
    shellcheck
    typescript
    nodejs
    jdk
    jdt-language-server
  ];
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
	vim-sleuth # auto detect tab stop
	coc-nvim
	rainbow-delimiters-nvim
	nvim-treesitter
	gitsigns-nvim
	lualine-nvim
	vim-humanoid-colorscheme
	transparent-nvim
	neoscroll-nvim

	# prose
	goyo-vim	# minimal interface
	vim-pencil	# better word wrap
	limelight-vim	# highlight current editing block
	vim-markdown	# rough markdown preview

	# shell
	coc-sh
	nvim-treesitter-parsers.bash
	vim-shellcheck

	# typescript
	typescript-tools-nvim
	plenary-nvim # required for typescript-tools

	# lazy java setup
	coc-java
	nvim-treesitter-parsers.java
    ];
    extraLuaConfig = ''
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

-- Make line numbers default
-- vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- https://github.com/HiPhish/rainbow-delimiters.nvim/issues/2
-- ChatGPT suggested the delay and it worked.
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.defer_fn(function()
            vim.cmd("TSBufEnable highlight")
        end, 100) -- Delay by 100 milliseconds
    end,
})

require('gitsigns').setup()
require('lualine').setup()
require("typescript-tools").setup {}
require('transparent').setup({})

    '';
    extraConfig = ''
colorscheme humanoid

function! s:goyo_enter()
  lua require('lualine').hide()
  set linebreak
  set spell spelllang=en_us
  Pencil
  
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

  set conceallevel=0 "do not hide quotes in markdown
  set mouse=
  call coc#rpc#stop()
  set noshowmode " hide --INSERT-- at bottom

  augroup cmdline
    autocmd!
    autocmd CmdlineLeave : lua vim.defer_fn(function() vim.cmd('echo ""') end, 5000)
  augroup END

endfunction

function! s:goyo_leave()
  lua require('lualine').hide({unhide=true})
  set nolinebreak
  set nospell
  NoPencil
  CocStart
  set showmode

  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

au FileType * if exists('$LOCAL_VIMRC') | call LoadLvimrc() | endif

function LoadLvimrc()
    let b:localrc_files = get(b:, 'localrc_files', [])
    let b:localrc_loaded = get(b:, 'localrc_loaded', 0)
    let l:lvimrcs = $LOCAL_VIMRC
    if empty(l:lvimrcs) | return | endif
    for l:file in split(l:lvimrcs, ':')
        if index(b:localrc_files, l:file) == -1
            source `=l:file`
            let b:localrc_loaded += 1
            let b:localrc_files += [l:file]
        endif
    endfor
endfunction

" Enter key for auto completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
    '';
  };

  home.file.".config/nvim/coc-settings.json" = {
    text = ''
      {
        "java.jdt.ls.java.home": "${pkgs.jdk}/lib/openjdk",
        "java.configuration.updateBuildConfiguration": "automatic",
        "java.import.gradle.enabled": true,
        "java.import.maven.enabled": true
      }
    '';
  };
}
