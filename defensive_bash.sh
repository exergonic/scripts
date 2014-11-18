set -e # exit on first error
set -u # error on unset
set -o pipefail
readonly progname=$(basename $0)
readonly progdir=$(readlink -m $(dirname $0))
readonly args="$@"

func ()
{
	local var=localvar #everything is local
}
