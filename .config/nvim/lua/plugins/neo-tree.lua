return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- show filtered items dimmed
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = { ".git", "node_modules", ".next", "dist" },
        -- ensure .env is never hidden by patterns
        always_show = { ".env", ".env.*" },
        never_show = {}, -- make sure .env is not listed here
        never_show_by_pattern = {}, -- and not here either
      },
    },
  },
}
