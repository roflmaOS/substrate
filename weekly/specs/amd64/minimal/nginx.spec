profile: default/linux/amd64/17.1/systemd
source_subpath: amd64/systemd/stage3-amd64-systemd-latest
target: embedded

embedded/packages:
	app-editors/vim
	www-servers/nginx[rtmp,vim-syntax]