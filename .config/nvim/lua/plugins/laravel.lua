-- lua/plugins/laravel.lua
return {
  {
    "adalessa/laravel.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "nvim-neotest/nvim-nio", -- ← required
      "nvim-lua/plenary.nvim", -- (telescope brings this, but safe to list)
    },
    opts = {}, -- your laravel.nvim opts
  },
  { "jwalton512/vim-blade", ft = { "blade" } },
}
