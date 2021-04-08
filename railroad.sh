#! /usr/bin/env sh

if [ ! -d "$HOME/.config/railroad" ]; then
	cp -rv /usr/local/lib/railroad/config/ "$HOME/.config/railroad"
fi

if [ ! -f "$HOME/.config/railroad/railroad" ]; then
	cp /usr/local/lib/railroad/railroad "$HOME/.config/railroad/railroad"
fi

echo /usr/local/lib/railroad/railroad -custom-path "$HOME/.config/railroad" $@

cd "$HOME/.config/railroad"
"$HOME/.config/railroad/railroad" -custom-path "$HOME/.config/railroad" $@