linux-headless: bash git
linux-computer: linux-headless pico8

.PHONY: bash git pico8 nano local
bash:
	stow bash
git:
	stow git
pico8:
	mkdir -p ~/.lexaloffle/pico-8
	stow -t '${HOME}/.lexaloffle/pico-8' pico8
nano:
	stow nano
sdkman:
	stow sdkman
	mkdir -p ~/.sdkman/archives
	mkdir -p ~/.sdkman/candidates
	mkdir -p ~/.sdkman/tmp
