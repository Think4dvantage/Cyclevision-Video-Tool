#DotSource Functions
. ($PSScriptRoot + "\NewVideoCombiner.ps1")

#Import System.Windows.Forms to your Script
Add-Type -assembly System.Windows.Forms

#Space for Videofunctions
function create-Checkbox($name, $fromLeft, $fromTop, $AddTo)
{
    $CB = New-Object System.Windows.Forms.Checkbox
    $CB.Name = $name
    $CB.Width = 20
    $CB.Height = 20
    $CB.AutoSize = $false
    $CB.Location = New-Object System.Drawing.Point($fromLeft,$fromTop)
    
    $AddTo.Controls.Add($CB)
}
function create-Label($Text, $fromLeft, $fromTop, $AddTo)
{
    $LB = New-Object System.Windows.Forms.Label
    $LB.Text = $Text
    $LB.Location  = New-Object System.Drawing.Point($fromLeft,$fromTop)
    $LB.AutoSize = $true
    $AddTo.Controls.Add($LB)
}

function create-Timepick($Name, $Text, $fromLeft, $fromTop, $AddTo)
{
    $TP = New-Object System.Windows.Forms.DateTimePicker
    $TP.Name = $Name
    $TP.AutoSize = $true
    $TP.Format = [windows.forms.datetimepickerFormat]::time
    $TP.ShowUpDown = $true
    $TP.Size = New-Object System.Drawing.Size(120,23)
    $TP.Text = $Text
    $TP.Location = New-Object System.Drawing.Point($fromLeft,$fromTop)
    $AddTo.Controls.Add($TP)
}

function create-NumUpDown($Name, $Text, $fromLeft, $fromTop, $AddTo)
{
    $NB = New-Object System.Windows.Forms.NumericUpDown
    $NB.Name = $Name
    $NB.AutoSize = $true
    $NB.Size = New-Object System.Drawing.Size(100,23)
    $NB.Text = $Text
    $NB.Location = New-Object System.Drawing.Point($fromLeft,$fromTop)
    $AddTo.Controls.Add($NB)
}


#Import System.Windows.Forms to your Script
Add-Type -assembly System.Windows.Forms

#Getting Input on where the VideoFiles have been stored
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.SelectedPath = "D:\Cyclevision"
$null = $FolderBrowser.ShowDialog()
$SourcePath = $FolderBrowser.SelectedPath
$VideoFolders = get-childitem -Path $SourcePath -Directory

#Stitchstuff
$StitchIt = @()
foreach($Folder in $VideoFolders)
{
    $tag = $folder.Name.Replace(".","")
    
    $StitchIt = @{
        Date = $tag
        Path = $Folder.FullName
        Stitch = $true
    }
    create-Video @StitchIt
}

$main_form = New-Object System.Windows.Forms.Form
$GroupLocation = 0
$GroupHeight = 310

foreach($folder in $VideoFolders)
{
    $tag = $folder.Name.Replace(".","")
    $GPVideo = New-Object System.Windows.Forms.GroupBox
    $GPVideo.Name = ("GP" + $tag)
    $GPVideo.Width = 550
    $GPVideo.Height = $GroupHeight
    $GPVideo.Font = New-Object System.Drawing.Font("Times New Roman",12)
    $GPVideo.Location = New-Object System.Drawing.Point(3,$GroupLocation)
    
    $LBTitle = New-Object System.Windows.Forms.Label
    $LBTitle.Text = $folder.Name
    $LBTitle.Location = New-Object System.Drawing.Point(1,10)
    $LBTitle.font = New-Object System.Drawing.Font("Times New Roman",18,[System.Drawing.FontStyle]::Bold)
    $LBTitle.AutoSize = $true
    $GPVideo.Controls.Add($LBTitle)

    create-Checkbox -Name "Skip" -fromLeft 3 -FromTop 40 -AddTo $GPVideo
    create-Label -Text "Skip this" -FromLeft 20 -FromTop 40 -AddTo $GPVideo
    
    create-Checkbox -Name "Short" -FromLeft 140 -FromTop 40 -AddTo $GPVideo
    create-Label -Text "Short Video" -fromLeft 160 -fromTop 40 -AddTo $GPVideo
    
    create-Checkbox -Name "Solid" -FromLeft 270 -FromTop 40 -AddTo $GPVideo
    create-Label -Text "Solid Video" -fromLeft 290 -fromTop 40 -AddTo $GPVideo
    
    create-Checkbox -Name "Transparent" -FromLeft 390 -FromTop 40 -AddTo $GPVideo
    create-Label -Text "Transparent Video" -fromLeft 410 -fromTop 40 -AddTo $GPVideo

    create-Label -Text "Enter Start Begin" -fromLeft 3 -fromTop 70 -AddTo $GPVideo
    create-Timepick -Name "StartBegin" -Text "00:00:00" -fromLeft 150 -fromTop 70 -AddTo $GPVideo

    create-Label -Text "Enter Start End" -fromLeft 280 -fromTop 70 -AddTo $GPVideo
    create-Timepick -Name "StartEnd" -Text "00:01:00" -fromLeft 420 -fromTop 70 -AddTo $GPVideo

    create-Label -Text "Enter Landing Begin" -fromLeft 3 -fromTop 100 -AddTo $GPVideo
    create-Timepick -Name "LandingBegin" -Text "00:00:00" -fromLeft 150 -fromTop 100 -AddTo $GPVideo

    create-Label -Text "Enter Landing End" -fromLeft 280 -fromTop 100 -AddTo $GPVideo
    create-Timepick -Name "LandingEnd" -Text "00:01:00" -fromLeft 420 -fromTop 100 -AddTo $GPVideo

    create-Label -Text "Distance for Videoparts" -fromLeft 3 -fromTop 130 -AddTo $GPVideo
    create-Timepick -Name "Increment" -Text "00:02:00" -fromLeft 280 -fromTop 130 -AddTo $GPVideo

    create-Label -Text "Size of Videoparts (in s)" -fromLeft 3 -fromTop 160 -AddTo $GPVideo
    create-NumUpDown -Name "ClipLength" -Text 15 -fromLeft 280 -fromTop 160 -AddTo $GPVideo

    create-Label -Text "Must have Szenen" -fromLeft 3 -fromTop 187 -AddTo $GPVideo
    create-Label -Text "Beginn" -fromLeft 280 -fromTop 187 -AddTo $GPVideo
    create-Label -Text "Ende" -fromLeft 420 -fromTop 187 -AddTo $GPVideo

    create-Checkbox -Name "Szene1" -FromLeft 3 -FromTop 210 -AddTo $GPVideo
    create-Label -Text "Szene 1" -fromLeft 23 -fromTop 210 -AddTo $GPVideo
    create-Timepick -Name "Szene1Begin" -Text "00:00:00" -fromLeft 280 -fromTop 210 -AddTo $GPVideo
    create-Timepick -Name "Szene1End" -Text "00:00:00" -fromLeft 420 -fromTop 210 -AddTo $GPVideo

    create-Checkbox -Name "Szene2" -FromLeft 3 -FromTop 240 -AddTo $GPVideo
    create-Label -Text "Szene 2" -fromLeft 23 -fromTop 240 -AddTo $GPVideo
    create-Timepick -Name "Szene2Begin" -Text "00:00:00" -fromLeft 280 -fromTop 240 -AddTo $GPVideo
    create-Timepick -Name "Szene2End" -Text "00:00:00" -fromLeft 420 -fromTop 240 -AddTo $GPVideo

    create-Checkbox -Name "Szene3" -FromLeft 3 -FromTop 270 -AddTo $GPVideo
    create-Label -Text "Szene 3" -fromLeft 23 -fromTop 270 -AddTo $GPVideo
    create-Timepick -Name "Szene3Begin" -Text "00:00:00" -fromLeft 280 -fromTop 270 -AddTo $GPVideo
    create-Timepick -Name "Szene3End" -Text "00:00:00" -fromLeft 420 -fromTop 270 -AddTo $GPVideo

    $main_form.Controls.Add($GPVideo)
    $GroupLocation = $GroupLocation + $GroupHeight
}

$main_form.Text ='Cyclevision Videostitcher'
$main_form.AutoSize = $true
$main_form.Width = 720
$main_form.Height = 720
$main_form.AutoScroll = $true

function BTNRUN()
{
    $Dataoutput = @()
        foreach($Folder in $VideoFolders)
        {
            $tag = $folder.Name.Replace(".","")
            
            $Dataoutput = @{
                Date = $tag
                Path = $Folder.FullName
                Skip = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Skip"}).Checked
                Stitch = $false
                Short = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Short"}).Checked
                Solid = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Solid"}).Checked
                Transparent = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Transparent"}).Checked
                StartBegin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "StartBegin"}).Text
                StartEnd = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "StartEnd"}).Text
                LandingBegin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "LandingBegin"}).Text
                LandingEnd = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "LandingEnd"}).Text
                Increment = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Increment"}).Text
                ClipLength = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "ClipLength"}).Text
                Szene1 = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene1"}).Checked
                Szene1Begin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene1Begin"}).Text
                Szene1End = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene1End"}).Text
                Szene2 = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene2"}).Checked
                Szene2Begin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene2Begin"}).Text
                Szene2End = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene2End"}).Text
                Szene3 = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene3"}).Checked
                Szene3Begin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene3Begin"}).Text
                Szene3End = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Szene3End"}).Text

            }
            create-Video @Dataoutput
        }
}

#Add Button to run ffmpeg
$BTNrun = New-Object System.Windows.Forms.Button
$BTNrun.Size = New-Object System.Drawing.Size(120,23)
$BTNrun.Text = "RUN"
$BTNrun.Location = New-Object System.Drawing.Point(560,10)

$BTNrun.Add_Click(
    {
        BTNRUN
    }
)

$main_form.Controls.Add($BTNrun)
$main_form.ShowDialog()

