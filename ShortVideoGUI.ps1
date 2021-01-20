#Initialize Form
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='ShortVideoInput'
$main_form.Width = 1000
$main_form.Height = 1000
$main_form.AutoSize = $true




$Label0 = New-Object System.Windows.Forms.Label
$Label0.Text = "Path to Frontview File"
$Label0.Location  = New-Object System.Drawing.Point(0,10)
$Label0.AutoSize = $true


$TextBox0 = New-Object System.Windows.Forms.TextBox
$TextBox0.Location  = New-Object System.Drawing.Point(200,10)
$TextBox0.Size = New-Object System.Drawing.Size(220,23)
$TextBox0.AutoSize = $true

$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Beginning of Start (in Seconds)"
$Label1.Location  = New-Object System.Drawing.Point(0,30)
$Label1.AutoSize = $true

$TextBox1 = New-Object System.Windows.Forms.TextBox
$TextBox1.Location  = New-Object System.Drawing.Point(300,30)
$TextBox1.Size = New-Object System.Drawing.Size(120,23)
$TextBox1.AutoSize = $true
$TextBox1.Name = ""

$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "End of Start (in Seconds)"
$Label2.Location  = New-Object System.Drawing.Point(0,50)
$Label2.AutoSize = $true

$TextBox2 = New-Object System.Windows.Forms.TextBox
$TextBox2.Location  = New-Object System.Drawing.Point(300,50)
$TextBox2.Size = New-Object System.Drawing.Size(120,23)
$TextBox2.AutoSize = $true

$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = "Beginning of Landing (in Seconds)"
$Label3.Location  = New-Object System.Drawing.Point(0,70)
$Label3.AutoSize = $true

$TextBox3 = New-Object System.Windows.Forms.TextBox
$TextBox3.Location  = New-Object System.Drawing.Point(300,70)
$TextBox3.Size = New-Object System.Drawing.Size(120,23)
$TextBox3.AutoSize = $true

$Label4 = New-Object System.Windows.Forms.Label
$Label4.Text = "End of Landing (in Seconds)"
$Label4.Location  = New-Object System.Drawing.Point(0,90)
$Label4.AutoSize = $true

$TextBox4 = New-Object System.Windows.Forms.TextBox
$TextBox4.Location  = New-Object System.Drawing.Point(300,90)
$TextBox4.Size = New-Object System.Drawing.Size(120,23)
$TextBox4.AutoSize = $true

#Add Button to run ffmpeg
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Location = New-Object System.Drawing.Size(300,110)
$Button1.Size = New-Object System.Drawing.Size(120,23)
$Button1.Text = "CreateShortVideo"

$Button1.Add_Click(
    {
        write-host $TextBox0.Text
        write-host $TextBox1.Text
        write-host $TextBox2.Text
        write-host $TextBox3.Text
        write-host $TextBox4.Text
    }
)

$main_form.Controls.Add($Label0)
$main_form.Controls.Add($Label1)
$main_form.Controls.Add($Label2)
$main_form.Controls.Add($Label3)
$main_form.Controls.Add($Label4)
$main_form.Controls.Add($Button1)
$main_form.Controls.Add($TextBox0)
$main_form.Controls.Add($TextBox1)
$main_form.Controls.Add($TextBox2)
$main_form.Controls.Add($TextBox3)
$main_form.Controls.Add($TextBox4)
$main_form.Controls.Add($FileBrowser)
$main_form.ShowDialog()

