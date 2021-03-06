#
#  By Duzy Chan <code@duzy.info>, 2012, 2013
#  
function get-pkg-info()
{
    dpkg -l $1 | grep $1 | awk '{ print $2 " " $3; }'
}

function install-prerequisite()
{
    local pkg=$1
    #local pkginfo=$(get-pkg-info $pkg)
    #if [[ "x$pkginfo" == "x" ]]; then
    printf "install $pkginfo..\n"
    sudo apt-get install $pkg
    #else
    #printf "package $pkg is ok\n"
    #fi
}

function install-git-libvpx()
{
    local back=$PWD
    local root=$(gst-root)
    local stage=$(gst-stage)

    cd $root
    clone-project http://git.chromium.org/webm libvpx .git

    cd libvpx && git checkout v1.2.0 && \
	./configure --prefix="$stage" \
	--enable-shared --enable-vp8

    make clean || true
    make ${options[make-args]} && make ${options[make-args]} install

    cd $back

    if [[ "x$USER" != "xduzy" ]]; then
	sudo ln -svf $stage/lib/pkgconfig/vpx.pc /usr/lib/pkgconfig
    fi
}

function prepare-prerequisites()
{
    for name in \
	autoconf \
	automake \
	autopoint \
	libbz2-dev \
	libdv4-dev \
	libfaac-dev \
	libfaad-dev \
	libgtk-3-dev \
	libmjpegtools-dev \
	libtag1-dev \
	libtool \
	libtoolize \
	libvpx-dev \
	pkg-config \
	zlib1g-dev \
	gtk-doc-tools \
	yasm \
	bison \
	flex \
	;
    do
	install-prerequisite $name
    done
}

function goto-gst-root()
{
    local gstroot=$(gst-root)
    mkdir -p $gstroot
    cd $gstroot
}

function clone-project()
{
    local reporoot=$1
    local project=$2
    local suffix=$3
    local depth=1
    local DEPTH="--depth=$depth"
    local repo="$reporoot/$project$suffix"

    DEPTH=

    if [[ -d $project/.git ]]; then
	cd $project || {
	    exit -1
	}
	echo "Update $project..."
	git pull $DEPTH
	cd - > /dev/null
    else
	rm -rf $project
	#echo "Clone $project..."
	git clone $DEPTH $repo
    fi
}

function clone-duzy-project()
{
    clone-project https://github.com/duzy $1 .git
}

function clone-gst-project()
{
    clone-project git://anongit.freedesktop.org/gstreamer $1
}

function update-gst-projects()
{
    for name in $@; do
	if [[ -d $name ]]; then
	    cd $name || { exit -1 }
	    git update
	    cd - > /dev/null
	else
	    clone-$where-project $name -b $branch
	fi
    done
}

function parse-options()
{
    declare -A options
    local args=( "$@" )
    for ((n=0; n < ${#args[@]}; ++n)); do
	arg="${args[$n]}"
	case $arg in
	    --force|-f)
		options[force]="yes"
		;;
	    --make-args)
		((++n))
		options[make-args]="${args[$n]}"
		;;
	esac
    done
    for k in ${!options[@]}; do
	printf "[$k]=\"${options[$k]}\" "
    done
}

function main()
{
    declare -A options="( $(parse-options $@) )"
    local back=$PWD
    local stage=$(gst-stage)
    local where=duzy
    local branch=speakertrack

    #prepare-prerequisites

    goto-gst-root && update-gst-projects \
	gstreamer \
	gst-plugins-base \
	gst-plugins-good \
	gst-plugins-bad \
	gst-plugins-ugly
}
