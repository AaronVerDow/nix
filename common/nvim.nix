{ config, pkgs, ... }:
let
  # this doesn't work
  /*
  treesitter-kanata = pkgs.vimUtils.buildVimPlugin {
    name = "treesitter-kanata";
    src = pkgs.fetchFromGitHub {
      owner = "AaronVerDow";
      repo = "nvim-treesitter-kanata";
      rev = "41f738677cdf99d9bfa6b02c3f432e178548a510";
      hash = "sha256-t7+Q7c7vql21WEouDyT/zy6diW8+JPsoajmQ3oIKoDg=";
    };
  };
  */
in
{
  home.packages = with pkgs; [ 
    shellcheck
    typescript
    nodejs
    jdk
    jdt-language-server
    nixd
    harper # grammar checking
    python3
    graphviz # plantuml
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
	cinnamon-nvim # smooth scroll

        # nix
        nvim-treesitter-parsers.nix

	# prose
	goyo-vim	# minimal interface
	vim-pencil	# better word wrap
	limelight-vim	# highlight current editing block
	vim-markdown	# rough markdown preview
        nvim-lspconfig  # used for harper

	# shell
	coc-sh
	nvim-treesitter-parsers.bash
	vim-shellcheck

	# typescript
	typescript-tools-nvim
	plenary-nvim # required for typescript-tools

        # python
        coc-pyright
        nvim-treesitter-parsers.python

	# lazy java setup
	coc-java
	nvim-treesitter-parsers.java

        # plantuml
        plantuml-syntax
        plantuml-previewer-vim
        open-browser-vim # required for plantuml previewer

    ] ++ [ pkgs.openscad-preview ];
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

-- map shift-ctrl-c to yank to system buffer
vim.api.nvim_set_keymap('v', '<C-S-c>', '"+y', { noremap = true, silent = true })

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

require'lspconfig'.harper_ls.setup {
  settings = {
    ["harper-ls"] = {
      linters = {
        SpellCheck = false,
        AvoidCurses = false, -- not documented
      },
      markdown = {
        IgnoreLinkTitle = true,
        filetypes = { "markdown", "rmd" }, -- AI guess
      }
    }
  },
  autostart = false,
}

require('gitsigns').setup()
require('lualine').setup()
require("typescript-tools").setup {}
require('transparent').setup({})
---@class CinnamonOptions
require("cinnamon").setup {
    -- Disable the plugin
    disabled = false,

    keymaps = {
        -- Enable the provided 'basic' keymaps
        basic = true,
        -- Enable the provided 'extra' keymaps
        extra = true,
    },
    
    ---@class ScrollOptions
    options = {
        -- The scrolling mode
        -- `cursor`: animate cursor and window scrolling for any movement
        -- `window`: animate window scrolling ONLY when the cursor moves out of view
        mode = "window",

        -- Only animate scrolling if a count is provided
        count_only = false,

        -- Delay between each movement step (in ms)
        delay = 5,

        max_delta = {
            -- Maximum distance for line movements before scroll
            -- animation is skipped. Set to `false` to disable
            line = false,
            -- Maximum distance for column movements before scroll
            -- animation is skipped. Set to `false` to disable
            column = false,
            -- Maximum duration for a movement (in ms). Automatically scales the
            -- delay and step size
            time = 1000,
        },

        step_size = {
            -- Number of cursor/window lines moved per step
            vertical = 1,
            -- Number of cursor/window columns moved per step
            horizontal = 20,
        },

        -- Optional post-movement callback. Not called if the movement is interrupted
        callback = function() end,
    },
}

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.puml",
    callback = function()
        vim.cmd("PlantumlOpen")
    end,
})

    '';
    extraConfig = ''
colorscheme humanoid

function! s:goyo_enter()
  lua require('lualine').hide()
  set linebreak
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

let g:vim_markdown_folding_disabled = 1

let g:plantuml_previewer#viewer_path = "~/tmp/plantuml"

" Enter key for auto completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
    '';
  };

  home.file.".config/nvim/coc-settings.json" = {
    text = ''
      {
        "languageserver": {
            "nix": {
                "command": "nixd",
                "filetypes": ["nix"]
            }
        }
        "java.jdt.ls.java.home": "${pkgs.jdk}/lib/openjdk",
        "java.configuration.updateBuildConfiguration": "automatic",
        "java.import.gradle.enabled": true,
        "java.import.maven.enabled": true
      }
    '';
  };
}
