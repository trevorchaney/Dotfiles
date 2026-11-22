#!/usr/bin/env bash
# check-stow.sh -- verify that the files stow manages are the symlinks stow
# would create. Read-only: it never changes anything.
#
#   ./check-stow.sh              packages install.sh stows in this session
#   ./check-stow.sh --all        every package in packages.sh
#   ./check-stow.sh kitty btop   only these packages
#   ./check-stow.sh -q           print problems only
#   ./check-stow.sh --target DIR check DIR instead of $HOME (for testing)
#
# Reports, per package:
#   missing link    nothing at the target (stow would create the link)
#   regular file    a real file where the link should be, and whether it is
#                   identical to the repo copy or has drifted from it
#   foreign link    a symlink that points somewhere outside this repo
#   other package   the target is already a link from a different package
#   broken link     a link into this repo whose file no longer exists
#
# Uses `stow -n` (simulate) with the same flags install.sh uses, so "OK" means
# running install.sh would change nothing. Exit status: 0 all OK, 1 problems.
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=packages.sh
. "$DOTFILES/packages.sh"

TARGET="$HOME"
QUIET=0
ALL=0
PACKAGES=()

while [ $# -gt 0 ]; do
    case "$1" in
        --all) ALL=1 ;;
        -q|--quiet) QUIET=1 ;;
        --target) shift; TARGET="${1:?--target needs a directory}" ;;
        -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*) echo "unknown option: $1" >&2; exit 2 ;;
        *) PACKAGES+=("$1") ;;
    esac
    shift
done
TARGET="$(cd "$TARGET" && pwd -P)" || exit 2

command -v stow >/dev/null 2>&1 || { echo "error: GNU Stow is not installed" >&2; exit 2; }

if [ ${#PACKAGES[@]} -eq 0 ]; then
    if [ $ALL -eq 1 ]; then read -ra PACKAGES <<< "$(all_packages | tr '\n' ' ')"
    else read -ra PACKAGES <<< "$(session_packages | tr '\n' ' ')"; fi
fi

if [ -t 1 ]; then RED=$'\e[31m'; YEL=$'\e[33m'; GRN=$'\e[32m'; DIM=$'\e[2m'; OFF=$'\e[0m'
else RED= YEL= GRN= DIM= OFF=; fi

# Show paths under $HOME as ~/...
show() { if [ "$TARGET" = "$(cd "$HOME" && pwd -P)" ]; then echo "~/$1"; else echo "$TARGET/$1"; fi; }

PROBLEMS=0
declare -A REPORTED=()

for pkg in "${PACKAGES[@]}"; do
    if [ ! -d "$DOTFILES/$pkg" ]; then
        echo "${RED}!!${OFF} $pkg: no such package in $DOTFILES"
        PROBLEMS=$((PROBLEMS + 1))
        continue
    fi
    flags="$(stow_flags "$pkg")"
    fix="stow $flags -d $DOTFILES -t $TARGET $pkg"
    fix="${fix//  / }"
    issues=()

    # 1. Ask stow what it would do (simulation only).
    while IFS= read -r line; do
        case "$line" in
            "LINK: "*)
                rel="${line#LINK: }"; rel="${rel%% => *}"
                issues+=("${YEL}missing link${OFF}   $(show "$rel")")
                ;;
            *"cannot stow "*" over existing target "*" since neither a link nor a directory"*)
                rel="${line#* over existing target }"; rel="${rel%% since neither*}"
                if cmp -s "$TARGET/$rel" "$DOTFILES/$pkg/$rel"; then
                    issues+=("${YEL}regular file${OFF}   $(show "$rel")  ${DIM}(same as repo copy: remove it, then restow)${OFF}")
                else
                    issues+=("${RED}regular file${OFF}   $(show "$rel")  ${DIM}(DIFFERS from repo: diff it, copy wanted changes into $pkg/$rel, then remove and restow)${OFF}")
                fi
                ;;
            *"existing target is neither a link nor a directory: "*)
                rel="${line##*directory: }"
                issues+=("${RED}regular file${OFF}   $(show "$rel")")
                ;;
            *"existing target is not owned by stow: "*)
                rel="${line##*not owned by stow: }"
                issues+=("${RED}foreign link${OFF}   $(show "$rel") -> $(readlink "$TARGET/$rel")")
                ;;
            *"existing target is stowed to a different package: "*)
                rel="${line##*different package: }"; owner="${rel#* => }"; rel="${rel%% => *}"
                owner="${owner##*/dotfiles/}"; owner="${owner%%/*}"
                issues+=("${RED}other package${OFF}  $(show "$rel") is linked from package '$owner'")
                ;;
            "MKDIR: "*|"WARNING"*|"All operations aborted"*|"") ;;
            *) issues+=("${RED}stow says${OFF}      ${line#  \* }") ;;
        esac
    done < <(stow -n -v $flags -d "$DOTFILES" -t "$TARGET" "$pkg" 2>&1)

    # 2. Broken links into this repo (stow does not report these). Scan every
    #    directory the package installs into, one level deep.
    while IFS= read -r dir; do
        [ -d "$TARGET/$dir" ] || continue
        while IFS= read -r link; do
            dest="$(readlink "$link")"
            [[ "$dest" = /* ]] || dest="$(dirname "$link")/$dest"
            dest="$(realpath -m "$dest")"
            case "$dest" in "$DOTFILES"/*) ;; *) continue ;; esac
            rel="${link#"$TARGET"/}"
            [ -n "${REPORTED[$rel]:-}" ] && continue
            REPORTED[$rel]=1
            issues+=("${RED}broken link${OFF}    $(show "$rel") -> ${dest#"$DOTFILES"/} ${DIM}(file gone from repo: remove the link)${OFF}")
        done < <(find "$TARGET/$dir" -maxdepth 1 -xtype l 2>/dev/null)
    done < <(cd "$DOTFILES/$pkg" && find . -mindepth 1 \( -type f -o -type l \) -not -name .stow-local-ignore -printf '%h\n' | sed 's#^\./\{0,1\}##' | sort -u | sed 's#^$#.#')

    if [ ${#issues[@]} -eq 0 ]; then
        [ $QUIET -eq 1 ] || printf '%s %s\n' "${GRN}ok${OFF}" "$pkg"
    else
        PROBLEMS=$((PROBLEMS + ${#issues[@]}))
        printf '%s %s %s\n' "${RED}!!${OFF}" "$pkg" "${DIM}(fix: $fix)${OFF}"
        printf '     %s\n' "${issues[@]}"
    fi
done

echo
if [ $PROBLEMS -eq 0 ]; then
    echo "${GRN}All ${#PACKAGES[@]} packages are correctly linked.${OFF}"
    exit 0
fi
echo "${RED}$PROBLEMS problem(s) found.${OFF} Nothing was changed."
exit 1
