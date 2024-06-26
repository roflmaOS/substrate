profile: default/linux/amd64/23.0/desktop/plasma/systemd
source_subpath: amd64/plasma/stage4-amd64-plasma-latest
portage_confdir: @REPO_DIR@/confdirs/livecd

livecd/use:
	ibus

livecd/packages:
	sys-apps/kexec-tools
	sys-apps/usbutils
	sys-boot/efibootmgr
	sys-fs/btrfs-progs
	sys-fs/dosfstools

livecd/depclean: yes
