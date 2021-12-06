#! /usr/bin/env sh

if [ ! -d "$HOME/.config/railroad" ]; then
	cp -rv /usr/local/lib/railroad/config/ "$HOME/.config/railroad"
fi

if [ ! -f "$HOME/.config/railroad/railroad-linux" ]; then
	cp /usr/local/lib/railroad/railroad-linux "$HOME/.config/railroad/railroad-linux"
fi

echo /usr/local/lib/railroad/railroad-linux -custom-path "$HOME/.config/railroad" $@

cd "$HOME/.config/railroad" && exit 1
"$HOME/.config/railroad/railroad-linux" -custom-path "$HOME/.config/railroad" $@