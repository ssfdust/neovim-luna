Neovim
=============

Dependencies
-----------

* deno
* npm
* python3
* python-neovim
* ripgrep
* jq (make, headless-install script requires)
* fortune-mod (optional, startup message)
* gcc (optional, treesitter support)
* global (optional, gtags support)
* python-pygments (optional, gtags support)

### Deno

`ddp.vim` and `ddu.vim` depens on `deno`, a javascript runtime. You can install it via your package manager or the following command.
```
curl -fsSL https://deno.land/x/install/install.sh | sh -s -- -y
```

### gtags

For gtags to work, you need to edit `gtags.conf`. Usually it locates at `/usr/share/gtags/gtags.conf` or `/etc/gtags.conf`. Ensure all the `ctagscom` refers to the right location for ctags in your system.

Then, you need to export the following environments `GTAGSCONF` and `GTAGSLABEL`. Add the following code to your `~/.bashrc`

```bash
export GTAGSLABEL=pygments
export GTAGSCONF=/path/to/gtags.conf
```

Install
-----------

```
git clone https://codeberg.org/ssfdust/neovim-lua.git ~/.config/nvim
```

#### Automatic Initilization

```bash
bash ~/.config/nvim/scripts/headless-install
```

#### Manually

##### First time startup

It will initilize dpp configuration at ~/.local/sahre/nvim/dpp

```
nvim +'autocmd User Dpp:makeStatePost qall'
```

##### Install Plugins during the second start

Start neovim with the denops server, then call 

```
nvim +"call denops#server#start()"
```

Manually install plugins in neovim

```
:call dpp#async_ext_action('installer', 'install')
```

Restart neovim
