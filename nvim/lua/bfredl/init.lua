-- logic: first_run, setup module and _G {{{
local first_run = not _G.bfredl
local bfredl = _G.bfredl or {}

if not first_run then
  require'plenary.reload'.reload_module'bfredl.'
end

do local status, err = pcall(vim.cmd, [[ runtime! autoload/bfredl.vim ]])
  if not status then
    vim.api.nvim_err_writeln(err)
  end
end

local function each(z)
  return (function (x) return x(x) end) (function (x) return function (y) z(y) return x(x) end end)
end

local h = bfredl

-- TODO(bfredl):: _G.h should be shorthand for the _last_ edited/reloaded .lua module
_G.h = bfredl
-- }}}
 -- packages {{{
local packer = require'packer'
packer.init {}
packer.reset()
do each (packer.use)
  -- 'norcalli/snippets.nvim'
  'L3MON4D3/LuaSnip'
  'norcalli/nvim-colorizer.lua'
  'vim-conf-live/pres.vim'
  --use 'norek/bbbork'


  'nvim-treesitter/nvim-treesitter'
  'nvim-treesitter/playground'

  'neovim/nvim-lspconfig'
  'jose-elias-alvarez/null-ls.nvim'

  {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}}
  {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
-- todo(packer): this should not be an error:
-- 'nvim-lua/plenary.nvim'

  '~/dev/nvim-miniyank'
  '~/dev/nvim-bufmngr'
  '~/dev/nvim-luadev'
  '~/dev/ibus-chords'
  '~/dev/nvim-ipy'
  '~/dev/nvim-test'
  '~/dev/vim-argclinic'
  '~/dev/nsync.nvim/'
  '~/dev/nvim-lanterna/'

  { '~/dev/nvim-miniluv/', rocks = 'openssl' }

  'mileszs/ack.vim'

  'phaazon/hop.nvim'
  'ggandor/leap.nvim'
  'justinmk/vim-sneak'
  'tommcdo/vim-exchange'

-- tpope section
  'tpope/vim-repeat'
  'tpope/vim-surround'
  'tpope/vim-fugitive'

  'lewis6991/gitsigns.nvim'
  'hotwatermorning/auto-git-diff'

  'vim-scripts/a.vim'
  {'folke/noice.nvim', requires ={'MunifTanjim/nui.nvim', "rcarriga/nvim-notify"}}

-- filetypes
  -- 'numirias/semshi'
  -- {'davidhalter/jedi-vim', ft = {'python'}}

  'ziglang/zig.vim'

  'JuliaEditorSupport/julia-vim'

  'lervag/vimtex'

-- them colors
  'morhetz/gruvbox'
  'eemed/sitruuna.vim'
end

vim.cmd [[ noremap ø :update<cr>:so $MYVIMRC<cr>:PackerUpdate<cr>  ]] -- <Plug>ch:,r

-- }}}
-- utils and API shortcuts {{{
for k,v in pairs(require'bfredl.util') do h[k] = v end
local a, buf, win, tabpage = h.a, h.buf, h.win, h.tabpage
_G.a = a

_G.__devcolors = not not (os.getenv'NVIM_DEV' and not os.getenv'NVIM_COLORDEV')

local v, set = vim.cmd, h.set
-- }}}
-- basic options {{{
'hidden'
'title'
'number'
'smartcase'
'ignorecase'
'expandtab'
'sw' (2)
'ts' (2)
'sts' (2)

'belloff' ""

'linebreak'

'incsearch'
'mouse' "a"
'updatetime' (1666)
'foldmethod' "marker"
'nomodeline'

'noshowmode'

'splitbelow'

'notimeout'
'ttimeout'
'ttimeoutlen' (10)

v 'set cpo-=_'
v 'set diffopt+=vertical'

if first_run then
  -- I liked this better:
  vim.o.dir = '.,'..vim.o.dir
end

-- }}}
-- them basic bindings {{{

-- CURRY NAM NAM, CURRY CURRY NAM NAM
function h.mapmode(mode)
  return function(lhs)
    return function(rhs)
      return a.set_keymap(mode, lhs, rhs, {})
    end
  end
end

local map = h.mapmode ''
local imap = h.mapmode 'i'
local chmap = function(x) return map('<Plug>ch:'..x) end
local CHmap = function(x) return map('<Plug>CH:'..x) end

-- test
chmap 'mw' '<cmd>lua print "HAJ!"<cr>'


-- TODO(bfredl): reload all the filetypes when reloading bfred/init.lua
v [[
  augroup bfredlft
    au FileType lua noremap <buffer> <Plug>ch:,l <cmd>update<cr><cmd>luafile %<cr>
  augroup END
]]

-- }}}
-- hop.nvim {{{
require'hop'.setup {
  keys = [[aoeipcrgljkwbmuhfqvxyzdtns]];
}
chmap 'jh' '<cmd>HopLineAC<cr>'
chmap 'kh' '<cmd>HopLineBC<cr>'
chmap 'jw' '<cmd>HopWordAC<cr>'
chmap 'kw' '<cmd>HopWordBC<cr>'
-- }}}
-- git signs {{{
require('gitsigns').setup {
   current_line_blame_formatter = '  <author_time:%Y-%m-%d> - <summary>, <author>',
}
chmap 'tn' '<cmd>Gitsigns next_hunk<cr>'
CHmap 'tn' '<cmd>Gitsigns prev_hunk<cr>'
chmap 'og' ':<c-u>Gitsigns toggle<c-z>'
-- }}}
-- vimenter stuff {{{
function h.vimenter(startup)
  if startup then
    require'colorizer'.setup()
    if a._fork_serve then
      _G.prepfork = true
       a._fork_serve()
      _G.postfork = true
       -- because reasons
       a._stupid_test()
    end
  end
end -- }}}
-- snippets {{{
vim.keymap.set({'i', 's'}, '<c-k>', "luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-k>'", {expr=true})
vim.keymap.set({'i', 's'}, '<c-j>', "luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<c-j>'", {expr=true})
require'bfredl.snippets'.setup()

do local ns = a.create_namespace 'selekt-color'
  a.set_hl(ns, "Visual", {bg='#006600'})
  local function on_win(_, winid, bufnr, row)
    if winid == a.get_current_win() and ({s=true,S=true,['']=true})[vim.fn.mode():sub(1,1)] then
      --(a._set_hl_ns or a.set_hl_ns)(ns)
    else
      --(a._set_hl_ns or a.set_hl_ns)(0)
    end
  end
  vim.api.nvim_set_decoration_provider(ns, {on_win=on_win})
end
-- }}}
-- LSP {{{
if not vim.g.bfredl_nolsp then
  local lspconfig = require'lspconfig'
  if vim.fn.executable('clangd') ~= 0 then
    lspconfig.clangd.setup {}
  end
  if vim.fn.executable('ra_lsp_server') ~= 0 then
    lspconfig.rust_analyzer.setup {}
  end
  if vim.fn.executable('zls') ~= 0 then
    -- lspconfig.zls.setup {}
  end
  if vim.fn.executable 'jedi-language-server' ~= 0 then
     lspconfig.pylsp.setup {}
  end

  if false then -- DISABLE
    require'null-ls'.config {
      sources = { require'null-ls'.builtins.diagnostics.zig_astcheck };
    }
    if lspconfig['null-ls'].setup then lspconfig['null-ls'].setup {} end
  end

end
vim.diagnostic.config {
  signs = false;
  update_in_insert = true;
}
-- }}}
-- tree sitter stuff {{{
function h.ts_setup()
  if os.getenv'NVIM_NOTS' then
    return
  end
  h.did_ts = true
  if true then require'nvim-treesitter.configs'.setup {
    --ensure_installed = "all",     -- one of "all", "language", or a list of languages
    highlight = {
      enable = true; -- false will disable the whole extension
    };
    incremental_selection = {
      enable = true;
      keymaps = {
        init_selection = "gnn";
        node_incremental = "gxn";
        scope_incremental = "grc";
        node_decremental = "grm";
      };
    };
    refactor = {
      highlight_definitions = { enable = true };
      --highlight_current_scope = { enable = false };
    };
    playground = {
      enable = true;
      disable = {};
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source cod;
      persist_queries = false; -- Whether the query persists across vim sessions
    };
  } end
  v [[
   " nmap <plug>ch:ht grn
  ]]
end
if true or h.did_ts then
  h.ts_setup()
end
-- }}}
-- telescope {{{
require'telescope'.setup {
  defaults = {
    winblend = 20;
    border = false;
  };
}
-- }}}
-- color {{{

local colors = require'bfredl.colors'
h.colors = colors
if os.getenv'NVIM_INSTANCE' then
  colors.defaults()
else
  v [[ hi EndOfBuffer guibg=#222222 guifg=#666666 ]]
  v [[ hi Folded guifg=#000000 ]]
end

function h.xcolor()
 local out = io.popen("xcolor"):read("*a")
 return vim.trim(out)
end
v 'inoremap <F3> <c-r>=v:lua.bfredl.init.xcolor()<cr>'
-- }}}
if os.getenv'NVIM_INSTANCE' then
  require'bfredl.miniline'.setup()
end
h.f = require'bfredl.floaty'.f
_G.f = h.f -- HAIII
-- autocmds {{{
v [[
  augroup bfredlua
  augroup END
]]
-- }}}
if os.getenv'NVIM_INSTANCE' and not __devcolors then
  v [[ color sitruuna_bfredl ]]
end
v [[ hi MsgArea blend=15 guibg=#281811]]
return bfredl
