Neovim
=============

Dependencies
-----------

* deno
* fortune-mod
* gcc
* npm
* python3
* python-neovim
* ripgrep
* jq (make)
* global (optional)
* python-pygments (optional)

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

install
-----------

```bash
./scripts/nvim-init
```
