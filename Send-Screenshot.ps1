# --- Configuration ---
$smtpServer = "smtp.gmail.com"
$smtpPort = 465
$emailSender = "zain@adnare.com"
$emailPassword = "bufuywiwoskyhcla"
$emailReceiver = "zain.ul.abideen1565@gmail.com"

# --- Timestamp and Paths ---
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$screenshotPath = "$PSScriptRoot\screenshot_$timestamp.png"

# --- Take Screenshot ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$screenBounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bitmap = New-Object System.Drawing.Bitmap $screenBounds.Width, $screenBounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screenBounds.Left, $screenBounds.Top, 0, 0, $bitmap.Size)
$bitmap.Save($screenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

# --- Prepare Email ---
$msg = New-Object System.Net.Mail.MailMessage
$msg.From = $emailSender
$msg.To.Add($emailReceiver)
$msg.Subject = "Screenshot from PowerShell Script"
$msg.Body = "Attached is the screenshot taken from your Windows machine."
$msg.Attachments.Add($screenshotPath)

# --- SMTP Client ---
$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($emailSender, $emailPassword)

try {
    $smtp.Send($msg)
    Write-Host "Screenshot sent to $emailReceiver"
}
catch {
    Write-Error "Failed to send email: $_"
}
finally {
    $msg.Dispose()
    Remove-Item -Path $screenshotPath -Force
}
