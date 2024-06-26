source_subpath: amd64/plasma/livecd-stage1-amd64-plasma-latest

boot/kernel: gentoo

livecd/cdtar: @REPO_DIR@/../builds/amd64/plasma/@latest@/livecd-stage2-amd64-plasma-@latest@.tar.bz2
livecd/fstype: squashfs
livecd/fsscript: @REPO_DIR@/fsscripts/livecd
livecd/fsops: -comp xz -Xbcj x86
livecd/iso: roflmaOS-plasma-@latest@.iso
livecd/verify: yes
livecd/volid: roflmaOS amd64 plasma @latest@

livecd/root_overlay:
	@REPO_DIR@/root_overlays/livecd
	@REPO_DIR@/root_overlays/repart.d/livecd
