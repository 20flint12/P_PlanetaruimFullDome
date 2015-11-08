#https://www.ffmpeg.org/ffmpeg.html
ffmpeg --help full
Pause


#Constant bitrate

#
ffmpeg -i input.mp4 -c:v libvpx -minrate 1M -maxrate 1M -b:v 1M output.webm