profile: default/linux/amd64/17.1/desktop/plasma/systemd/merged-usr
source_subpath: amd64/plasma/stage4-amd64-plasma-latest
portage_confdir: @REPO_DIR@/confdirs/amd64/plasma/duet

livecd/use:
	ibus
	pulseaudio
	vaapi

livecd/packages:
	app-admin/pass-otp
	app-admin/sysstat
	app-crypt/efitools
	app-crypt/sbsigntools
	app-crypt/tpm2-totp
	app-crypt/tpm2-tss-engine
	app-office/abiword
	dev-libs/intel-compute-runtime
	dev-texlive/texlive-latexextra
	kde-apps/ffmpegthumbs
	mail-client/thunderbird
	media-gfx/zbar
	media-libs/libva-intel-media-driver
	media-libs/vulkan-loader
	media-video/mpv
	net-analyzer/vnstat
	net-dialup/xl2tpd
	net-im/gajim
	net-im/signal-desktop-bin
	net-irc/quassel
	net-misc/yt-dlp
	net-voip/mumble
	sys-apps/kexec-tools
	sys-apps/usbutils
	sys-boot/efibootmgr
	sys-firmware/intel-microcode
	sys-fs/btrfs-progs
	sys-fs/dosfstools
	sys-fs/fuse-exfat
	sys-kernel/linux-firmware
	x11-drivers/xf86-video-intel
	x11-misc/zim

livecd/depclean: yes
