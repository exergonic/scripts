#!/bin/bash
# record the desktop
# if -v is passed, record sound as well
if [[ "$1" == "-v" ]]
then
	#ffmpeg -f alsa -i pulse -f x11grab -r 25 -s 1440x900 -i :0.0+0,24 -vcodec libx264  -threads 0 -strict -2 cast.mp4
	ffmpeg -f alsa -i pulse -f x11grab -r 25 -s 1600x900 -i :0.0 -vcodec libx264  -threads 0 -strict -2 cast.mp4
else
	ffmpeg -f x11grab -r 25 -s 1440x900 -i :0.0 -qscale 0 rec.mp4
fi
