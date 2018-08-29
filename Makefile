linux-headless: bash git nano
linux-computer: linux-headless pico8

.PHONY: bash git pico8 nano
bash:
	stow bash
git:
	stow git
pico8:
	mkdir ~/.lexaloffle/pico-8
	stow -t '${HOME}/.lexaloffle/pico-8' pico8
nano:
	stow nano
