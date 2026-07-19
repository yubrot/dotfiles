-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Let nvim-tree handle directory buffers instead of the built-in netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
  "EdenEast/nightfox.nvim",
  "gbprod/substitute.nvim",
  "monaqa/dial.nvim",
  { "kylechui/nvim-surround", version = "*" },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "willothy/nvim-cokeline", dependencies = { "nvim-tree/nvim-web-devicons" } },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeOpen", "NvimTreeClose" },
    keys = {
      {
        "<leader>e",
        function()
          local tree_was_focused = vim.bo.filetype == "NvimTree"
          require("nvim-tree.api").tree.open()
          if tree_was_focused then vim.cmd("wincmd p") end
        end,
        desc = "Open nvim-tree / focus editor",
      },
      { "<leader>E", "<Cmd>NvimTreeClose<CR>", desc = "Close nvim-tree" },
    },
    opts = {
      view = { side = "left", width = 60 },
      renderer = {
        group_empty = true,
        highlight_git = "all",
        icons = {
          git_placement = "right_align",
          glyphs = { git = { unstaged = "○" } },
        },
        root_folder_label = function(path)
          local parts = vim.split(vim.fs.normalize(path), "/", { plain = true, trimempty = true })
          return table.concat(vim.list_slice(parts, math.max(1, #parts - 2)), "/")
        end,
      },
      git = { enable = true },
      diagnostics = { enable = true },
      update_focused_file = { enable = true, update_root = false },
    },
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },
  { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter/nvim-treesitter" } },
  { "sustech-data/wildfire.nvim", event = "VeryLazy", dependencies = { "nvim-treesitter/nvim-treesitter" } },
})

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
  require("cokeline").setup({
    components = {
      {
        text = function(buffer) return " " .. buffer.devicon.icon end,
        fg = function(buffer) return buffer.devicon.color end,
      },
      {
        text = function(buffer)
          if buffer.path == "" then return " " .. buffer.filename end
          local parent = vim.fn.fnamemodify(buffer.path, ":h:t")
          return (" %s/%s"):format(parent, buffer.filename)
        end,
        underline = function(buffer) return buffer.is_hovered and not buffer.is_focused end,
        truncation = { direction = "left" },
      },
      {
        text = function(buffer)
          if buffer.is_modified then return "*" end
          return ""
        end,
      },
      { text = " " },
    },
  })
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
local augend = require("dial.augend")
require("dial.config").augends:register_group{
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.constant.alias.bool,
    augend.semver.alias.semver,
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%Y-%m-%d"],
  },
}

-- Keymaps
require("substitute").setup()
require("nvim-treesitter.configs").setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["ad"] = "@block.outer",
        ["id"] = "@block.inner",
      }
    }
  }
}
require("nvim-surround").setup {
  surrounds = {
    ["d"] = {
      add = { "do ", " end" },
      find = function()
        local config = require("nvim-surround.config")
        return config.get_selection({ motion = "ad" })
      end,
      delete = "^(do ?)().-( ?end)()$",
    }
  }
}
require("wildfire").setup()
vim.keymap.set({"n", "v"}, "j", "gj", { noremap = true })
vim.keymap.set({"n", "v"}, "k", "gk", { noremap = true })
vim.keymap.set("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
vim.keymap.set("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
vim.keymap.set("v", "v", "$h", { noremap = true })
vim.keymap.set({"n", "v"}, "Y", "y$", { noremap = true })
vim.keymap.set("n", "s", require('substitute').operator)
vim.keymap.set("n", "ss", require('substitute').line)
vim.keymap.set("n", "S", require('substitute').eol)
vim.keymap.set("v", "s", require('substitute').visual)
vim.keymap.set({"n", "v"}, "n", "nzz", { noremap = true })
vim.keymap.set({"n", "v"}, "N", "Nzz", { noremap = true })
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
  vim.keymap.set("n", "<leader>d", "<Cmd>bp | bd #<CR>")
  vim.keymap.set("n", "<leader>D", "<Cmd>bp | bd! #<CR>")
  vim.keymap.set("n", "<leader>t", "<Cmd>tabnew<CR>")
  vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>")
  vim.keymap.set("n", "H", "<Cmd>bp<CR>")
  vim.keymap.set("n", "L", "<Cmd>bn<CR>")
end

-- It's unclear why, but tree-sitter-ruby requires an explicit `parse` call at least once.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function()
    local node = vim.treesitter.get_node()
    if node then return end

    local buf = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok or not parser then return end

    parser:parse()
  end
})
