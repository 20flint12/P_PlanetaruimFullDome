::ffmpeg -r 30 -s 1280x768 -pix_fmt yuv420p -y -i "parts/slide5/slide5_%%10d.jpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 25 "result_video/slide5.mpg"
::ffmpeg -r 30 -s 1280x768 -pix_fmt yuv420p -y -i "parts/slide6/slide6_%%10d.jpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 25 "result_video/slide6.mpg"
::ffmpeg -r 30 -s 1280x768 -pix_fmt yuv420p -y -i "parts/slide7/slide7_%%10d.jpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 25 "result_video/slide7.mpg"
::ffmpeg -r 30 -s 1280x768 -pix_fmt yuv420p -y -i "parts/slide8/slide8_%%10d.jpg" -b:v 22000k -minrate 22000k -maxrate 22000k -bufsize 40000k -q:v 25 "result_video/slide8.mpg"

ffmpeg -r 30 -y -i "parts/slide1/slide1_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide1.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide2/slide2_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide2.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide3/slide3_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide3.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide4/slide4_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide4.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide5/slide5_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide5.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide6/slide6_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide6.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide7/slide7_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide7.mp4" -vstats
ffmpeg -r 30 -y -i "parts/slide7/slide8_%%10d.jpg" -c:v mpeg4 -b:v 2M -minrate 0 -maxrate 20M -bufsize 40M -q:v 10 "result_video/slide8.mp4" -vstats


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
