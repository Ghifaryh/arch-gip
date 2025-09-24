return {
  "nvim-telescope/telescope.nvim",
  opts = {
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = true,
        no_ignore_parent = true,
        follow = true,
      },
    },
  },
}
