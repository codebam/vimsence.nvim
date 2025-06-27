<p align="center">
  <h1 align="center">VimSence</h1>
</p>

<p align="center">
  <img src="https://i.imgur.com/aL4g3nx.png" width="300">
  <img src="https://i.imgur.com/nrhZj4O.png" width="300">
</p>

## Getting Started
These instructions will get you a copy of the project up and running on your local machine.
More help about the plugin itself can be found [here](doc/vimsence.txt).

### Prerequisites
- **Neovim**: Requires Neovim 0.7+ with Lua support

### Installing
##### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'vimsence/vimsence',
  config = function()
    require('vimsence').setup()
  end
}
```

##### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'vimsence/vimsence',
  config = function()
    require('vimsence').setup()
  end
}
```

##### [vim-plug](https://github.com/junegunn/vim-plug)
Add to your `init.lua` or `init.vim`:
```vim
Plug 'vimsence/vimsence'
```

##### Other Plugin Managers
Use the same plugin specification: `'vimsence/vimsence'`

## Configuration

Configure VimSence using the `setup()` function:
```lua
require('vimsence').setup({
  client_id = '439476230543245312',
  small_text = 'Neovim',
  small_image = 'neovim',
  editing_details = 'Editing: {}',
  editing_state = 'Working on: {}',
  editing_large_text = 'Editing a {} file',
  file_explorer_text = 'In the file explorer',
  file_explorer_details = 'Looking for files',
  ignored_file_types = {'help', 'nerdtree'},
  ignored_directories = {'.git', 'node_modules'},
  custom_icons = {python = 'py', javascript = 'js'},
  discord_flatpak = false  -- Enable for Flatpak Discord on Linux
})
```

## Commands
- `:DiscordUpdatePresence` - Manually update Discord presence
- `:DiscordReconnect` - Reconnect to Discord
- `:DiscordDisconnect` - Disconnect from Discord

## Development

This plugin is written in Lua for Neovim. To develop:

1. Fork and clone the repository
2. Make changes to the Lua files in `lua/vimsence/`
3. Test with your Neovim configuration
4. Submit a pull request

## Authors
| Contributor                                                                                                                         | What has been done    |
|-------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| <img src="https://avatars.githubusercontent.com/anned20" height=30px align=center>   [Anne Douwe Bouma](https://github.com/anned20) | Original work         |
| <img src="https://avatars.githubusercontent.com/hugolgst" height=30px align=center>   [Hugo Lageneste](https://github.com/hugolgst) | Maintaining this fork |

See also the list of [contributors](https://github.com/vimsence/vimsence/contributors) who participated in this project.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
