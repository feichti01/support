#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
legacy_origin="https://feichti01.github.io/support"
target_origin="https://feichti01.github.io/gasblender/support"

assert_redirect() {
    local file=$1
    local target=$2

    [[ "$target" == https://* ]] || {
        printf 'Redirect target must use HTTPS: %s\n' "$target" >&2
        exit 1
    }
    [[ "$target" != "$legacy_origin"* ]] || {
        printf 'Redirect target loops to the legacy origin: %s\n' "$target" >&2
        exit 1
    }
    grep -Fq "<meta http-equiv=\"refresh\" content=\"0;url=$target\">" \
        "$repository_root/$file"
    grep -Fq "<link rel=\"canonical\" href=\"$target\">" \
        "$repository_root/$file"
}

assert_redirect privacy.html "$target_origin/privacy.html"
assert_redirect printer-compatibility.html "$target_origin/printer-compatibility.html"

grep -Fq '<link rel="canonical" href="https://feichti01.github.io/support/">' \
    "$repository_root/index.html"
if grep -Fiq '<meta http-equiv="refresh"' "$repository_root/index.html"; then
    printf 'General support directory must not redirect\n' >&2
    exit 1
fi
grep -Fq 'href="https://feichti01.github.io/gasblender/support/"' \
    "$repository_root/index.html"
grep -Fq 'https://github.com/feichti01/support/issues/new' "$repository_root/index.html"
grep -Fq 'https://github.com/feichti01/support/issues?q=' "$repository_root/index.html"

printf 'support redirect contract tests passed\n'
