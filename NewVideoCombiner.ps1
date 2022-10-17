function create-Video {
    [CmdletBinding()]
    param (
        $Date,
        $Path,
        $Stitch,
        $Skip,
        $Short,
        $Solid,
        $Transparent,
        $StartBegin,
        $StartEnd,
        $LandingBegin,
        $LandingEnd,
        $Increment,
        $ClipLength,
        $Szene1,
        $Szene1Begin,
        $Szene1End,
        $Szene2,
        $Szene2Begin,
        $Szene2End,
        $Szene3,
        $Szene3Begin,
        $Szene3End
    )
    
    process 
    {
        if($Skip -eq $true)
        {
            write-host ("Folder " + $Path + " was Skipped due to SKIP Parameter!")
            return
        }

        #Path to the FFMPEG Binary (needs to be downloaded from ffmpeg)
        $ffmpegPath = $PSScriptRoot + "\ffmpeg\ffmpeg.exe"
        #Path to the FFProbe Binary (in the same download as the ffmpeg download)
        $ffmpegProbePath = $PSScriptRoot + "\ffmpeg\ffprobe.exe"
        #Path to the Output of the Stitching of FrontParts
        $frontOut = ($Path + "\" + $Date + "-Frontview.mp4")
        #Path to the Output of the Short Video
        $outputshort = $Path + "\" + $Date + "-short.mp4"

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
        
        #Path to the Txt file containing the Parts for later Stitching
        $InputFilePath = ($Path + "\PartList.txt")

        #Check if Fronview and Backview Video have been Stitched together - if they are skip this Step
        if(!(test-path -path $frontout))
        {
            #Trigger createInputFunction and write output to InputFilePath
            set-content -path $InputFilePath -Value (createInputfile $Path "F")
            #Stitch together all MP4 Files mentioned in the Input File Path
            start-process -FilePath $ffmpegPath -ArgumentList "-f concat -safe 0 -i $InputFilePath -c copy $frontOut -y" -PassThru -Wait -NoNewWindow
            #Trigger createInputFunction to get Backview Parts and write it to InputFile
            
            #Test if FrontView and Backview Video exist - if they exist delete the Sourcevideos
            if((test-path -path $frontout))
            {
                Remove-Item -Path ($Path + "\*") -Exclude ($Date + "*") -Recurse -Force
            }
        }
        else 
        {
            write-host ($Date + " - Front and Backout have been created skipping Stitching.")   
        }

        if($Stitch -eq $true)
        {
            Write-host ($Date + " - Stitch only is active progressing with next Folder!")
            return 
        }

        $StartBegin = [int]([timespan]$StartBegin).TotalSeconds
        $StartEnd = [int]([timespan]$StartEnd).TotalSeconds
        $LandingBegin = [int]([timespan]$LandingBegin).TotalSeconds
        $LandingEnd = [int]([timespan]$LandingEnd).TotalSeconds
        $Increment = [int]([timespan]$Increment).TotalSeconds

        $tmpfront = ($path + "\frontlen")
        write-host "getting VideoSize"
        start-process -FilePath $ffmpegProbePath -ArgumentList ("-v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " + $frontOut) -NoNewWindow -RedirectStandardOutput $tmpfront
        start-sleep -seconds 1
        $frontViewSize = get-content -Path $tmpfront
        if($frontViewSize)
        {
            remove-item -path $tmpfront
        }
        #Create Value of Offset as a string to use it in the Arguments of the Blending Command
        write-host $frontviewSize

        if($Short -eq $true -and !(test-path $outputshort))
        {
            write-host "got into the Shortvideo"
            if($StartEnd -le $StartBegin -or $LandingEnd -le $LandingBegin)
            {
                Write-host ($Date + " - Check StartBegin, StartEnd and so on")
                return
            }
            write-host "Starting to Create Arguments"
            $ffmpegarguments = ("-i $frontout -i $backout -filter_complex " + [char]34 + "[1]trim="+ ($startBegin-$VideoOffset) + ":" + ($StartEnd-$VideoOffset) +",setpts=PTS-STARTPTS[bs],[bs]scale=550:-1[bso];[0]atrim=" + $StartBegin + ":" + $StartEnd + ",asetpts=PTS-STARTPTS[ap1],[0]trim=" + $StartBegin + ":" + $StartEnd + ",setpts=PTS-STARTPTS[fv],[fv][bso] overlay=10:760[p1],")
            [int[]]$ClipsBegin = @()
            [int[]]$ClipsEnd = @()
            if($Szene1 -eq $true)
            {
                $ClipsBegin += [int]([timespan]$Szene1Begin).TotalSeconds
                $ClipsEnd += [int]([timespan]$Szene1End).TotalSeconds
                write-host ("Szene 1: " + $ClipsBegin[0] + "-" + $ClipsEnd[0])
            }
            if($Szene2 -eq $true)
            {
                $ClipsBegin += ([timespan]$Szene2Begin).TotalSeconds
                $ClipsEnd += ([timespan]$Szene2End).TotalSeconds
                write-host ("Szene 2: " + $ClipsBegin[1] + "-" + $ClipsEnd[1])
            }
            if($Szene3 -eq $true)
            {
                $ClipsBegin += [int]([timespan]$Szene3Begin).TotalSeconds
                $ClipsEnd += [int]([timespan]$Szene3End).TotalSeconds
                write-host ("Szene 3: " + $ClipsBegin[2] + "-" + $ClipsEnd[2])
            }

            $ClipsBegin += $LandingBegin
            $ClipsEnd += $LandingEnd
            $ClipsBegin += $StartBegin
            $ClipsEnd += $StartEnd
            write-host "pre PartInc Parts"
            write-host $ClipsBegin
            write-host $ClipsEnd
            
            $partStart = $StartBegin + $Increment
            write-host "incrementing through parts"
            do 
            {
                $partEnd = $partStart + $CLipLength
                $ClipOK = $true
                for ($i = 0; $i -lt $ClipsBegin.Count; $i++) 
                {
                    if($PartStart -lt ($ClipsBegin[$i] -30) -or $PartStart -gt ($ClipsEnd[$i] + 30) -or $PartEnd -lt ($ClipsBegin[$i] - 30) -or $PartEnd -gt ($ClipsEnd[$i] + 30))
                    {
                        
                    }
                    else
                    {
                        $ClipOK = $false
                    }
                }
                if($ClipOK -eq $true)
                {
                    $ClipsBegin += $PartStart
                    $ClipsEnd += $PartEnd
                    Write-Host ("Partstart: " + $PartStart + " PartEnd: " + $partEnd)
                }
                $partStart = $partStart + $Increment  
            } while ($PartStart -lt $LandingBegin)
            
            $ClipsBegin = $ClipsBegin | Sort-Object
            $ClipsEnd = $ClipsEnd | Sort-Object
            
            write-host $ClipsBegin
            write-host $ClipsEnd
            
            $PartCounter = 2
            for ($i = 1; $i -lt $ClipsBegin.Count; $i++) 
            {
                $ffmpegarguments = ($ffmpegarguments + "[0]atrim=" + $ClipsBegin[$i] + ":" + $ClipsEnd[$i] +",asetpts=PTS-STARTPTS[ap"+ $PartCounter +"]," + "[0]trim=" + $ClipsBegin[$i] + ":" + $ClipsEnd[$i] +",setpts=PTS-STARTPTS[p"+ $PartCounter +"],")
                $PartCounter++
            }
            write-host "Parts created, create end of Video"
            for ($i = 1; $i -lt ($ClipsBegin.Count + 1); $i++) 
            {
                $ffmpegarguments = ($ffmpegarguments + "[p" + $i + "][ap" + $i + "]")
            }
            $ffmpegarguments = ($ffmpegarguments + "concat=n=" + $ClipsBegin.Count + ":v=1:a=1[out][aout]" + [char]34 + " -map " + [char]34 + "[out]" + [char]34 + " -map " + [char]34 + "[aout]" + [char]34 +" $outputshort -af " + [char]34 +"highpass=f=300, lowpass=f=2000, loudnorm" + [char]34 + " -hwaccel cuda -hwaccel_output_format cuda -y")
            
            $VidLength = [timespan]::fromseconds([int]($StartEnd - $StartBegin) + ((($LandingBegin - $StartEnd)/$Increment)*15) + ($LandingEnd - $LandingBegin))
            Write-Host ($Date + " - The Video will be approximately " + $VidLength.ToString("hh\:mm\:ss") + " Long:") -BackgroundColor Yellow -ForegroundColor Black
            write-host $ffmpegArguments
            start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
            write-host "ShortVideo has ended" -BackgroundColor Green -ForegroundColor Black
        }#End ShortVideo

    }#End Process
    
}


write-host "NewVideoCombiner imported"