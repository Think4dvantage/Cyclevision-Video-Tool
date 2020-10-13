function CreateCamVideo($InputFolder)
{
    function createInputfile($Path, $View)
    {
        $out = @()
        $FileNames = (get-childitem -Path $Path\* -Include ($View + "_*")).Versioninfo.Filename
        foreach($file in $filenames)
        {
            $out += ("file '" + $file + "'") 
        }
        return $out
    }

    $RecordDate = ((get-childitem -Path $InputFolder\* -Include ("F_*"))[0].LastWriteTime).ToString("yyyy-MM-dd")
    $InputFilePath = ($InputFolder + "\PartList.txt")
    $frontOut = ($InputFolder + "\Frontview.mp4")
    $backOut = ($InputFolder + "\BackView.mp4")
    $outputpath = ($InputFolder + "\" + $RecordDate + ".mp4")

    $ffmpegPath = "C:\Program Files\ffmpeg\ffmpeg.exe"

    set-content -path $InputFilePath -Value (createInputfile $InputFolder "F")
    start-process -FilePath $ffmpegPath -ArgumentList "-f concat -safe 0 -i $InputFilePath -c copy $frontOut -y" -PassThru -Wait -NoNewWindow
    set-content -path $InputFilePath -Value (createInputfile $InputFolder "B")
    start-process -FilePath $ffmpegPath -ArgumentList "-f concat -safe 0 -i $InputFilePath -c copy $backOut -y" -PassThru -Wait -NoNewWindow

    $ffmpegarguments = ("-i $frontout -itsoffset 00:00:02.370 -i $backout -filter_complex " + [char]34 + "[1:v] scale=550:-1, pad=1920:1080:ow-iw-1360:oh-ih-10, setsar=sar=1, format=rgba [bs]; [0:v] setsar=sar=1, format=rgba [fb]; [fb][bs] blend=all_mode=addition:all_opacity=0.7" + [char]34 + " -vcodec libx265 -crf 26 $outputpath -hwaccel cuda -hwaccel_output_format cuda -y")
    start-process -FilePath $ffmpegPath -ArgumentList $ffmpegarguments -PassThru -wait -nonewWindow
}

$SurveilanceFolder = "C:\Cyclevision\"

foreach($folder in (get-childitem -path $SurveilanceFolder))
{
    $fp = ($SurveilanceFolder + $folder.Name)
    if((get-childitem -path $fp).Name -notcontains "Partlist.txt")
    {
        CreateCamVideo $fp
    }
    else 
    {
        Write-host "Video already produced - i guess"    
    }
}

