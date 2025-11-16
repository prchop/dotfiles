## Option if Compile lynx from source

```sh
#!/bin/sh

export CFLAGS="-O2 -g -pipe -fstack-protector-strong -D_FORTIFY_SOURCE=2"

./configure \
	--with-ssl \
	--with-zlib \
	--with-bzlib \
	--enable-debug \
	--with-screen=ncursesw \
	--enable-ipv6 \
	--enable-nls \
	--enable-default-colors \
	--enable-externs
```
