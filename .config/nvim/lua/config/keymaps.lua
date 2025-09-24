-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Open URL under cursor with xdg-open
vim.keymap.set("n", "gx", function()
  local url = vim.fn.expand("<cfile>")
  if url == "" then
    vim.notify("No URL under cursor", vim.log.levels.WARN)
    return
  end
  -- Allow localhost and proper schemes
  if not url:match("^%a[%w+.-]*:") and not url:match("^localhost") then
    url = "http://" .. url
  end
  vim.fn.jobstart({ "xdg-open", url }, { detach = true })
end, { desc = "Open URL under cursor" })

-- ~/.config/nvim/lua/config/keymaps.lua
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
    follow = true,
    find_command = {
      "fd",
      "--type",
      "f",
      "--hidden",
      "--no-ignore",
      "--no-ignore-parent",
      "--follow",
      "--exclude",
      ".git",
      "--exclude",
      "node_modules",
      "--exclude",
      ".next",
      "--exclude",
      "dist",
    },
  })
end, { desc = "Find files (dotfiles, exclude node_modules/.git)" })
