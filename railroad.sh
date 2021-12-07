#! /usr/bin/env sh

if [ ! -d "$HOME/.config/railroad" ]; then
	cp -rv /var/lib/$(REPO_NAME)/config/ "$HOME/.config/railroad"
fi

if [ ! -f "$HOME/.config/railroad/railroad-linux" ]; then
	cp /var/lib/$(REPO_NAME)/railroad-linux "$HOME/.config/railroad/railroad-linux"
fi

echo /var/lib/$(REPO_NAME)/railroad-linux -custom-path "$HOME/.config/railroad" $@

cd "$HOME/.config/railroad" && exit 1
"$HOME/.config/railroad/railroad-linux" -custom-path "$HOME/.config/railroad" $@