#!/bin/bash

rm -rf ./imgs
rm -rf ./frames

mkdir ./imgs
mkdir ./frames

#Extract audio of video file passed in $1
#ffmpeg -y -i $1 -f mp3 -ab 192000 -vn audio.mp3
#Extract jpg frames of video passed in $1
ffmpeg -y -i $1 ./frames/thumb%05d.jpg -hide_banner


N=50
for file in ./frames/*.jpg; 
do
    #Leverage TLP and execute up to 50 subshells
    ((i=i%N)); ((i++==0)) && wait
    (
        #get file basename
        base=$(basename $file);
        #Convert to Ascii art using jp2a 
        jp2a --html --colors $file > $base.html;
        google-chrome --headless --disable-gpu --window-size=870,470 --screenshot=./imgs/$base.png $base.html
        #Convert to png using imagemagick  
        convert ./imgs/$base.png -resize 1280x720 -background black -gravity center -extent 1280x720 ./imgs/$base.png
        rm $base.html;
    ) &
done

#Merge frames into an output file output.mp4
ffmpeg -y -r 29.97 -f image2 -s 1280x720 -i ./imgs/thumb%05d.jpg.png \
    -vcodec libx264 -crf 25  -pix_fmt yuv420p output.mp4
#Combine old audio with new video
ffmpeg -y -i output.mp4 -i audio.mp3 -c:v copy -c:a aac outputWAudio.mp4


