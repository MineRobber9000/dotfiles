linux-headless: bash git nano local
linux-computer: linux-headless pico8

.PHONY: bash git pico8 nano local
bash:
	stow bash
git:
	stow git
pico8:
	mkdir ~/.lexaloffle/pico-8
	stow -t '${HOME}/.lexaloffle/pico-8' pico8
nano:
	stow nano
local:
	mkdir ~/.local
	stow -t '${HOME}/.local' local
