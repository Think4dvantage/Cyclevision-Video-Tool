    #Path to the FFMPEG Binary (needs to be downloaded from ffmpeg)
    $ffmpegPath = "C:\Program Files\ffmpeg\ffmpeg.exe"

    #Path to the Output of the Stitching of FrontParts
    $frontOut = "D:\Cyclevision\2021.01.08.1\2021-01-08-Frontview.mp4"
    $backOut = "D:\Cyclevision\2021.01.08.1\2021-01-08-Backview.mp4"
    $outputshort = "D:\Cyclevision\2021.01.08.1\2021-01-08-SHORT.mp4"
    $VideoOffset = "2.000"

    $StartBegin = 40 #read-host "Please Input the Beginning of the Start"
    $StartEnd = 65 #read-host "Please Input the End of the Start"
    $LandingBegin = 1700 #read-host "Please Input the Beginning of the Landing"
    $LandingEnd = 1775 #read-host

    $ffmpegarguments = ("-i $frontout -i $backout -filter_complex " + [char]34 + "[1]trim="+ ($startBegin-$VideoOffset) + ":" + ($StartEnd-$VideoOffset) +",setpts=PTS-STARTPTS[bs],[bs]scale=550:-1[bso];[0]atrim=" + $StartBegin + ":" + $StartEnd + ",asetpts=PTS-STARTPTS[ap1],[0]trim=" + $StartBegin + ":" + $StartEnd + ",setpts=PTS-STARTPTS[fv],[fv][bso] overlay=10:760[p1],")
    $parts = 1
    $Inc = 120
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
    $ffmpegarguments = ($ffmpegarguments + "[p" + $parts + "][ap" + $parts + "]concat=n=" + $parts + ":v=1:a=1[out][aout]" + [char]34 + " -map " + [char]34 + "[out]" + [char]34 + " -map " + [char]34 + "[aout]" + [char]34 +" $outputshort -hwaccel cuda -hwaccel_output_format cuda -y")

    start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
    write-host "DONE" -BackgroundColor green
    exit

