linux: bash git

.PHONY: bash git pico8
bash:
	stow bash
git:
	stow git
pico8:
	mkdir ~/.lexaloffle/pico-8
	stow -t '${HOME}/.lexaloffle/pico-8' pico8
