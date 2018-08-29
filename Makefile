linux: bash git

.PHONY: bash git pico8
bash:
	stow bash
git:
	stow git
pico8:
	stow -t '$$HOME/.lexaloffle' pico8
