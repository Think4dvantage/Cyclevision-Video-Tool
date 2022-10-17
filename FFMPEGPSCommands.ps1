
#Command to concatenate multiple MP4 very Fast
start-process -FilePath "C:\git\PS_VidAggregator\ffmpeg\ffmpeg.exe" -ArgumentList "-f concat -safe 0 -i D:\Insta360Parts\20221016-Parts.txt -c copy D:\Insta360Parts\20221016-Full.mp4 -y" -PassThru -Wait -NoNewWindow

ffmpeg.exe -i D:\Insta360Parts\20221016-Full.mp4 -filter_complex "[0]atrim=4:14,setpts=PTS-STARTPTS[ap1],[0]trim=4:14,setpts=PTS-STARTPTS[p1],[0]atrim=600:620,setpts=PTS-STARTPTS[ap2],[0]trim=600:620,setpts=PTS-STARTPTS[p2],[p1][ap1][p2][ap2]concat=n=15:v=1:a=1[out][aout]" -map "[out]" -map "[aout]" D:\test.mp4 -filter:a loudnorm -hwaccel cuda -hwaccel_output_format cuda -y