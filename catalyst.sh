#!/bin/bash

set -eo pipefail

if which lsns 2>/dev/null >&2; then
	if test -z "$(lsns | awk "/$$/&&/mnt/")"; then
		echo re-executing in our own mount namespace
		exec unshare -m $0 $@
	fi
fi

date=${1:-$(date --date=yesterday +%Y%m%d)}
arch=${ARCH:-$(uname -m)}

BASE_DIR="$(dirname $(readlink -f $0))"
REPO_DIR=$BASE_DIR/weekly

catalyst_version=$( (catalyst -V || true) | awk 'NR==1{print$NF}')
case "$arch" in
x86_64)
	targets="${TARGETS:-systemd:stage1 systemd:stage2 systemd:stage3 router:stage4 systemd:stage4 sso:stage4}"
	upstream="amd64"
	sharedir="/usr/lib64/catalyst"
	;;
aarch64)
	targets="${TARGETS:-default:stage1}"
	upstream="arm64"
	sharedir="/usr/lib64/catalyst"
	;;
armv8l)
	cbuild="armv7a-hardfloat-linux-gnueabi"
	sharedir="/usr/lib64/catalyst"
	;& # fall through
armv7l)
	cflags="-O2 -mfloat-abi=hard -mfpu=vfpv3-d16"
	case "$(hostname)" in
	spring|daisy)
		cflags="$cflags -march=armv7ve -pipe"
		;;
	ella-*)
		cflags="$cflags -march=armv7-a -mcpu=cortex-a9 --param ggc-min-expand=0 --param ggc-min-heapsize=4096 -fno-inline"
		;;
	*)
		cflags="$cflags -march=armv7-a -mcpu=cortex-a9 -pipe"
	esac
	targets="${TARGETS:-hardfp:stage1 hardfp:stage2 hardfp:stage3 ella:stage4 hardfp:stage4}"
	upstream="armv7a"
	subarch="_hardfp"
	sharedir="${sharedir:-/usr/lib/catalyst}"
	;;
*)
	echo "Unknown architecture ARCH=$arch" >&2
	exit 1
	;;
esac
case $catalyst_version in
3.*)
	sharedir="/usr/share/catalyst"
	;;
esac

BUILDS_DIR=$BASE_DIR/builds/$upstream
tempstage=$(mktemp)
cataconf=$(mktemp)
envscript=$(mktemp)

cat $BASE_DIR/catalyst.conf > $cataconf
tee $envscript <<<"export MAKEOPTS=\"-j$(nproc)\""
tee -a $cataconf <<<"envscript=\"${envscript}\""
tee -a $cataconf <<<"sharedir=\"${sharedir}\""
tee -a $cataconf <<<"storedir=\"$BASE_DIR\""

catalyst="catalyst -c $cataconf"

if ! tar tvvf $(dirname $0)/snapshots/portage-$date.tar.bz2 >/dev/null; then
	if test x"$HISTORICAL" = "xyes"; then
		rm -f $(dirname $0)/snapshots/portage-$date.tar.bz2*
		wget -P $(dirname $0)/snapshots https://dev.gentoo.org/~swift/snapshots/portage-$date.tar.bz2
		wget -P $(dirname $0)/snapshots https://dev.gentoo.org/~swift/snapshots/portage-$date.tar.bz2.md5sum
	else
		rsync --no-motd --progress mirror.bytemark.co.uk::gentoo/snapshots/portage-$date.tar.bz2* $(dirname $0)/snapshots || true
	fi
	pushd $(dirname $0)/snapshots
		md5sum -c portage-$date.tar.bz2.md5sum
		chattr +i portage-$date.tar.bz2 || true
	popd
fi

for combo in $targets; do
	target=$(cut -d: -f1 <<<$combo)
	rel=${subarch:--$target}
	stage=$( cut -d: -f2 <<<$combo)

	# Skip a build if it already exists
	test -f $BUILDS_DIR/$target/$date/$stage-$upstream$rel-$date.tar.bz2 && continue

	# If a Makefile exists for the target, run the default target
	test -f $BUILDS_DIR/$target/Makefile && make -C $BUILDS_DIR/$target


	sed "s:@REPO_DIR@:$REPO_DIR:;s/@latest@/$date/" \
		$REPO_DIR/specs/$upstream/$target/$stage.spec | \
		tee $tempstage

	# add subarch and target
	tee -a $tempstage <<<"subarch: $upstream$subarch"
	tee -a $tempstage <<<"target: $stage"
	# append rel_type, version_stamp and snapshot
	tee -a $tempstage <<<"rel_type: $upstream/$target/$date"
	grep -q version_stamp: $tempstage || tee -a $tempstage <<<"version_stamp: $target-$date"
	tee -a $tempstage <<<"snapshot: $date"
	# append CHOST/CFLAGS to stage spec if set
	test -n "$chost" && tee -a $tempstage <<<"chost: $chost"
	(test -n "$cflags" && ! grep -q cflags: $tempstage) && tee -a $tempstage <<<"cflags: $cflags"

	$catalyst -f $tempstage | tee $BASE_DIR/logs/$stage-$upstream$rel-$date.log

	rm -f $BUILDS_DIR/$target/$stage-$upstream$rel-latest.tar.bz2
	(cd $BUILDS_DIR/$target && ln -s $date/$stage-$upstream$rel-$date.tar.bz2 $BUILDS_DIR/$target/$stage-$upstream$rel-latest.tar.bz2)
	tee $BUILDS_DIR/$target/latest-$stage-$upstream$rel.txt <<<"$date/$stage-$upstream$rel-$date.tar.bz2"
done
