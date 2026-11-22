#!/usr/bin/env sh
#
# link-user-dirs.sh
#
# Symlinks the standard home-directory folders (Downloads, Pictures, Videos,
# Music, Documents, Templates) plus a couple of personal ones (Projects,
# Work) to their real location under ~/pars, and points the matching
# XDG_*_DIR entries in ~/.config/user-dirs.dirs at the symlinked paths so
# XDG-aware apps (browsers, GTK/Qt file pickers) recognize them correctly.
#
# This assumes a machine where personal data lives on a separate mount under
# ~/pars (a symlink to /mnt/state/pars on the primary machine) rather than
# inside $HOME itself. On any machine without that layout, this is a no-op.
#
# Desktop and PublicShare are intentionally left alone — not symlinked, and
# their XDG entries are not touched.
#
# Safe to re-run: only replaces a target that doesn't exist yet or is an
# already-empty directory. Never touches a target with real content in it,
# and never touches a target that's already a symlink.

PARS="$HOME/pars"

if [ ! -d "$PARS" ]; then
    echo "link-user-dirs: $PARS not found, skipping (not this kind of machine)"
    exit 0
fi

link_one() {
    name=$1
    target=$2
    link="$HOME/$name"

    if [ -L "$link" ]; then
        echo "  $name: already a symlink, skipping"
        return
    fi

    if [ -d "$link" ]; then
        if [ -z "$(ls -A "$link" 2>/dev/null)" ]; then
            rmdir "$link"
        else
            echo "  $name: $link exists and has content, skipping (not touching real data)"
            return
        fi
    fi

    if [ ! -e "$target" ]; then
        echo "  $name: target $target does not exist, skipping"
        return
    fi

    ln -s "$target" "$link"
    echo "  $name -> $target"
}

echo "Linking user directories under \$HOME to \$HOME/pars..."
link_one Downloads  "$PARS/storage/downloads"
link_one Pictures   "$PARS/storage/pictures"
link_one Videos     "$PARS/storage/videos"
link_one Music      "$PARS/storage/music"
link_one Documents  "$PARS/storage/documents"
link_one Templates  "$PARS/resources/templates"
link_one Projects   "$PARS/projects"
link_one Work       "$PARS/areas/ai"

USER_DIRS_FILE="$HOME/.config/user-dirs.dirs"
if [ -f "$USER_DIRS_FILE" ]; then
    echo "Updating $USER_DIRS_FILE (leaving Desktop and PublicShare untouched)..."
    sed -i \
        -e 's|^XDG_DOWNLOAD_DIR=.*|XDG_DOWNLOAD_DIR="$HOME/Downloads"|' \
        -e 's|^XDG_PICTURES_DIR=.*|XDG_PICTURES_DIR="$HOME/Pictures"|' \
        -e 's|^XDG_VIDEOS_DIR=.*|XDG_VIDEOS_DIR="$HOME/Videos"|' \
        -e 's|^XDG_TEMPLATES_DIR=.*|XDG_TEMPLATES_DIR="$HOME/Templates"|' \
        -e 's|^XDG_MUSIC_DIR=.*|XDG_MUSIC_DIR="$HOME/Music"|' \
        -e 's|^XDG_DOCUMENTS_DIR=.*|XDG_DOCUMENTS_DIR="$HOME/Documents"|' \
        "$USER_DIRS_FILE"
fi

echo "Done linking user directories."
