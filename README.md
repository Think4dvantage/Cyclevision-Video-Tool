# CyclevisionVideoStitcher
Powershell Script to Stitch together Cyclevision Video Parts and then blend in the Rearview over the Frontview

# Prerequirements
In this Script I assume you have ffmpeg and ffprobe stored in C:\programfiles\ffmpeg\ - you can change this by 
changing the $ffmpegPath and $ffmpegProbePath variable with your respective Path to the EXE File of ffmpeg

Nevertheless you will need to download a compiled version of ffmpeg for Windows from https://ffmpeg.org/download.html
and unpack the ZIP to somewhere. 

Also you will need a Cyclevision helmet to produce the Source Data :-P www.cyclevision.com.au

# Description of what this Script does

This script checks if your C:\Cyclevision Folder has any Subfolders. In those Subfolders the Script expects Cyclevision
Video Files of the Backview and Frontview named in the Standardnaming of Cyclevision (B_for Backview and F_ Frontview) 
First of all the Script stitches together the VideoParts of Backview and the Videoparts of Frontview and stores them in 
the Folder. Then those two files are Taken, the Backview is resized and blended ontop of the FrontView Video with 70% 
Opacity. After this, the Script removes the Source Parts and keeps the Stitched Frontview/Backview and the blended video
in the Folder.

# Details of ffmepg Commands

It was hard for me to Understand the Syntax of ffmpeg - to make sure I can find my way around it when i Come back I will
explain the ffmpeg commands in here. 
    
## Blending

Before using this Script and ffmpeg I used Video edition Software to create a Picture in Picture of the two Video Streams 
Best way to do this PiP is if you add the Backview with a lowered Opacity. By blending the two Video streams I can now get 
the exact same result by using ffmpeg and this Script.

Example Argument: 
    
ffmpeg.exe -i C:\Cyclevision\2020.10.01\Frontview.mp4 -itsoffset 00:00:01.889 -i C:\Cyclevision\2020.10.01\BackView.mp4 
-filter_complex "
    [1:v] scale=550:-1, pad=1920:1080:ow-iw-1360:oh-ih-10, setsar=sar=1, format=rgba [bs]; 
    [0:v] setsar=sar=1, format=rgba [fb]; 
    [fb][bs] blend=all_mode=addition:all_opacity=0.7" 
-vcodec libx265 -crf 28 
C:\Cyclevision\2020.10.01\.mp4 
-hwaccel cuda -hwaccel_output_format cuda -y

Explaining Arguments of Blending:
Command | Explanation
------- | -----------
-i C:\Cyclevision\2020.10.01\Frontview.mp4 | first Input stored as [0]
 -itsoffset 00:00:01.889 | Offsetting the Start of Stream [1] by 01.889 Seconds (since the Videos dont Start at the same time)
 -i C:\Cyclevision\2020.10.01\BackView.mp4 | second Input stored as [1]
 -filter_complex | start complex filter which enables you do to crazy things
 [1:v] | Take Videostream of Video 1
 scale=550:-1, | Scale Video [1] it to 550*302 Pixels
 pad=1920:1080: | Keep the size of the Stream of Video [1] on FullHD - this is needed so that the two streams can be blended together (blending needs same Resolution)
 ow-iw-1360:oh-ih-10 | put the Scaled video on the Bottomleft Corner with 10px padding (1360 + 550 = 1910 - makes a 10px margin) 
 setsar=sar=1, format=rgba [bs] | set Color preset for blending and store the altered Stream of [1] as [bs]
 [0:v] setsar=sar=1, format=rgba [fb] | Set Color Preset for Video [0] and store it as [fb]
 [fb][bs] blend=all_mode=addition:all_opacity=0.7 | Blend in [bs] on top of [fb] with an opacity of 0.7 = 70%
 -vcodec libx265 -crf 28 | Re-Encode Video with x265 Codec with a CRF (quality) setting of 28 - the lower the CRF the higher the Quality
 C:\Cyclevision\2020.10.01\.mp4 | Output Path for Operation -> this is the result of the Operation
 -hwaccel cuda -hwaccel_output_format cuda | enable ffmpeg to use Nvidia power to increase Speed of operation
 -y | Overwrite Output File if it already exists
   
Why use blending instead of Overlay? to be able to use Opacity

## Stitching

Cyclevision creates a new Videofile every 2 Minutes - ffmpeg has an easy filter to stitch those together to one Video file.

First of all I needed to create a File with all Paths to the Video Parts in correct order in it. But with the Syntax:

file 'path' -> file 'C:\Cyclevision\2020.09.27.1\B_20200927_174741.mp4'

After this TXT File has been created I could run the following Command: 

ffmpeg.exe -f concat -safe 0 -i parts.txt -c copy C:\Cyclevision\2020.10.01\Frontview.mp4 -y

Command | Explanation
------- | -----------
-f concat | Filter Concatenate -> Add the following Inputs together
-save 0 | No idea what it does
-i parts.txt | Input the TXT File with the Path to the Video Parts
-c copy | Tell the System to Copy - i guess
C:\Cyclevision\2020.10.01\Frontview.mp4 | Output file
-y | Overwrite Output File if it already Exists

## Get Video Length

I had the Problem that the Cyclevision Helmet is creating the two Videostreams with a slight offset. First I thought its always the same Offset
but later I realized its always a different offset. To be able to synchronise the Videos properly I needed a way to get the exact length of the 
Backend and the Frontend video and then offset the Backend stream by those tiny bits of seconds its later than the FrontView Video. 

ffprobe.exe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 C:\Cyclevision\2020.10.01\Frontview.mp4

Command | Explanation
------- | -----------
ffprobe.exe | This time I had to use ffprobe.exe and not ffmpeg.exe
-v error | no idea
-show_entries format=duration | get duration of Video metadata
-of default=noprint_wrappers=1:nokey=1 | no idea
C:\Cyclevision\2020.10.01\Frontview.mp4 | Path to the Videofile I wanted to analyze