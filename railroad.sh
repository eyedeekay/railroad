#! /usr/bin/env sh

if [ ! -d "$HOME/.config/railroad" ]; then
	cp -rv /usr/local/lib/railroad/config/ "$HOME/.config/railroad"
fi

/usr/local/lib/railroad/railroad -custom-path "$HOME/.config/railroad"