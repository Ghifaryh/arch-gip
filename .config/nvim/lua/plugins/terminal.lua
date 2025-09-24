return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-`>]], -- VSCode style toggle
        direction = "float",
        shade_terminals = true,
      })

      -- Better keymaps inside terminal
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts) -- Esc to normal mode
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts) -- jk to normal mode
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
    },
  },
}
