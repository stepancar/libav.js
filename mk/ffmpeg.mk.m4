changequote(`[[[', `]]]')

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

FFMPEG_VERSION=5.1.2

FFMPEG_CONFIG=--prefix=/opt/ffmpeg \
	--target-os=linux \
	--cc=emcc --ranlib=emranlib \
	--disable-doc \
	--disable-stripping \
	--disable-programs \
	--disable-ffplay --disable-ffprobe --disable-network --disable-iconv --disable-xlib \
	--disable-sdl2 \
	--disable-everything


build/ffmpeg-$(FFMPEG_VERSION)/build-%/libavformat/libavformat.a: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-%/ffbuild/config.mak
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$* ; $(MAKE)

# General build rule for any target
# Use: buildrule(target name, configure flags, CFLAGS)
define([[[buildrule]]], [[[
build/ffmpeg-$(FFMPEG_VERSION)/build-$1-%/ffbuild/config.mak: build/inst/$1/cflags.txt \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED configs/%/ffmpeg-config.txt
	test ! -e configs/$(*)/deps.txt || $(MAKE) `sed 's/@TARGET/$1/g' configs/$(*)/deps.txt`
	mkdir -p build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*) ; \
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*) ; \
	emconfigure env PKG_CONFIG_PATH="$(PWD)/build/inst/$1/lib/pkgconfig" \
		../configure $(FFMPEG_CONFIG) \
		$2 \
		--extra-cflags="-I$(PWD)/build/inst/$1/include $3" \
		--extra-ldflags="-L$(PWD)/build/inst/$1/lib $3" \
		`cat ../../../configs/$(*)/ffmpeg-config.txt`
	touch $(@)
]]])

# Base (asm.js and wasm)
buildrule(base, [[[--disable-pthreads --arch=emscripten]]], [[[]]])
# wasm + threads
buildrule(thr, [[[--arch=emscripten --enable-cross-compile]]], [[[-pthread]]])
# wasm + simd
buildrule(simd, [[[--disable-pthreads --arch=x86 --disable-inline-asm --disable-x86asm]]], [[[-msimd128]]])
# wasm + threads + simd
buildrule(thrsimd, [[[--arch=x86 --disable-inline-asm --disable-x86asm --enable-cross-compile]]], [[[-pthread -msimd128]]])

extract: build/ffmpeg-$(FFMPEG_VERSION)/PATCHED

build/ffmpeg-$(FFMPEG_VERSION)/PATCHED: build/ffmpeg-$(FFMPEG_VERSION)/configure
	cd build/ffmpeg-$(FFMPEG_VERSION) ; ( test -e PATCHED || patch -p1 -i ../../patches/ffmpeg.diff )
	touch $@

build/ffmpeg-$(FFMPEG_VERSION)/configure: build/ffmpeg-$(FFMPEG_VERSION).tar.xz
	cd build ; tar Jxf ffmpeg-$(FFMPEG_VERSION).tar.xz
	touch $@

build/ffmpeg-$(FFMPEG_VERSION).tar.xz:
	mkdir -p build
	curl https://ffmpeg.org/releases/ffmpeg-$(FFMPEG_VERSION).tar.xz -o $@

ffmpeg-release:
	cp build/ffmpeg-$(FFMPEG_VERSION).tar.xz libav.js-$(LIBAVJS_VERSION)/sources/

.PRECIOUS: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-simd-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-simd-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thrsimd-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thrsimd-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	build/ffmpeg-$(FFMPEG_VERSION)/configure
