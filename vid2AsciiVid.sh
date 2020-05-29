#!/bin/bash

rm -rf ./ascii_imgs
rm -rf ./frames

mkdir ./ascii_imgs
mkdir ./frames

#Extract audio of video file passed in $1
ffmpeg -y -i $1 -f mp3 -ab 192000 -vn audio.mp3
#Extract jpg frames of video passed in $1
ffmpeg -y -i $1 ./frames/thumb%05d.jpg -hide_banner


N=24
for file in ./frames/*.jpg; 
do
    #Leverage TLP and execute up to 24 subshells
    ((i=i%N)); ((i++==0)) && wait
    (
        #get file basename
        base=$(basename $file);
        #Convert to Ascii art using jp2a 
        jp2a --background=light $file > $base.txt;
        #Convert to png using imagemagick  
        bash txt2png $base.txt ./ascii_imgs/$base.png;
        rm $base.txt;
    ) &
done

#Merge frames into an output file output.mp4
ffmpeg -r 23.98 -f image2 -s 1920x1080 -i ./ascii_imgs/thumb%05d.jpg.png \
    -vcodec libx264 -crf 25  -pix_fmt yuv420p output.mp4
#Combine old audio with new video
ffmpeg -i output.mp4 -i audio.mp3 -c:v copy -c:a aac outputWAudio.mp4


