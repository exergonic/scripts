set -e # exit on first error
set -u # error on unset

func ()
{
	local var=localvar #everything is local
}
