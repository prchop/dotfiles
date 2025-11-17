## Option if Compile lynx from source

```build
#!/bin/sh

export CFLAGS="-O2 -g -pipe -fstack-protector-strong -D_FORTIFY_SOURCE=2"

./configure \
	--prefix="$HOME/.local" \
	--bindir="$HOME/.local/bin" \
	--sysconfdir="$HOME/.config/lynx" \
	--datadir="$HOME/.local/share" \
	--mandir="$HOME/.local/share/man" \
	--with-ssl \
	--with-zlib \
	--with-screen=ncursesw \
	--enable-widec \
	--enable-ipv6 \
	--enable-nls \
	--enable-default-colors \
	--enable-color-style \
	--enable-persistent-cookies \
	--enable-externs
```

```
# 1. Make the script executable
chmod +x build

# 2. Run configure
./build

# 3. Compile
make

# 4. Install
make install
make install-help

# 5. Verify installation
ls -l ~/.local/bin/lynx
```
