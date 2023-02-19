local packer_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
  vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", packer_path})
  vim.cmd [[packadd packer.nvim]]
end

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  use "EdenEast/nightfox.nvim"
  use "gbprod/substitute.nvim"
  use { "kylechui/nvim-surround", tag = "*" }
  use { "nvim-lualine/lualine.nvim", requires = "nvim-tree/nvim-web-devicons" }
  use { "akinsho/bufferline.nvim", tag = "v3.*", requires = "nvim-tree/nvim-web-devicons" }
  use { "nvim-telescope/telescope.nvim", tag = "0.1.1", requires = "nvim-lua/plenary.nvim" }
end)

-- UI
if not vim.g.vscode then
  vim.opt.number = true
  vim.opt.shiftwidth = 2
  vim.opt.scrolloff = 6
  vim.opt.list = true
  vim.opt.listchars = { tab = ">-", trail = "-" }
  vim.opt.cursorline = true
  vim.opt.completeopt = "menuone"
  vim.opt.termguicolors = true
  vim.cmd("colorscheme duskfox")
  require("lualine").setup()
  require("bufferline").setup()
end

-- Behavior
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.timeout = false
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.wrap = false
vim.opt.shiftround = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true

-- Keymaps
require("substitute").setup()
require("nvim-surround").setup()
vim.keymap.set({"n", "v"}, "j", "gj", { noremap = true })
vim.keymap.set({"n", "v"}, "k", "gk", { noremap = true })
vim.keymap.set("v", "v", "$h", { noremap = true })
vim.keymap.set({"n", "v"}, "Y", "y$", { noremap = true })
vim.keymap.set("n", "s", require('substitute').operator)
vim.keymap.set("n", "ss", require('substitute').line)
vim.keymap.set("n", "S", require('substitute').eol)
vim.keymap.set("v", "s", require('substitute').visual)
vim.keymap.set({"n", "v"}, "n", "nzz", { noremap = true })
vim.keymap.set({"n", "v"}, "N", "Nzz", { noremap = true })
vim.g.mapleader = " "
vim.keymap.set({"n", "v"}, "<leader>h", "^", { noremap = true })
vim.keymap.set({"n", "v"}, "<leader>l", "$", { noremap = true })
vim.keymap.set({"n", "v"}, "<leader>j", "10j", { noremap = true })
vim.keymap.set({"n", "v"}, "<leader>k", "10k", { noremap = true })
vim.keymap.set("n", "<leader>/", "<Cmd>nohl<CR>")
vim.keymap.set("v", "<leader>y", "\"*y", { noremap = true })
if vim.g.vscode then
  vim.keymap.set("n", "<leader>p", "<Cmd>call VSCodeNotify('workbench.action.showCommands')<CR>")
  vim.keymap.set("n", "<leader>o", "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
  vim.keymap.set("n", "<leader>d", "<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>")
  vim.keymap.set("n", "<leader>t", "<Cmd>call VSCodeNotify('workbench.action.files.newUntitledFile')<CR>")
  vim.keymap.set("n", "<leader>w", "<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>")
  vim.keymap.set("n", "H", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
  vim.keymap.set("n", "L", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
else
  vim.keymap.set("n", "<leader>p", "\"*p", { noremap = true })
  vim.keymap.set("n", "<leader>o", function() require("telescope.builtin").find_files { hidden = true } end)
  vim.keymap.set("n", "<leader>r", function() require("telescope.builtin").live_grep { hidden = true } end)
  vim.keymap.set("n", "<leader>d", "<Cmd>bd<CR>")
  vim.keymap.set("n", "<leader>D", "<Cmd>bd!<CR>")
  vim.keymap.set("n", "<leader>t", "<Cmd>tabnew<CR>")
  vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>")
  vim.keymap.set("n", "H", "<Cmd>bp<CR>")
  vim.keymap.set("n", "L", "<Cmd>bn<CR>")
end

