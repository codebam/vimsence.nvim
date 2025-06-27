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
- **Vim**: Requires Python 3 support
- **Neovim**: Requires Neovim 0.7+ with Lua support

### Installing

#### For Vim (Python Version)
##### [Vim-Plug](https://github.com/junegunn/vim-plug)
1. Add `Plug 'vimsence/vimsence'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:PlugInstall`

##### [Vundle](https://github.com/VundleVim/Vundle.vim) or similar
1. Add `Plugin 'vimsence/vimsence'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:BundleInstall`

#### For Neovim (Lua Version)
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

##### Other Plugin Managers
Follow the same pattern as Vim installation methods above.

## Configuration

### For Vim (VimScript)
You can configure VimSence in your `.vimrc` with these options:
```vim
let g:vimsence_client_id = '439476230543245312'
let g:vimsence_small_text = 'Vim'
let g:vimsence_small_image = 'vim'
let g:vimsence_editing_details = 'Editing: {}'
let g:vimsence_editing_state = 'Working on: {}'
let g:vimsence_editing_large_text = 'Editing a {} file'
let g:vimsence_file_explorer_text = 'In the file explorer'
let g:vimsence_file_explorer_details = 'Looking for files'
let g:vimsence_ignored_file_types = ['help', 'nerdtree']
let g:vimsence_ignored_directories = ['.git', 'node_modules']
let g:vimsence_custom_icons = {'python': 'py', 'javascript': 'js'}
let g:vimsence_discord_flatpak = 0  " Enable for Flatpak Discord on Linux
```

### For Neovim (Lua)
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
First create a virtual environment.
If you don’t already have a preferred way to do this,
take some time to look at tools like pew, virtualfish, and virtualenvwrapper.

Install the development dependencies:
```sh
pip install -r requirements-dev.txt
```

To avoid committing code that violates our style guide, we strongly advise you to install [pre-commit](https://pre-commit.com/) hooks:
```sh
pre-commit install
```

You can also run them anytime using:
```sh
pre-commit run --all-files
```

## Authors
| Contributor                                                                                                                         | What has been done    |
|-------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| <img src="https://avatars.githubusercontent.com/anned20" height=30px align=center>   [Anne Douwe Bouma](https://github.com/anned20) | Original work         |
| <img src="https://avatars.githubusercontent.com/hugolgst" height=30px align=center>   [Hugo Lageneste](https://github.com/hugolgst) | Maintaining this fork |

See also the list of [contributors](https://github.com/vimsence/vimsence/contributors) who participated in this project.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
