# Console fonts

Run `shaddai` (or `shaddai-fonts`) on a Linux virtual console. It starts with
`Lat2-Terminus16.psfu.gz` when installed. Use `n`/`p` to browse, `/` to filter,
`d` for double size, and `h` for a five-page tour of the actual files and
commands. `shaddai --tutorial` also works in a desktop terminal or a pipe.

`q`, EOF, and handled signals restore the original font and Unicode map.
Enter keeps the preview and asks whether to save it for this numbered TTY,
all TTYs, or neither. Saving may ask for sudo authentication. A font belongs
to a console, so the choice applies to everyone using it.

`shaddai --default` installs and applies `Lat2-Terminus16.psfu.gz` as the
shared default without opening the chooser. It does not require a console
on stdin. This is also a simple child-process interface for initial setup.
Both executable names use the same implementation.

## Saved fonts are files

`/etc/consolefonts/shaddai/tty2.psf` controls `/dev/tty2`.
`/etc/consolefonts/shaddai/default.psf` is the fallback for consoles without
their own file. Saving a new shared default preserves TTY-specific choices.
The chooser saves the loaded glyphs and Unicode map, including double size,
so persistence does not depend on the original directory or package version.
A replaced choice is retained as `NAME.psf.previous`.

The small loader in `lib/shaddai/console-font` is copied to
`/usr/local/libexec/shaddai-console-font`. Two systemd drop-ins named
`90-shaddai-font.conf` call it after `systemd-vconsole-setup.service` and
before `getty@.service` login prompts (including the `autovt@` alias).
No login shell hook, daemon, or reference to this checkout is needed at boot.
The hooks append commands and do not replace the distro's setup commands.
Font failures are logged but never block a login prompt.

The boot hook visits allocated consoles via `/dev/vcsN`, rather than opening
every `/dev/ttyN` and allocating unused consoles. The getty hook covers later
allocations. Custom programs allocating a VT without getty can explicitly
call `sudo /usr/local/libexec/shaddai-console-font /dev/ttyN`.

The native configuration remains `/etc/vconsole.conf` on systemd systems;
on NixOS, `console.font` generates that file. Shaddai's saved choices load
after native setup, leaving the keymap and generated files intact. This
sets the font after the initramfs stage; it does not rebuild early boot images.
Persistence requires systemd. Temporary previewing still only requires kbd.

## Inspect and undo

```sh
systemctl cat systemd-vconsole-setup.service getty@tty2.service
cat /usr/local/libexec/shaddai-console-font
sudo rm /etc/consolefonts/shaddai/tty2.psf  # inherit the shared default
sudo rm /etc/consolefonts/shaddai/default.psf  # use the native default
sudo systemctl restart systemd-vconsole-setup.service
```

To remove the integration completely, remove both `90-shaddai-font.conf`
drop-ins and the installed loader, then run `sudo systemctl daemon-reload`.
To recover a replaced choice, copy its `.psf.previous` file over its `.psf`
file and run the loader. These operations never require the chooser.

Upstream references: [setfont source and manual](https://github.com/legionus/kbd),
[systemd console setup](https://www.freedesktop.org/software/systemd/man/latest/systemd-vconsole-setup.service.html),
[vconsole.conf](https://www.freedesktop.org/software/systemd/man/latest/vconsole.conf.html),
and [NixOS's console module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/console.nix).
