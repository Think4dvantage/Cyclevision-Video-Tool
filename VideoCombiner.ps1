param (
    [Parameter()]
    [switch]$StitchOnly = $false,           # Only Stitch together Videoparts
    [switch]$TransparentVideo = $false,     # Only create a Video with front and Backview in Solid
    [switch]$SolidVideo = $false,           # Only create a Video with Fron in solid and Backview with Opacity
    [switch]$DoAll = $false,                # Create all different Video flawers
    [switch]$ShortVideo = $false,           # Create a short video with Start, Landing and Video snippets in between
    [int]$StartBegin,                       # For Short Video: Tell the Video where the Start beginns (in seconds)
    [int]$StartEnd,                         # For Short Video: Tell the Video where the Start Ends (in seconds)
    [int]$LandingBegin,                     # For Short Video: Tell the Video where the Landing begins (in Seconds)
    [int]$LandingEnd,                       # For Short Video: Tell the Video where the Landing ends (in Seconds)
    [int]$inc = 120                         # For Short Video: Set the Increment of the Video Snippets
)
#Do the Magic so I dont lose my mind about the Options
if($stitchonly -eq $false -and $TransparentVideo -eq $false -and $SolidVideo -eq $false -and $doall -eq $false -and $ShortVideo -eq $false)
{
    $ShortVideo = $true
}

if($doall -eq $true)
{
    $StitchOnly = $false
    $TransparentVideo = $true
    $SolidVideo = $true
    $ShortVideo = $true
}

#This Function does all the Work - Stitches Together the Backview and FrontView and then Puts the Backview as smaller overlay to the FrontView Video
function CreateCamVideo($InputFolder)
{
    #Function to create Input File for Video Stitching - I somehow didn't get it to work with a Variable.
    function createInputfile($Path, $View)
    {
        #Prepare Output Var
        $out = @()
        #Get Filenames from Folder - Either F_ for frontview or B_ for Backview
        $FileNames = (get-childitem -Path $Path\* -Include ($View + "_*")).Versioninfo.Filename
        #Go trough every File and add it to the Output Array
        foreach($file in $filenames)
        {
            $out += ("file '" + $file + "'") 
        }
        #Return the Files collected
        return $out
    }

    #If Sourcefiles still exist, get RecordDate from Writetime of Source file - if not get RecordDate from any Filename in Folder
    if((get-childitem -Path $InputFolder\* -Include ("F_*")))
    {
        $RecordDate = ((get-childitem -Path $InputFolder\* -Include ("F_*"))[0].LastWriteTime).ToString("yyyy-MM-dd")
    }
    else 
    {
        $RecordDate = (get-childitem -Path $InputFolder\*)[0].Name.Substring(0,10)
    }
    
    #Path to the Txt file containing the Parts for later Stitching
    $InputFilePath = ($InputFolder + "\PartList.txt")
    #Path to the Output of the Stitching of FrontParts
    $frontOut = ($InputFolder + "\" + $RecordDate + "-Frontview.mp4")
    #Path to the Output of the Stitching of BackParts
    $backOut = ($InputFolder + "\" + $RecordDate + "-BackView.mp4")
    #Generate Output path for the Blended Video
    $outputpath = ($InputFolder + "\" + $RecordDate + "-trans.mp4")
    #OutputSolid
    $outputsolid = ($InputFolder + "\" + $RecordDate + "-solid.mp4")
    #OutputShort
    $outputshort = ($InputFolder + "\" + $RecordDate + "-short.mp4")
    #Path to the FFMPEG Binary (needs to be downloaded from ffmpeg)
    $ffmpegPath = "C:\Program Files\ffmpeg\ffmpeg.exe"
    #Path to the FFProbe Binary (in the same download as the ffmpeg download)
    $ffmpegProbePath = "C:\Program Files\ffmpeg\ffprobe.exe"

    #Check if Fronview and Backview Video have been Stitched together - if they are skip this Step
    if(!(test-path -path $frontout) -and !(test-path -path $backout))
    {
        #Trigger createInputFunction and write output to InputFilePath
        set-content -path $InputFilePath -Value (createInputfile $InputFolder "F")
        #Stitch together all MP4 Files mentioned in the Input File Path
        start-process -FilePath $ffmpegPath -ArgumentList "-f concat -safe 0 -i $InputFilePath -c copy $frontOut -y" -PassThru -Wait -NoNewWindow
        #Trigger createInputFunction to get Backview Parts and write it to InputFile
        set-content -path $InputFilePath -Value (createInputfile $InputFolder "B")
        #Stitch together the Rearview Input Files to one Big video
        start-process -FilePath $ffmpegPath -ArgumentList "-f concat -safe 0 -i $InputFilePath -c copy $backOut -y" -PassThru -Wait -NoNewWindow

        #Test if FrontView and Backview Video exist - if they exist delete the Sourcevideos
        if((test-path -path $frontout) -and (test-path -path $backout))
        {
            Remove-Item -Path $InputFolder\* -Exclude ($RecordDate + "*") -Recurse -Force
        }
    }
    
    if($StitchOnly -eq $true)
    {
        Write-host "Stitched Videos and Stitch only is active progressing with next Folder!"
        return 
    }

    #Get FrontView Video length by using ffprobe - to get an Idea what offset the Videos have (its everytime different) had to use cmd cause start-process wouldn't deliver me the return
    $frontViewSize = cmd /c ([char]34 + "$ffmpegProbePath" + [char]34 + " -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " + $frontOut)
    #Get Backview Video length to see how much the Backview video needs to be delayed
    $BackViewSize = cmd /c ([char]34 + "$ffmpegProbePath" + [char]34 + " -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " + $BackOut)
    #Create Value of Offset as a string to use it in the Arguments of the Blending Command
    $VideoOffset = ($FrontViewSize - $BackViewSize).toString("#.###")
    #Make sure VideoOffset has 3 digits after the Comma 
    if($videoOffset -like "-*")
    {
        $videoOffset = "2.000"
    }
    
    if($VideoOffset.Length -ne 5)
    {
        switch ($VideoOffset.Length) {
            4 { $VideoOffset = $VideoOffset + "0" }
            3 { $VideoOffset = $VideoOffset + "00" }
            1 { $VideoOffset = $VideoOffset + ".000" }
            Default {$VideoOffset = "2.000" }
        }
    }

    if($TransparentVideo -eq $true -and !(test-path $outputpath))
    {
        #Prepare FFMPEG Arguments to Blend the two videos together
        $ffmpegarguments = ("-i $frontout -itsoffset 00:00:0$VideoOffset -i $backout -filter_complex " + [char]34 + "[1:v] scale=550:-1, pad=1920:1080:ow-iw-1360:oh-ih-10, setsar=sar=1, format=rgba [bs]; [0:v] setsar=sar=1, format=rgba [fb]; [fb][bs] blend=all_mode=addition:all_opacity=0.7" + [char]34 + " -filter:a loudnorm -vcodec libx265 -crf 28 $outputpath -hwaccel cuda -hwaccel_output_format cuda -y")
        
        #Example Argument: -i C:\Cyclevision\2020.10.01\Frontview.mp4 -itsoffset 00:00:01.889 -i C:\Cyclevision\2020.10.01\BackView.mp4 -filter_complex "[1:v] scale=550:-1, pad=1920:1080:ow-iw-1360:oh-ih-10, setsar=sar=1, format=rgba [bs]; [0:v] setsar=sar=1, format=rgba [fb]; [fb][bs] blend=all_mode=addition:all_opacity=0.7" -vcodec libx265 -crf 28 C:\Cyclevision\2020.10.01\.mp4 -hwaccel cuda -hwaccel_output_format cuda -y
        #Explaining Arguments of Blending:
        # -i C:\Cyclevision\2020.10.01\Frontview.mp4        -> first Input stored as [0]
        # -itsoffset 00:00:01.889                           -> Offsetting the Start of Stream [1] by 01.889 Seconds (since the Videos dont Start at the same time)
        # -i C:\Cyclevision\2020.10.01\BackView.mp4         -> second Input stored as [1]
        # -filter_complex                                   -> start complex filter which enables you do to crazy things
        # [1:v]                                             -> Take Videostream of Video 1
        # scale=550:-1,                                     -> Scale Video [1] it to 550*302 Pixels
        # pad=1920:1080:                                    -> Keep the size of the Stream of Video [1] on FullHD - this is needed so that the two steams can be blended together (blending needs same Resolution)
        # ow-iw-1360:oh-ih-10                               -> put the Scaled video on the Bottomleft Corner with 10px padding (1360 + 550 = 1910 - makes a 10px margin) 
        # setsar=sar=1, format=rgba [bs]                    -> set Color preset for blending and store the altered Stream of [1] as [bs]
        # [0:v] setsar=sar=1, format=rgba [fb]              -> Set Color Preset for Video [0] and store it as [fb]
        # [fb][bs] blend=all_mode=addition:all_opacity=0.7  -> Blend in [bs] on top of [fb] with an opacity of 0.7 = 70%
        # -vcodec libx265 -crf 28                           -> Re-Encode Video with x265 Codec with a CRF (quality) setting of 28 - the lower the CRF the higher the Quality
        # C:\Cyclevision\2020.10.01\.mp4                    -> Output Path for Operation -> this is the result of the Operation
        # -hwaccel cuda -hwaccel_output_format cuda         -> enable ffmpeg to use Nvidia power to increase Speed of operation
        # -y                                               -> Overwrite Output File if it already exists
        # Why use blending instead of Overlay? to be able to use Opacity
        
        #Blend FrontView and Backview together
        start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
    }
    
    if($SolidVideo -eq $true -and !(test-path $outputsolid))
    {
        #Prepare FFMPEG Arguments to Blend the two videos together
        $ffmpegarguments = ("-i $frontout -itsoffset 00:00:0$VideoOffset -i $backout -filter_complex " + [char]34 + "[1:v] scale=550:-1 [bs]; [0][bs] overlay=10:760" + [char]34 + " -filter:a loudnorm -vcodec libx265 -crf 28 $outputsolid -hwaccel cuda -hwaccel_output_format cuda -y")
                     
        #Blend FrontView and Backview together
        start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
    }


    if($ShortVideo -eq $true -and !(test-path $outputshort))
    {
        if(!$StartBegin -or !$StartEnd -or !$LandingBegin -or !$LandingEnd)
        {
            Write-host "Sorry but if you want to create a Short Video you need to Input StartBegin, StartEnd, LandingBegin, LandingEnd for it to Properly Work"
            return
        }
        
        <#
            Sample Arguments of this Command and Its Explanation

            -i D:\Cyclevision\2021.01.08.1\2021-01-08-Frontview.mp4             -> Input [0] 
            -itsoffset 00:00:02.000                                             -> Offset Input [1] by 2 Seconds (cause the backend Video has an Offset)
            -i D:\Cyclevision\2021.01.08.1\2021-01-08-Backview.mp4              -> Input [1]
            -filter_complex "
                [1]trim=38:63,setpts=PTS-STARTPTS[bs],                          -> Cut out a part of [1] and store it in [BS]
                [bs]scale=550:-1[bso],                                          -> Resize [bs] so that it will have the right size for Overlay and store it in [bso]                 
                [0]atrim=40:65,asetpts=PTS-STARTPTS[ap1],                       -> Cut out the Audio part of [0] and store it in [ap1]
                [0]trim=40:65,setpts=PTS-STARTPTS[bv],                          -> Cut out the Video part of [0] and store it in [bv]
                [bv][obs] overlay=10:760[p1],                                   -> Overlay [BSO] over [BV] and store it in [p1]
                [0]atrim=160:175,asetpts=PTS-STARTPTS[ap2],                     -> Trim Audio from [0] and store it in [ap2]       
                [0]trim=160:175,setpts=PTS-STARTPTS[p2],                        -> Trim Video from [0] and store it in [p2]
                [p1][ap1][p2][ap2]concat=n=15:v=1:a=1[out][aout]"               -> Combine Videoparts together and store it in [out] combine Audio parts and store it in [aout]
            -map "[out]"                                                        -> Map [out] to Output
            -map "[aout]" D:\Cyclevision\2021.01.08.1\2021-01-08-SHORT.mp4      -> Map [aout] to Output
            -filter:a loudnorm                                                  -> Apply Audio filter to break down peaks
            -hwaccel cuda                                                       -> Use CUDA as hwaccel
            -hwaccel_output_format cuda                                         -> Use CUDA 
            -y                                                                  -> Overwrite existing Outputfile
        #>
       
        
        
        $ffmpegarguments = ("-i $frontout -i $backout -filter_complex " + [char]34 + "[1]trim="+ ($startBegin-$VideoOffset) + ":" + ($StartEnd-$VideoOffset) +",setpts=PTS-STARTPTS[bs],[bs]scale=550:-1[bso];[0]atrim=" + $StartBegin + ":" + $StartEnd + ",asetpts=PTS-STARTPTS[ap1],[0]trim=" + $StartBegin + ":" + $StartEnd + ",setpts=PTS-STARTPTS[fv],[fv][bso] overlay=10:760[p1],")
        $parts = 1
        $partStart = $StartBegin + $inc
        do {
            $parts++
            $partEnd = $partStart + 15
            $ffmpegarguments = ($ffmpegarguments + "[0]atrim=" + $partStart + ":" + $PartEnd +",asetpts=PTS-STARTPTS[ap"+ $parts +"]," + "[0]trim=" + $partStart + ":" + $PartEnd +",setpts=PTS-STARTPTS[p"+ $parts +"],")
            $partStart = $partStart + $Inc
        } while ($PartStart -lt $LandingBegin)
        $Parts += 1
        $ffmpegarguments = ($ffmpegarguments + "[0]atrim=" + $LandingBegin + ":" + $LandingEnd + ",asetpts=PTS-STARTPTS[ap"+ $parts +"],[0]trim=" + $LandingBegin + ":" + $LandingEnd + ",setpts=PTS-STARTPTS[p"+ $parts +"],")
        $i = 1
        do {
            $ffmpegarguments = ($ffmpegarguments + "[p" + $i + "][ap" + $i + "]")
            $i++ 
            
        } while ($i -lt $parts)
        $ffmpegarguments = ($ffmpegarguments + "[p" + $parts + "][ap" + $parts + "]concat=n=" + $parts + ":v=1:a=1[out][aout]" + [char]34 + " -map " + [char]34 + "[out]" + [char]34 + " -map " + [char]34 + "[aout]" + [char]34 +" $outputshort -filter:a loudnorm -hwaccel cuda -hwaccel_output_format cuda -y")
        
        $VidLength = [timespan]::fromseconds([int]($StartEnd - $StartBegin) + ((($LandingBegin - $StartEnd)/$inc)*15) + ($LandingEnd - $LandingBegin))
        Write-Host ("The Video will be approximately " + $VidLength.ToString("hh\:mm\:ss") + " Long:")

        start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
    }
}

<#
    Idea for Further Development:
    - Add Trimming of Videos - Code as follows:
     .\ffmpeg.exe -ss 0 -i "D:\Cyclevision\2020.11.08.3\2020-11-08-solid.mp4" -t 510 -vcodec libx265 -crf 28 "D:\Cyclevision\2020.11.08.3\2020-11-08-solid-cut.mp4" -hwaccel cuda -hwaccel_output_format cuda -y 
    - Add Powershell GUI to give more Control (like in here https://theitbros.com/powershell-gui-for-scripts/)
    - Use FFMPEG Viewer to preview where video will start and end
#>

#Define Folder where to search for subfolders with Recordings
$SurveilanceFolder = "D:\Cyclevision\"
#Foreach Folder in C:\Cyclevision - start the Function to create a Video
foreach($folder in (get-childitem -path $SurveilanceFolder))
{
    #Create path to Folder
    $fp = ($SurveilanceFolder + $folder.Name)

    CreateCamVideo $fp
}
Write-host "Videocreation has finished" -BackgroundColor green
