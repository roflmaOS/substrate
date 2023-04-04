profile: default/linux/amd64/17.1/no-multilib/systemd/merged-usr
source_subpath: amd64/systemd/stage4-amd64-systemd-latest
portage_confdir: @REPO_DIR@/confdirs/livecd

livecd/packages:
	sys-apps/kexec-tools
	sys-apps/usbutils
	sys-boot/efibootmgr
	sys-fs/btrfs-progs
	sys-fs/dosfstools

livecd/depclean: yes
