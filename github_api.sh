#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-02-12 23:43:00 +0000 (Wed, 12 Feb 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#
#  args: /repos/HariSekhon/DevOps-Bash-tools/actions/workflows
#  # returns 0
#  args: /repos/HariSekhon/DevOps-Bash-tools/actions/runners

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Script to query the GitHub.com API

Automatically handles authentication via environment variables \$GITHUB_USER
and \$GITHUB_TOKEN / \$GITHUB_PASSWORD (the latter is deprecated)

Can specify \$CURL_OPTS for options to pass to curl or provide them as arguments


usage: ${0##*/} /path [<curl_options>]


eg. ${0##*/} /repos/HariSekhon/DevOps-Bash-tools/actions/workflows

"

help_usage "$@"

min_args 1 "$@"

export USER="${GITHUB_USER:-${USERNAME:-${USER}}}"
PASSWORD="${GITHUB_PASSWORD:-${GITHUB_TOKEN:-${PASSWORD:-}}}"

if [ -z "${PASSWORD:-}" ]; then
    PASSWORD="$(git remote -v | awk '/https:\/\/[[:alnum:]]+@github\.com/{print $2; exit}' | sed 's|https://||;s/@.*//')"
fi

export PASSWORD

#if [ -n "${PASSWORD:-}" ]; then
#    echo "using authenticated access" >&2
#fi

url_path="${1:-}"
url_path="${url_path//https:\/\/api.github.com}"
url_path="${url_path##/}"

shift

eval "$srcdir/curl_auth.sh" --fail -sS --connect-timeout 3 "${CURL_OPTS:-}" "https://api.github.com/$url_path" "$@"
