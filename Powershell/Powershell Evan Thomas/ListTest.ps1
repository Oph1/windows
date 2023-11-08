Clear-Host
Set-PSDebug -Strict
Remove-Variable * -ErrorAction SilentlyContinue

Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(300,400)
$flp = New-Object System.Windows.Forms.FlowLayoutPanel
$flp.Location = New-Object System.Drawing.Size(10,60)
#$flp.AutoScroll = $true
#$flp.DefaultMaximumSize = 
$form.Controls.Add($flp)

#Let's say you read the following values from file
#$array = ("Lorem", "Ipsum", "Dolor") 
$array = new-object 'System.Collections.Generic.List[string]'
$array.Add("Lorem")
$array.Add("Ipsum")
$array.Add("Dolor")

$i = 0
$array | % {
    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Text = $_
    $checkBox.Name = "checkBox$_"
    $flp.Controls.Add($checkBox)
    #$checkBox.Add_CheckedChanged({
    #    $index = $flp.Controls.IndexOf($this)
    #    $name = $this.Name
    #    $text = $this.Text
    #    $value = $this.Checked
    #    #[System.Windows.Forms.MessageBox]::Show("Index: $index" +"`n" + "Name: $name" + "`n" + "Text: $text" + "`n" + "Value: $value" + "`n")
    #    #$((Get-Variable -name $name).Value).Checked = $this.Checked
    #})

    New-Variable -name checkBox$_ -Value $checkBox

    $i++
}



$arraySelect = new-object 'System.Collections.Generic.List[string]'
$arraySelect.Add("Lorem")
$arraySelect.Add("Dolor")

$i = 0
$arraySelect | % {
    Write-Host "Cocher" $_
    
    $((Get-Variable -name checkBox$_).Value).Checked = $true


    $i++
}



$form.ShowDialog()
$form.Dispose()

$i = 0
$array | % {
    Write-Host "Cocher" $_ " : "
    $i++
}