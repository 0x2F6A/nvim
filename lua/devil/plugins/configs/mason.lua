local options = {
  ensure_installed = { "lua-language-server" }, -- not an option from mason.nvim

  -- Whether to automatically check for new versions when opening the :Mason window.
  check_outdated_packages_on_open = true,

  -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
  border = "rounded",

  -- Width of the window. Accepts:
  -- - Integer greater than 1 for fixed width.
  -- - Float in the range of 0-1 for a percentage of screen width.
  width = 0.8,

  -- Height of the window. Accepts:
  -- - Integer greater than 1 for fixed height.
  -- - Float in the range of 0-1 for a percentage of screen height.
  height = 0.9,

  ui = {
    icons = {
      package_pending = " ",
      package_installed = "󰄳 ",
      package_uninstalled = " 󰚌",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 3,
}

return options
