$TimeFile = "C:\apps\time.txt"

function CreateOrUpdateTimeFile {
	(Get-Date).ToString() | Out-File $TimeFile
}

if (![System.IO.File]::Exists($TimeFile)) {
	CreateOrUpdateTimeFile
}

$LastTime = Get-Content $TimeFile

$LogFile = "C:\apps\jaCartaCheck.log"
$jaCartaError = get-eventlog -LogName System -EntryType Error -Source ScardSvr,WudfUsbccidDriver -After $LastTime
$LogErrorMessage = "$((Get-Date).ToString()) We have errors: `n" + $($jaCartaError | fl | out-string)
$LogNoErrorMessage = "$((Get-Date).ToString()) It is no errors."

$MailEncoding = [System.Text.Encoding]::UTF8
$MailFrom = "mail@address"
$MailRcpt = "mail@address"
$MailSubject = "Error in logs!"
$MailBody = "`nThis is a mail that include error(s):`n" + $($jaCartaError | fl | out-string)
$MailSecPasswd = ConvertTo-SecureString "password" -AsPlainText -Force
$MailMyCreds = New-Object System.Management.Automation.PSCredential ("login", $MailSecPasswd)
$MailSmtp = "IP_or_Name_of_MailServer"

function WriteLog($LogMessage) {
	Out-File $LogFile -inputobject $LogMessage -Append
}

if ($jaCartaError) {
	WriteLog -LogMessage $LogErrorMessage
	Send-MailMessage -From $MailFrom -To $MailRcpt -Subject $MailSubject -Body $MailBody -smtpserver $MailSmtp -credential $MailMyCreds -Encoding $MailEncoding
	CreateOrUpdateTimeFile
}
else {
	WriteLog -LogMessage $LogNoErrorMessage
	CreateOrUpdateTimeFile
}

