#Space for Videofunctions



#Import System.Windows.Forms to your Script
Add-Type -assembly System.Windows.Forms

#Getting Input on where the VideoFiles have been stored
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.SelectedPath = "D:\Cyclevision"
$null = $FolderBrowser.ShowDialog()
$SourcePath = $FolderBrowser.SelectedPath

$VideoFolders = get-childitem -Path $SourcePath -Directory

$main_form = New-Object System.Windows.Forms.Form
$GroupLocation = 0
$GroupHeight = 200
$Dataoutput = @()

foreach($folder in $VideoFolders)
{
    $tag = $folder.Name.Replace(".","")
    $GPVideo = New-Object System.Windows.Forms.GroupBox
    $GPVideo.Name = ("GP" + $tag)
    $GPVideo.Width = 990
    $GPVideo.Height = $GroupHeight
    $GPVideo.Font = New-Object System.Drawing.Font("Times New Roman",12)
    $GPVideo.Location = New-Object System.Drawing.Point(3,$GroupLocation)
    
    $LBTitle = New-Object System.Windows.Forms.Label
    $LBTitle.Text = $folder.Name
    $LBTitle.Location = New-Object System.Drawing.Point(1,10)
    $LBTitle.font = New-Object System.Drawing.Font("Times New Roman",18,[System.Drawing.FontStyle]::Bold)
    $LBTitle.AutoSize = $true

    $CBStitchOnly = New-Object System.Windows.Forms.Checkbox
    $CBStitchOnly.Name = ("Stitch")
    $CBStitchOnly.Width = 20
    $CBStitchOnly.Height = 20
    $CBStitchOnly.AutoSize = $false
    $CBStitchOnly.Location = New-Object System.Drawing.Point(3,40)

    $LBstitchOnlyCB = New-Object System.Windows.Forms.Label
    $LBstitchOnlyCB.Text = "Stitch Only"
    $LBstitchOnlyCB.Location  = New-Object System.Drawing.Point(20,40)
    $LBstitchOnlyCB.AutoSize = $true

    $CBShortVideo = New-Object System.Windows.Forms.Checkbox
    $CBShortVideo.Name = ("Short")
    $CBShortVideo.AutoSize = $false
    $CBShortVideo.Width = 20
    $CBShortVideo.Height = 20
    $CBShortVideo.Location = New-Object System.Drawing.Point(150,40)

    $LBShortVideoCB = New-Object System.Windows.Forms.Label
    $LBShortVideoCB.Text = "Short Video"
    $LBShortVideoCB.Location  = New-Object System.Drawing.Point(170,40)
    $LBShortVideoCB.AutoSize = $true

    $CBSolid = New-Object System.Windows.Forms.Checkbox
    $CBSolid.Name = ("Solid")
    $CBSolid.AutoSize = $false
    $CBSolid.Width = 20
    $CBSolid.Height = 20
    $CBSolid.Location = New-Object System.Drawing.Point(280,40)

    $LBSolidCB = New-Object System.Windows.Forms.Label
    $LBSolidCB.Text = "Solid Video"
    $LBSolidCB.Location  = New-Object System.Drawing.Point(300,40)
    $LBSolidCB.AutoSize = $true

    $CBTrans = New-Object System.Windows.Forms.Checkbox
    $CBTrans.Name = ("Transparent")
    $CBTrans.AutoSize = $false
    $CBTrans.Width = 20
    $CBTrans.Height = 20
    $CBTrans.Location = New-Object System.Drawing.Point(400,40)

    $LBTransCB = New-Object System.Windows.Forms.Label
    $LBTransCB.Text = "Transparent Video"
    $LBTransCB.Location  = New-Object System.Drawing.Point(420,40)
    $LBTransCB.AutoSize = $true

    $LBStartBeginTP = New-Object System.Windows.Forms.Label
    $LBStartBeginTP.Text = "Enter Start Begin"
    $LBStartBeginTP.Location  = New-Object System.Drawing.Point(3,70)
    $LBStartBeginTP.AutoSize = $true

    $TPStartBegin = New-Object System.Windows.Forms.DateTimePicker
    $TPStartBegin.Name = ("StartBegin")
    $TPStartBegin.AutoSize = $true
    $TPStartBegin.Format = [windows.forms.datetimepickerFormat]::time
    $TPStartBegin.ShowUpDown = $true
    $TPStartBegin.Size = New-Object System.Drawing.Size(120,23)
    $TPStartBegin.Text = "00:01:00"
    $TPStartBegin.Location = New-Object System.Drawing.Point(150,70)

    $LBStartEndTP = New-Object System.Windows.Forms.Label
    $LBStartEndTP.Text = "Enter Start End"
    $LBStartEndTP.Location  = New-Object System.Drawing.Point(280,70)
    $LBStartEndTP.AutoSize = $true

    $TPStartEnd = New-Object System.Windows.Forms.DateTimePicker
    $TPStartEnd.Name = ("StartEnd")
    $TPStartEnd.AutoSize = $true
    $TPStartEnd.Format = [windows.forms.datetimepickerFormat]::time
    $TPStartEnd.ShowUpDown = $true
    $TPStartEnd.Size = New-Object System.Drawing.Size(120,23)
    $TPStartEnd.Text = "00:01:30"
    $TPStartEnd.Location = New-Object System.Drawing.Point(420,70)

    $LBLandingBeginTP = New-Object System.Windows.Forms.Label
    $LBLandingBeginTP.Text = "Enter Landing Begin"
    $LBLandingBeginTP.Location  = New-Object System.Drawing.Point(3,100)
    $LBLandingBeginTP.AutoSize = $true

    $TPLandingBegin = New-Object System.Windows.Forms.DateTimePicker
    $TPLandingBegin.Name = ("LandingBegin")
    $TPLandingBegin.AutoSize = $true
    $TPLandingBegin.Format = [windows.forms.datetimepickerFormat]::time
    $TPLandingBegin.ShowUpDown = $true
    $TPLandingBegin.Size = New-Object System.Drawing.Size(120,23)
    $TPLandingBegin.Text = "00:01:00"
    $TPLandingBegin.Location = New-Object System.Drawing.Point(150,100)

    $LBLandingEndTP = New-Object System.Windows.Forms.Label
    $LBLandingEndTP.Text = "Enter Landing End"
    $LBLandingEndTP.Location  = New-Object System.Drawing.Point(280,100)
    $LBLandingEndTP.AutoSize = $true

    $TPLandingEnd = New-Object System.Windows.Forms.DateTimePicker
    $TPLandingEnd.Name = ("LandingEnd")
    $TPLandingEnd.AutoSize = $true
    $TPLandingEnd.Format = [windows.forms.datetimepickerFormat]::time
    $TPLandingEnd.ShowUpDown = $true
    $TPLandingEnd.Size = New-Object System.Drawing.Size(120,23)
    $TPLandingEnd.Text = "00:01:30"
    $TPLandingEnd.Location = New-Object System.Drawing.Point(420,100)
    
    $GPVideo.Controls.Add($LBTitle)
    $GPVideo.Controls.Add($CBStitchOnly)
    $GPVideo.Controls.Add($LBstitchOnlyCB)
    $GPVideo.Controls.Add($CBShortVideo)
    $GPVideo.Controls.Add($LBShortVideoCB)
    $GPVideo.Controls.Add($CBSolid)
    $GPVideo.Controls.Add($LBSolidCB)
    $GPVideo.Controls.Add($CBTrans)
    $GPVideo.Controls.Add($LBTransCB)
    $GPVideo.Controls.Add($LBStartBeginTP)
    $GPVideo.Controls.Add($TPStartBegin)
    $GPVideo.Controls.Add($LBStartEndTP)
    $GPVideo.Controls.Add($TPStartEnd)
    $GPVideo.Controls.Add($LBLandingBeginTP)
    $GPVideo.Controls.Add($TPLandingBegin)
    $GPVideo.Controls.Add($LBLandingEndTP)
    $GPVideo.Controls.Add($TPLandingEnd)

    $main_form.Controls.Add($GPVideo)
    $GroupLocation = $GroupLocation + $GroupHeight
}

$main_form.Text ='Cyclevision Videocombiner'
$main_form.AutoSize = $true
$main_form.Width = 1000
$main_form.Height = 1000

#Add Button to run ffmpeg
$BTNrun = New-Object System.Windows.Forms.Button
$BTNrun.Size = New-Object System.Drawing.Size(120,23)
$BTNrun.Text = "RUN"
$BTNrun.Location = New-Object System.Drawing.Point(600,400)

$BTNrun.Add_Click(
    {
        foreach($Folder in $VideoFolders)
        {
            $tag = $folder.Name.Replace(".","")
            
            $Dataoutput = [PSCustomObject] @{
                Path = $Folder.FullName
                Stitch = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Stitch"}).Checked
                Short = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Short"}).Checked
                Solid = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Solid"}).Checked
                Transparent = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "Transparent"}).Checked
                StartBegin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "StartBegin"}).Text
                StartEnd = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "StartEnd"}).Text
                LandingBegin = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "LandingBegin"}).Text
                LandingEnd = (($main_form.Controls | where-object {$_.Name -eq ("GP" + $tag)}).Controls | where-object {$_.Name -like "LandingEnd"}).Text
            }
        }
        $main_form.Close()
    }
)

$main_form.Controls.Add($BTNrun)

$main_form.ShowDialog()
