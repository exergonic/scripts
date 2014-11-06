set -e # exit on first error
set -u # error on unset
set -o pipefile
readonly progname=$(basename $0)
readonly progdir=$(readlink -m $(dirname $0))
readonly args="$@"
set -e
set -u
set -o pipefail

func ()
{
	local var=localvar #everything is local
}
