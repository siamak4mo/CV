#!/bin/sh
#
# build script
#
SRC="cv.tex"
DEP=$(sed -ne "s/.usepackage.*{\(.*\)}.*/\1/p" $SRC | tr ',' '\n')
_MAIN_FARSI_FONT=$(sed -ne "s/.settextfont{\(.*\)}/\1/p" $SRC)
_MAIN_LATIN_FONT=$(sed -ne "s/.setlatintextfont{\(.*\)}/\1/p" $SRC)
_cache_file=".build.cache"

Y="echo yes"
N="echo no"

compile(){
    $TEXCC $SRC
}

# checking for cache
if [ -s $_cache_file ]; then
    TEXCC="$(cat $_cache_file)"
    [ ! -s $TEXCC ] && unset TEXCC
fi

# compile or configure
if [ -n "$TEXCC" ]; then
    compile
    exit 0
else
    echo "configure"
fi

check_font(){
    for _fnt in "Regular" "Italic" "Bold" "Bold Italic"; do
        echo -n "checking for font $1 ($_fnt)... "
        if [ -z "$(fc-list :family="$1" | grep "$_fnt" -o)" ]; then
            $N
            echo "Error -- first install '$1 ($_fnt)' font" >&2
            exit 1
        else
            $Y
        fi
    done
}

# check fonts
check_font "$_MAIN_FARSI_FONT"
check_font "$_MAIN_LATIN_FONT"

# check latex engine
echo -n "checking for latex engine... "
TEXCC=$(which xelatex)
if [ -z "$TEXCC" ]; then
    $N
    echo "Error -- xelatex engine not found" >&2
    exit 1
else
    $Y
    echo "using $TEXCC"
fi

# check dependencies
for _dep in $DEP; do
    echo -n "checking for latex package $_dep... "
    _pp=$(locate "$_dep.sty")
    if [ -z "$_pp" ]; then
        $N
        echo "Error -- first install $_dep.sty" >&2
        exit 1
    else
        $Y
        if [ -z "$(echo $_pp | grep '/texlive/[0-9]*/texmf-dist/' -o)" ]; then
            echo "Warning -- package $_dep.sty is unreachable for latex" >&2
        fi
    fi
done

# build
echo -n "make cache..."
echo $TEXCC > $_cache_file
$Y
compile
