# Zen.nvim

A minimal Neovim plugin for distraction-free coding. It creates a centered floating window with customizable width, height, and z-index, hiding UI elements and focusing your attention.

## Features

- Centered floating window for the current buffer
- Customizable width, height, and z-index
- Background dimming
- Toggle Zen mode on/off
- Works with Neovim 0.5+ (requires floating window zindex support)

## Installation

With [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Raist90/zen.nvim",
  name = "Zen",
  event = "BufEnter",
  config = function()
    require("zen").setup({
      window = {
        width = 120,
        height = 1,
      },
      zindex = 40,
    })

    vim.keymap.set("n", "<leader>Z", function()
      require("zen").toggle()
    end, { desc = "Toggle Zen Mode" })
  end,
}
```

## Usage

- Press `<leader>Z` in normal mode to toggle Zen mode.
- Customize `width`, `height`, and `zindex` in the setup function.

## API

- `require("zen").setup(opts)` — Configure Zen mode.
- `require("zen").toggle()` — Toggle Zen mode.
- `require("zen").open(opts)` — Open Zen mode.
- `require("zen").close()` — Close Zen mode.

## Options

```lua
{
  window = {
    width = 120,   -- or a function returning a number
    height = 1,    -- or a function returning a number
  },
  zindex = 40,
}
```

## Requirements

- Neovim 0.5+ (May 2021 or newer, for floating window zindex support)

## License

MIT
```

You can adjust the installation path and keymap as needed.

