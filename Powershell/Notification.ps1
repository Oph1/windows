#win10 messaging :: build 28/seagull
#uses research from martin bengtsson, michael mccool, ben whitmore, kelvin tegelaar, trevor jones, jon north

write-host "Send a branded message to Windows 10 devices"
write-host "============================================"

########### FUNCTION JUNCTION #############

function getProxyData {
    if (([IntPtr]::size) -eq 4) {$configLoc="$env:SystemDrive\Program Files\CentraStage\CagService.exe.config"} else {$configLoc="$env:SystemDrive\Program Files (x86)\CentraStage\CagService.exe.config"}
	[xml]$varPlatXML= get-content "$configLoc" -ErrorAction SilentlyContinue
	$script:varProxyLoc=($varPlatXML.configuration.applicationSettings."CentraStage.Cag.Core.AppSettings".setting | Where-Object {$_.Name -eq 'ProxyIp'}).value
    $script:varProxyPort=($varPlatXML.configuration.applicationSettings."CentraStage.Cag.Core.AppSettings".setting | Where-Object {$_.Name -eq 'ProxyPort'}).value
}

function downloadFile { #downloadFile build 31/seagull :: copyright datto, inc.

    param (
        [parameter(mandatory=$false)]$url,
        [parameter(mandatory=$false)]$whitelist,
        [parameter(mandatory=$false)]$filename,
        [parameter(mandatory=$false,ValueFromPipeline=$true)]$pipe
    )

    function setUserAgent {
        $script:WebClient = New-Object System.Net.WebClient
    	$script:webClient.UseDefaultCredentials = $true
        $script:webClient.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
        $script:webClient.Headers.Add([System.Net.HttpRequestHeader]::UserAgent, 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)');
    }

    if (!$url) {$url=$pipe}
    if (!$whitelist) {$whitelist="the required web addresses."}
	if (!$filename) {$filename=$url.split('/')[-1]}
	
    try { #enable TLS 1.2
		[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
    } catch [system.exception] {
		write-host "- ERROR: Could not implement TLS 1.2 Support."
		write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
		write-host "  Please install that before proceeding."
		exit 1
    }
	
	write-host "- Downloading: $url"
    if ($env:CS_PROFILE_PROXY_TYPE -eq "0" -or !$env:CS_PROFILE_PROXY_TYPE) {$useProxy=$false} else {$useProxy=$true}

	if ($useProxy) {
        setUserAgent
        getProxyData
        write-host ": Proxy location: $script:varProxyLoc`:$script:varProxyPort"
	    $script:WebClient.Proxy = New-Object System.Net.WebProxy("$script:varProxyLoc`:$script:varProxyPort",$true)
	    $script:WebClient.DownloadFile("$url","$filename")
		if (!(test-path $filename)) {$useProxy=$false}
    }

	if (!$useProxy) {
		setUserAgent #do it again so we can fallback if proxy fails
		$script:webClient.DownloadFile("$url","$filename")
	} 

    if (!(test-path $filename)) {
        write-host "- ERROR: File $filename could not be downloaded."
        write-host "  Please ensure you are whitelisting $whitelist."
        write-host "- Operations cannot continue; exiting."
        exit 1
    } else {
        write-host "- Downloaded:  $filename"
    }
}

############# CODE ABODE ############

write-host "- Message title:  $env:usrMessageTitle"
write-host "- Message body:   $env:usrMessageContent"

#win10 check
[int]$varKernel = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\Windows\system32\kernel32.dll")).FileBuildPart
if ($varKernel -lt 10240) {
    write-host "! ERROR: This Component only works for Windows 10."
    write-host "  Exiting."
    exit 1
}

#oh in image
if ($env:usrHeroImgURL) {
    downloadFile $env:usrHeroImgURL -filename hero.png
} else {
    downloadFile "https://storage.centrastage.net/dattoHero.png" -filename hero.png
}

#get some data
$varCurrentLocation=$($PWD.Path) -replace '\\','/'
$varBrandLocation="file://$env:ProgramData/CentraStage/Brand" -replace '\\','/'
[xml]$varBrandXML= get-content "$env:ProgramData\CentraStage\Brand\keys.xml" -encoding UTF8 -ErrorAction SilentlyContinue
$varCurrentBrand=($varBrandXML.bundles.bundle.entry | ? {$_.key -eq 'productShortNameText'}).'#text' -replace "[^a-zA-Z0-9\sáéíóúäëïöüåß`'`"!&\.]",''

#make the notifier
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
New-Item -Path "HKCR:\AppUserModelId" -Name "dRMMNotifier" -Force | out-null
New-ItemProperty -Path "HKCR:\AppUserModelId\dRMMNotifier" -Name DisplayName -Value "$varCurrentBrand" -PropertyType String -Force | out-null
New-ItemProperty -Path "HKCR:\AppUserModelId\dRMMNotifier" -Name ShowInSettings -Value 0 -PropertyType DWORD -Force | out-null

@"
#fill some forms
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

#furnish the toast XML
[xml]`$ToastTemplate = @"
<toast duration="long">
  <visual>
    <binding template="ToastGeneric">
      <text>$env:usrMessageTitle</text>
      <text placement="attribution">User Notification</text>
      <image placement="hero" src="file://$varCurrentLocation/hero.png"/>
      <image id="1" placement="appLogoOverride" hint-crop="circle" src="$varBrandLocation/primaryLogo.png"/>
        <group>
            <subgroup>
                <text hint-style="body" hint-wrap="true">$env:usrMessageContent</text>
            </subgroup>
        </group>
    </binding>
  </visual>
"@ | set-content "$PWD\toastMessage.ps1" -force -Encoding UTF8

#reboot message?
if ($env:usrShowRestart -match 'true') {
    write-host "- Restart option enabled. User will see a localised option to restart the device."

    #i18n because we're nice like that
    $arrStrings=@{
        1031=[PSCustomObject]@{Caption="German";            rebootString="Jetzt neu starten"}
        1033=[PSCustomObject]@{Caption="English (American)";rebootString="Restart now"}
        1034=[PSCustomObject]@{Caption="Spanish (European)";rebootString="Reiniciar ahora"}
        1036=[PSCustomObject]@{Caption="French";            rebootString="Redémarrer maintenant"}
        1040=[PSCustomObject]@{Caption="Italian";           rebootString="Riavvia ora"}
        1043=[PSCustomObject]@{Caption="Dutch";             rebootString="Nu opnieuw opstarten"}
        2057=[PSCustomObject]@{Caption="English (British)"; rebootString="Restart now"}
        2058=[PSCustomObject]@{Caption="Spanish (Mexican)"; rebootString="Reiniciar ahora"}
    }

    [int]$varLangCode=cmd /c set /a 0x$((Get-ItemProperty hklm:\system\controlset001\control\nls\language -name InstallLanguage).InstallLanguage)
    $varRebootLocalised=$arrStrings[$varLangCode].rebootString
    if (!$varRebootLocalised) {
        write-host ": System Language: Unsupported; Restart option, if enabled, will appear in English"
        $varRebootLocalised="Restart now"
    } else {
        write-host ": System Language: $($arrStrings[$varLangCode].Caption)"
    }

    #protocol handler to reboot :: kelvin tegelaar, cyberdrain.com
    if (!(get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue')) {
        #create handler for reboot
        New-item 'HKCR:\ToastReboot' -force | out-null
        set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force | out-null
        set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force | out-null
        new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688 | out-null
        New-item 'HKCR:\ToastReboot\Shell\Open\command' -force | out-null
        set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 10' -force | out-null
    }

    #add the action to the XML
    add-content -path "$PWD\toastMessage.ps1" -Value "<actions><action content=`"$varRebootLocalised`" arguments=`"ToastReboot:\\`" activationType=`"protocol`" /></actions>" -force -Encoding UTF8
} else {
    add-content -path "$PWD\toastMessage.ps1" -Value "<actions/>" -force -Encoding UTF8
    write-host "- Restart option has not been enabled."
}

#finish off the XML
@"
</toast>
`"@
`$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
`$ToastXml.LoadXml(`$ToastTemplate.OuterXml)
`$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New(`$ToastXML)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("dRMMNotifier").Show(`$ToastMessage)
"@ | add-content "$PWD\toastMessage.ps1" -force -Encoding UTF8

#PSRun :: michael mccool, the miller group
@'
Set objShell = CreateObject("Wscript.Shell")
Set args = Wscript.Arguments
For Each arg In args
	objShell.Run("powershell -windowstyle hidden -executionpolicy bypass -noninteractive ""&"" ""'" & arg & "'"""),0
Next
'@ | set-content PSRun.vbs -Force

if (query user) { #run tasks as the logged-in user :: jon north, seagull :: build 8
    #run 'query user' and output its data as a string to get the localised name of the first object
    $varUsers=(((query user) -replace '>', '') -replace '\s{2,}', ',' | ConvertFrom-Csv)
    $varUNLocal=($varUsers -as [string]).split('=')[0] -replace '@{',''
    #run 'query user' again and pass the localised data from the first object AS an object TO schtasks
    (((query user) -replace '>', '') -replace '\s{2,}', ',' | ConvertFrom-Csv).$varUNLocal | % {
        if ($_) {
            $varCurrentUser=$_
            #find the user-domain for this user from the registry
            Get-ChildItem "Registry::HKEY_USERS\" | ? { $_.PSIsContainer } | % {
                if ((Get-ItemProperty "Registry::$_\Volatile Environment" -Name USERNAME -ErrorAction SilentlyContinue).USERNAME -match $varCurrentUser) {
                    $varCurrentDomain=$((Get-ItemProperty "Registry::$_\Volatile Environment" -Name USERDOMAIN -ErrorAction SilentlyContinue).USERDOMAIN)
                }
            }
            #now we have all the data, schedule the task
            schtasks /create /sc hourly /tn "Toaster message for $varCurrentUser" /tr "wscript `"$PWD\PSRun.vbs`" `"$PWD\toastMessage.ps1`"" /st $(([DateTime]::Now.AddMinutes(2)).ToString("HH:mm")) /et $(([DateTime]::Now.AddMinutes(4)).ToString("HH:mm")) /ru "$varCurrentDomain\$varCurrentUser" /f /z
            write-host "- Message has been scheduled to appear for user $varCurrentDomain\$varCurrentUser."
        }
    }
} else {
    write-host "! ERROR: Cannot display a toast message as no users are logged on to receive it."
    exit
}