lua << EOF
if vim.g.neovide then
  vim.opt.guifont = "Fira Code,Noto Color Emoji,FiraCode Nerd Font,Hack Nerd Font:h12"
  vim.g.remember_window_size = true
  vim.g.remember_window_position = true

  vim.g.neovide_cursor_animation_length = 0.13
  vim.g.neovide_cursor_trail_size = 0.8
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_underline_automatic_scaling = true
  vim.g.neovide_theme = "auto"
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_input_ime = true
  vim.g.neovide_cursor_antialiasing = true

  local function toggleFullscreen()
    if vim.g.neovide_fullscreen == false then
      vim.g.neovide_fullscreen = true
    else
      vim.g.neovide_fullscreen = false
    end
  end

  vim.keymap.set("n", "<F11>", function()
    toggleFullscreen()
  end)
end
EOF
