profile: default/linux/amd64/17.1/no-multilib/systemd/merged-usr
source_subpath: amd64/mergeusr/stage3-amd64-mergeusr-latest
portage_confdir: @REPO_DIR@/confdirs/base

stage4/packages:
	app-admin/ansible
	app-editors/vim
	app-eselect/eselect-repository
	app-shells/bash-completion
	dev-vcs/git
	net-firewall/nftables
	sys-apps/iproute2
	sys-devel/bc
	sys-kernel/dracut
	sys-process/htop

stage4/root_overlay: @REPO_DIR@/root_overlays/base

stage4/unmerge:
	app-editors/nano

stage4/empty:
	/var/cache/edb/dep