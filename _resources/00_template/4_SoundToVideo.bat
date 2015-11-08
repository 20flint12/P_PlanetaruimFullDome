ffmpeg -i sound.mp3 -i "result_video/slide1.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide1s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide2.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide2s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide3.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide3s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide4.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide4s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide5.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide5s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide6.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide6s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide7.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide7s.mpg"
ffmpeg -i sound.mp3 -i "result_video/slide8.mpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 4 -y "result_video/slide8s.mpg"

Pause

:: -q:v 2-31 2-best quality video
:: -q:a 2-31 2-best quality audio 

:: -b Set bit rate in bits/s

:: -maxrate integer (encoding,audio,video) 
:: Set max bitrate tolerance (in bits/s). Requires bufsize to be set.

:: -minrate integer (encoding,audio,video)
:: Set min bitrate tolerance (in bits/s). Most useful in setting up a CBR encode. It is of little use elsewise.

:: -bufsize integer (encoding,audio,video) Set ratecontrol buffer size (in bits).

:: -r fps 
:: Set frame rate (Hz value, fraction or abbreviation), (default = 25).

:: -s size
:: Set frame size. The format is wxh (ffserver default = 160x128, ffmpeg default = same as source).

:: -pix_fmt format
:: Set pixel format. Use 'list' as parameter to show all the supported pixel formats.
:: -pix_fmts
:: Show available pixel formats.

:: -y
:: Overwrite output files.

:: -i filename
:: Input file name
