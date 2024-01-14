#!/bin/sh
#
# build script
#
SRC="cv.tex"
DEP="xepersian geometry titling hyperref multicol titlesec tasks"
_MAIN_FARSI_FONT="Yas"
_MAIN_LATIN_FONT="Noto Serif"
_cache_file=".build.cache"

echo -n "checking for cache... "
if [ -s $_cache_file ]; then
    echo "yes"
    $(cat $_cache_file) $SRC
    exit 0
else
    echo "no"
    echo "configure"
fi

check_font(){
    for _fnt in "Regular" "Italic" "Bold" "Bold Italic"; do
        echo -n "checking for $1 ($_fnt)... "
        if [ -z "$(fc-list :family="$1" | grep "$_fnt" -o)" ]; then
            echo "no"
            echo "Error -- first install '$1 ($_fnt)' font" >&2
            exit 1
        else
            echo "yes"
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
    echo "no"
    echo "Error -- xelatex engine not found" >&2
    exit 1
else
    echo "yes"
    echo "using $TEXCC"
fi

# check dependencies
for _dep in $DEP; do
    echo -n "checking for latex package $_dep... "
    _pp=$(locate "$_dep.sty")
    if [ -z "$_pp" ]; then
        echo "no"
        echo "Error -- first install $_dep.sty" >&2
        exit 1
    else
        echo "yes"
        if [ -z "$(echo $_pp | grep '/texlive/[0-9]*/texmf-dist/' -o)" ]; then
            echo "Warning -- package $_dep.sty is unreachable for latex" >&2
        fi
    fi
done

# build
echo $TEXCC >> $_cache_file
$TEXCC $SRC
