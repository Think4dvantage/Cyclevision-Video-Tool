# Cyclevision Video Tool
This is a little Powershell Tool (with .Net GUI) to Stitch together Cyclevision Videoparts and create a Bunch of Outputs.
Output can be Stitched Backend/Frontend only, Short Video, Full video with Transparent Backview, Full Video with Solid Backview

# Prerequirements
In this Script I assume that you have a ffmpeg folder in the Script folder with at least ffmpeg.exe and ffprobe.exe in it. 
You should be able to find the Path in NewVideoCombiner.ps1 and Change it if you need to. 

Nevertheless you will need to download a compiled version of ffmpeg for Windows from https://ffmpeg.org/download.html
and unpack the ZIP to somewhere. 

Also you will need a Cyclevision helmet to produce the Source Data :-P www.cyclevision.com.au

After you have Created your Videos, connect your Helmet to your Computer and Copy all the Front/Back-View Videos into Folders. 
I assume you create one Subfolder per Video you want to create. 

Folderstructure can be D:\Cyclevision and Subfolders D:\Cyclevision\20210124, D:\Cyclevision\202101242, D:\Cyclevision\202101243 
each Subfolders is expected to contain Backview and Frontview Videoparts. 

# How to Use
Clone the Repository to your Computer, Download and Unpack FFMPEG. Prepare a Folder Structure with your Videoparts. Then open 
Powershell and navigate to the cloned Repository and launch CyclevisionVideoToolGUI.ps1

# Description of what this Script does

First of all the GUI starts a Folder-Selection GUI where you are able to choose the Folder where you put your Videoparts into Subfolders.
After you have chosen the Folder the Script goes through every Folder and Stitches those Videos together. Videos named B_* will be combined 
into Backview Videos and Videos named F_* will be combined into Frontview. The Videoparts will be deleted as they do not have a value anymore.

After the Videos have been Stitched the main GUI will be launched, it could be the GUI is launched hidden behind the Powershell Window - please 
check if this happened before giving up on the Script. After the GUI has been launched you are able to choose what you want to do with the Videos 
you can choose between Skip, Short, Solid and Transparent videos. 

|Option|Needed for|Description|Datatype|Example|
|------|----------|-----------|--------|-------|
|skip  |StitchOnly|Skip this Folder|bool|$true|
|short |ShortVideo|Create a Short Video|bool|$true|
|solid |SolidVideo|Create a Full length Video with solid Overlay of Backview|bool|$true|
|transparent|Transparent Video|Create a Full lenght Video with tranparent Overlay of Backview|bool|$true|
|StartBegin|ShortVideo|Timestamp where the Start Begins in the FrontVideo (HH:MM:SS)|DateTime|00:02:00|  
|StartEnd|ShortVideo|Timestamp where the Start Ends in the FrontVideo (HH:MM:SS)|DateTime|00:04:00|
|LandingBegin|ShortVideo|Timestamp where the Landing Begins in the FrontVideo (HH:MM:SS)|DateTime|00:54:12|  
|LandingEnd|ShortVideo|Timestamp where the Landing Ends in the FrontVideo (HH:MM:SS)|DateTime|00:56:30|
|Distance of VideoParts|ShortVideo|Distance between the Videoparts that will be cut out of the Video(HH:MM:SS)|DateTime|00:02:00|
|Size of Videoparts|ShortVideo|Length of Videopart that will be cut out in Seconds |int|15|
|SzeneX|ShortVideo|Scenes that you want to be part of the ShortVideo (HH:MM:SS)|DateTime|00:02:00| 

As you can see - most of the options revolve around the ShortVideo - after you have entered your Information and pushed the "RUN" Button. 
The GUI triggers create-Video Function which was imported from NewVideoCombiner.ps1 and in this Function all the magic happens. 

solid and tranparent are pretty straight forward - Shortvideo will get a separate description. 

## ShortVideo
When Short Video is true then the Script will take the Start and Landing and cut out a part of the video between Start and Landing every XY Seconds (Distance).
Standard config is: Every 2 Minutes a 15 Second Script will be cut out. All the Scripts that have been cut out will be Stitched together with the Landing and the Start
as Start and End of the Video. Also the must have Scenes will be cut out and put into the Video at the right order. 


# Details of ffmepg Commands

It was hard for me to Understand the Syntax of ffmpeg - to make sure I can find my way around it when i Come back I will
explain the ffmpeg commands in here. 
    
## Transparent Video Overlay

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

## Stitch Videos together

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

## Solid Video Overlay

## Short Video Summary

The ShortVideo takes out multiple parts of the Input and cut them together. 

ffmpeg.exe -i D:\Cyclevision\2021.01.08.1\2021-01-08-Frontview.mp4 -itsoffset 00:00:02.000 -i D:\Cyclevision\2021.01.08.1\2021-01-08-Backview.mp4 -filter_complex "[1]trim=38:63,setpts=PTS-STARTPTS[bs],[bs]scale=550:-1[bso],[0]atrim=40:65,asetpts=PTS-STARTPTS[ap1],[0]trim=40:65,setpts=PTS-STARTPTS[bv],[bv][obs] overlay=10:760[p1],[0]atrim=160:175,setpts=PTS-STARTPTS[ap2],[0]trim=160:175,setpts=PTS-STARTPTS[p2],[p1][ap1][p2][ap2]concat=n=15:v=1:a=1[out][aout]" -map "[out]" -map "[aout]" D:\Cyclevision\2021.01.08.1\2021-01-08-SHORT.mp4 -filter:a loudnorm -hwaccel cuda -hwaccel_output_format cuda -y

Command | Explanation 
------- | -----------
-i D:\Cyclevision\2021.01.08.1\2021-01-08-Frontview.mp4 | Input [0] FrontVideo
-itsoffset 00:00:02.000 | Offset Input [1] by 2 Seconds (cause the backend Video has an Offset)
-i D:\Cyclevision\2021.01.08.1\2021-01-08-Backview.mp4 | Input [1] BackVideo
-filter_complex " | Filter Complex 
[1]trim=38:63,setpts=PTS-STARTPTS[bs], | Cut out a part of [1] and store it in [BS]
[bs]scale=550:-1[bso], | Resize [bs] so that it will have the right size for Overlay and store it in [bso]                 
[0]atrim=40:65,asetpts=PTS-STARTPTS[ap1], | Cut out the Audio part of [0] and store it in [ap1]
[0]trim=40:65,setpts=PTS-STARTPTS[bv], | Cut out the Video part of [0] and store it in [bv]
[bv][obs] overlay=10:760[p1], | Overlay [BSO] over [BV] and store it in [p1]
[0]atrim=160:175,asetpts=PTS-STARTPTS[ap2], | Trim Audio from [0] and store it in [ap2]       
[0]trim=160:175,setpts=PTS-STARTPTS[p2], | Trim Video from [0] and store it in [p2]
[p1][ap1][p2][ap2]concat=n=15:v=1:a=1[out][aout]" | Combine Videoparts together and store it in [out] combine Audio parts and store it in [aout]
-map "[out]" | Map [out] to Output
-map "[aout]" D:\Cyclevision\2021.01.08.1\2021-01-08-SHORT.mp4 | Map [aout] to Output
-filter:a loudnorm | Apply Audio filter to break down peaks
-hwaccel cuda | Use CUDA as hwaccel
-hwaccel_output_format cuda | Use CUDA 
-y | Overwrite existing Outputfile