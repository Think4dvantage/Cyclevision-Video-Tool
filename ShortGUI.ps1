. ($PSScriptRoot + "\lib.ps1")
Add-Type -assembly System.Windows.Forms

$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.SelectedPath = "D:\"
$null = $FolderBrowser.ShowDialog()
write-host $FolderBrowser.SelectedPath

$main_form = New-Object System.Windows.Forms.Form

$main_form.Text ='Video Shortener'
$main_form.AutoSize = $true
$main_form.Width = 720
$main_form.Height = 720
$main_form.AutoScroll = $true

function new-shortForm($title)
{
    $short_form = New-Object System.Windows.Forms.Form

    $short_form.Text = $title
    $short_form.AutoSize = $true
    $short_form.Width = 720
    $short_form.Height = 400
    $short_form.AutoScroll = $true
    return $short_form
}
$FromTopIncrementor = 3

#Add Elements
create-label "Video Folder selected:" 3 $FromTopIncrementor $main_form
create-Label $FolderBrowser.SelectedPath 150 $FromTopIncrementor $main_form
#$FolderButton = create-button "Change Folder" 120 23 200 3 $main_form
#$folderButton.add_click( {$null = $FolderBrowser.ShowDialog()})
$VideoFiles = get-childitem -path $FolderBrowser.SelectedPath -Filter "*.mp4"
foreach($Video in $VideoFiles)
{
    $FromTopIncrementor = $FromTopIncrementor + 30
    $btn = create-button $Video.Name 300 23 3 $FromTopIncrementor $main_form
    $btn.add_click( 
        { 
            $main_form.Close()
            $form = new-shortform($video.name)
            create-label "Video selected:" 3 3 $form
            create-label $Video.Name 200 3 $form
            create-label "Select Resulting Video Length:" 3 23 $form
            create-Timepick "ResultLength" "00:05:00" 200 23 $form
            create-label "Select Increment Length:" 3 43 $form
            create-Timepick "Increment" "00:00:10" 200 43 $form
            $short_btn = (create-button "Run Shortener" 300 23 200 63 $form)
            $short_btn.add_click(
                {
                    $Increment = ($form.Controls | where-object {$_.Name -like "Increment"}).Text
                    $ResultLength = ($form.Controls | where-object {$_.Name -like "ResultLength"}).Text
                    create-shortVid $Video.FullName $Increment $ResultLength
                    write-host $short_btn 
                }
            
            )
            $short_btn = 0
            $form.ShowDialog()           
        }
                    
    )
    $btn = 0
}

<#
    $BT.Add_Click(
    {
        BTNRUN
    }
    )

#>

$main_form.ShowDialog()