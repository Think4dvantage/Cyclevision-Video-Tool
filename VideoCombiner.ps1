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
    $outputpath = ($InputFolder + "\" + $RecordDate + ".mp4")
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
    }
    
    #Get FrontView Video length by using ffprobe - to get an Idea what offset the Videos have (its everytime different) had to use cmd cause start-process wouldn't deliver me the return
    $frontViewSize = cmd /c ([char]34 + "$ffmpegProbePath" + [char]34 + " -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " + $frontOut)
    #Get Backview Video length to see how much the Backview video needs to be delayed
    $BackViewSize = cmd /c ([char]34 + "$ffmpegProbePath" + [char]34 + " -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 " + $BackOut)
    #Create Value of Offset as a string to use it in the Arguments of the Blending Command
    $VideoOffset = ($FrontViewSize - $BackViewSize).toString("#.###")
    #Make sure VideoOffset has 3 digits after the Comma 
    if($VideoOffset.Length -ne 5)
    {
        switch ($VideoOffset.Length) {
            4 { $VideoOffset = $VideoOffset + "0" }
            3 { $VideoOffset = $VideoOffset + "00" }
            1 { $VideoOffset = $VideoOffset + ".000" }
            Default {$VideoOffset = "2.000" }
        }
    }

    #Prepare FFMPEG Arguments to Blend the two videos together
    $ffmpegarguments = ("-i $frontout -itsoffset 00:00:0$VideoOffset -i $backout -filter_complex " + [char]34 + "[1:v] scale=550:-1, pad=1920:1080:ow-iw-1360:oh-ih-10, setsar=sar=1, format=rgba [bs]; [0:v] setsar=sar=1, format=rgba [fb]; [fb][bs] blend=all_mode=addition:all_opacity=0.7" + [char]34 + " -vcodec libx265 -crf 28 $outputpath -hwaccel cuda -hwaccel_output_format cuda -y")
    
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

    #Test if FrontView and Backview Video exist - if they exist delete the Sourcevideos
    if((test-path -path $frontout) -and (test-path -path $backout))
    {
        Remove-Item -Path $InputPath\* -Exclude ($RecordDate + "*")
    }
}
#Define Folder where to search for subfolders with Recordings
$SurveilanceFolder = "C:\Cyclevision\"
#Foreach Folder in C:\Cyclevision - start the Function to create a Video
foreach($folder in (get-childitem -path $SurveilanceFolder))
{
    #Create path to Folder
    $fp = ($SurveilanceFolder + $folder.Name)
    #Check if partlist.txt already exists - if it exists no Video creation needed
    if((get-childitem -path $fp).Name -like "*Partlist.txt")
    {
        Write-host "There is already a Video"
    }
    else 
    {
        CreateCamVideo $fp        
    }
}
Write-host "Videocreation has finished" -BackgroundColor green
