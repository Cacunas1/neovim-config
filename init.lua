-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.expandtab = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes"

if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.o.guifont = "Source Code Pro:h12"
    vim.g.neovide_transparency = 0.95
end
-------------------------------------------------------------------------------
-- Keymap
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fd", vim.cmd.Ex, {desc = "Find Directory"})
vim.keymap.set("n", "<leader>fs", "<cmd>write<cr>", {desc = "File Save"})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>y", "\"+y", {desc = "Yank to system clipboard"})
vim.keymap.set("v", "<leader>y", "\"+y", {desc = "Yank to system clipboard"})
vim.keymap.set("n", "<leader>Y", "\"+Y", {desc = "Yank to system clipboard"})

-------------------------------------------------------------------------------
-- Bootstrap Package Manager
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
-------------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------------
require("lazy").setup({
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    { "folke/neoconf.nvim", cmd = "Neoconf" },
    "folke/neodev.nvim",
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function () 
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "rust", "python" },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },  
            })
        end
    },
    "nvim-treesitter/playground",
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "ThePrimeagen/harpoon",
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

            vim.keymap.set("n", "<C-h>", function () ui.nav_file(1) end)
            vim.keymap.set("n", "<C-t>", function () ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function () ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function () ui.nav_file(4) end)
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git, {desc = "Git Status"});
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        lazy = true,
        config = function()
            -- This is where you modify the settings for lsp-zero
            -- Note: autocompletion settings will not take effect

            require('lsp-zero.settings').preset({})
        end
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            {'L3MON4D3/LuaSnip'},
        },
        config = function()
            -- Here is where you configure the autocompletion settings.
            -- The arguments for .extend() have the same shape as `manage_nvim_cmp`: 
            -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp

            require('lsp-zero.cmp').extend()

            -- And you can configure cmp even more, if you want to.
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local luasnip = require("luasnip")
            local cmp = require('cmp')
            local cmp_action = require('lsp-zero.cmp').action()

            cmp.setup({
                mapping = {
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
                            -- they way you will only jump inside the snippet region
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = {
                    { name = "path" },
                    { name = "nvim_lsp", keyword_length = 3 },
                    { name = "nvim_lsp_signature_help" },
                    { name = "nvim_lua", keyword_length = 2 },
                    { name = "buffer", keyword_length = 2 },
                    { name = "vsnip", keyword_length = 2 },
                    { name = "calc" },
                    { name = "crates" },
                },
            })
        end
    },

    -- LSP
    {"williamboman/nvim-lsp-installer"},
    {
        'neovim/nvim-lspconfig',
        cmd = 'LspInfo',
        event = {'BufReadPre', 'BufNewFile'},
        dependencies = {
            {'hrsh7th/cmp-nvim-lsp'},
            {'williamboman/mason-lspconfig.nvim'},
            {
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.api.nvim_command, 'MasonUpdate')
                end,
            },
        },
        config = function()
            -- This is where all the LSP shenanigans will live

            local lsp = require('lsp-zero')

            lsp.on_attach(function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp.default_keymaps({buffer = bufnr})
            end)

            -- (Optional) Configure lua language server for neovim
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

            lsp.setup()

            local on_attach = require("lspconfig").on_attach
            local capabilities = require("lspconfig").capabilities
            local lspconfig = require("lspconfig")
            local util = require "lspconfig/util"
        end
    },
    "vim-airline/vim-airline",
    "vim-airline/vim-airline-themes",
    {
        "saecki/crates.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('crates').setup()
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },
    {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = "neovim/nvim-lspconfig",
        opts = function()
            local on_attach = require("lspconfig").on_attach
            local capabilities = require("lspconfig").capabilities

            local options = {
                server = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                }
            }
            return options
        end,
        config = function(_, opts)
            require('rust-tools').setupt(opts)
        end
    },
})
-------------------------------------------------------------------------------
--- More Options
-------------------------------------------------------------------------------
vim.cmd.colorscheme "catppuccin"

