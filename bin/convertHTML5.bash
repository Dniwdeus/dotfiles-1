#!/bin/bash

if [[ $1 ]]
then
    filename=$(basename "$1")
    filename=${filename%.*}
    directory=$(dirname "$1")

    duration=$(ffmpeg -i "$1" 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
    minutes=${duration%:*}
    hours=${minutes%:*}
    minutes=10#${minutes##*:}
    seconds=${duration##*:}
    seconds=${seconds%.*}

    
    hours=$((hours*3600))
    minutes=$((minutes*60))

    total=$(expr $hours + $minutes + $seconds)
    number=$RANDOM
    let "number %= $total"

    echo "Generating thumbnail"
    ffmpeg -i "$1" -deinterlace -an -ss $number -t 00:00:01 -r 1 -y -vcodec mjpeg -f mjpeg "$directory/$filename.jpg" 2>&1
    echo "Converting $filename to ogv"
    ffmpeg -i "$1" -acodec libvorbis -ac 2 -ab 96k -ar 44100 -b 345k "$directory/$filename.ogv"
    echo "Finished ogv"

    echo "Converting $filename to webm"
    ffmpeg -i "$1" -acodec libvorbis -ac 2 -ab 96k -ar 44100 -b 345k "$directory/$filename.webm"
    echo "Finished webm"

    echo "Converting $filename to h264"
    ffmpeg -i "$1" -acodec libfaac -ab 96k -vcodec libx264 slow -vpre baseline -level 21 -refs 2 -b 345k -bt -threads 0 "$directory/$filename.mp4"
    echo "Finished h264"

    echo "Writing HTML..."
    
    echo "<video controls poster=\"$filename.jpg\" preload>" > "$directory/$filename.html"
    echo "  <source type=\"video/ogg\" src=\"$filename.ogv\">" >> "$directory/$filename.html"
    echo "  <source type=\"video/webm\" src=\"$filename.webm\">" >> "$directory/$filename.html"
    echo "  <source type=\"video/mp4\" src=\"$filename.mp4\">" >> "$directory/$filename.html"
    echo "  Sorry, your browser does not support HTML5 video" >> "$directory/$filename.html"
    echo "</video>" >> "$directory/$filename.html"
    
    echo "All Done!"
else
    echo "Usage: [filename]"
fi
