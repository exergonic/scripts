set -e
set -u
set -o pipefail
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

func ()
{
	local var=localvar #everything is local
}
