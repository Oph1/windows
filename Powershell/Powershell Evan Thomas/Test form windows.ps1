
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(400,400)
$form.Text = "form windows d'essai"
$form.StartPosition = 'CenterScreen'

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(130,60)
$listBox.Size = New-Object System.Drawing.Size(220,230)
$form.Controls.Add($listBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Size = New-Object System.Drawing.size(80,23)
$okButton.Location = New-Object System.Drawing.Point(160,300)
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Size = New-Object System.Drawing.Size(250,40)
$label.Text = "May the force be with you... choose your side : "
$form.Controls.Add($label)

$checkBox1.Location = New-Object System.Drawing.Point(30,70)
$checkBox1.Size = New-Object System.Drawing.Size(90,30)
$checkBox1.Name = "checkBox1"
$checkBox1.Text = "light side"
$form.Controls.Add($checkBox1)

$checkBox2.Location = New-Object System.Drawing.Point(30,110)
$checkBox2.Size = New-Object System.Drawing.Size(90,30)
$checkBox2.Name = "checkBox2"
$checkBox2.Text = "dark side"
$form.Controls.Add($checkBox2)

$checkBox1 = New-Object System.Windows.Forms.CheckBox
$checkBox2 = New-Object System.Windows.Forms.CheckBox

$b1= $false
$b2= $false

$handler_okButton_Click= 
{

    $listBox1.Items.Clear();    

    if ($checkBox1.Checked)     {  $listBox1.Items.Add( "Light side choosen"  ) }

    if ($checkBox2.Checked)     {  $listBox1.Items.Add( "Dark side choosen"   ) }

}

$okButton_info.Add_Click({
$Popup=New-Object System.Windows.Forms.Form
$Popup.Size = ‘400,400’
$Popup.Text = "Vos Informations"
$Popup.StartPosition = "CenterScreen"
$Popup.Visible = $true
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Renseignez tous les champs!"
$Label.AutoSize = $true
$Label.Location = ‘15,30’
$Label.Font = ‘Arial,9’
$Popup.Controls.Add($label)
$label_winid = New-Object System.Windows.Forms.Label
$label_winid.AutoSize = $true
$label_winid.Location = New-Object System.Drawing.Point(20,130)
$label_winid.Name = 'Identifiants Windows'
$label_winid.Size = New-Object System.Drawing.Size(100,20)
$label_winid.Text = "Identifiants Windows"
})


$result = $form.ShowDialog()