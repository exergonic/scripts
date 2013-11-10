#!/bin/bash

# script to explore how the select function
# uses the number the user puts in

select foo in foo bar oni ; do
	echo $REPLY
	echo $foo
	break
done
