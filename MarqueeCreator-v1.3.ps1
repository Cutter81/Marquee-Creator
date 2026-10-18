# MarqueeCreator GUI
# Choose the system folder and logo; output is automatically written to <system folder>\media\marquee.
# Requires Windows PowerShell 5.1+ and ImageMagick (magick.exe) on PATH.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Give Windows a stable, app-specific taskbar identity for Marquee Creator.
if (-not ('MarqueeCreatorTaskbarIdentity' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class MarqueeCreatorTaskbarIdentity {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int SetCurrentProcessExplicitAppUserModelID(string appID);
}
'@
}
[void][MarqueeCreatorTaskbarIdentity]::SetCurrentProcessExplicitAppUserModelID('Cutter81.MarqueeCreator.v1_3')


# Use the actual RazorBlade .ico file directly; no programmatic drawing.
$actualIconPath = Join-Path $env:TEMP 'MarqueeCreator_RazorBlade_v1_3.ico'
if (-not (Test-Path -LiteralPath $actualIconPath -PathType Leaf)) {
    $actualIconPath = Join-Path $PSScriptRoot 'MarqueeCreator-RazorBlade.ico'
}
if (-not (Test-Path -LiteralPath $actualIconPath -PathType Leaf)) {
    throw "RazorBlade icon file was not found: $actualIconPath"
}
$script:RazorIcon = New-Object System.Drawing.Icon($actualIconPath)


function New-Label($text, $x, $y, $width = 110) {
    $control = New-Object System.Windows.Forms.Label
    $control.Text = $text
    $control.Location = New-Object System.Drawing.Point($x, $y)
    $control.Size = New-Object System.Drawing.Size($width, 25)
    $control.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    return $control
}

function New-TextBox($text, $x, $y, $width = 495) {
    $control = New-Object System.Windows.Forms.TextBox
    $control.Text = $text
    $control.Location = New-Object System.Drawing.Point($x, $y)
    $control.Size = New-Object System.Drawing.Size($width, 25)
    $control.Anchor = 'Top,Left,Right'
    return $control
}

$initialDir = (Get-Location).Path
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Marquee Creator v1.3'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(900, 980)
$form.MinimumSize = New-Object System.Drawing.Size(860, 920)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.Icon = $script:RazorIcon
$form.ShowInTaskbar = $true

$lblSource = New-Label 'System folder:' 16 18 105
$txtSource = New-TextBox $initialDir 125 18 560
$btnSource = New-Object System.Windows.Forms.Button
$btnSource.Text = 'Browse...'
$btnSource.Location = New-Object System.Drawing.Point(700, 17)
$btnSource.Size = New-Object System.Drawing.Size(95, 27)
$btnSource.Anchor = 'Top,Right'

$defaultLogo = Join-Path $initialDir 'logo.png'
$lblLogo = New-Label 'Logo image:' 16 57 105
$txtLogo = New-TextBox $defaultLogo 125 57 560
$btnLogo = New-Object System.Windows.Forms.Button
$btnLogo.Text = 'Browse...'
$btnLogo.Location = New-Object System.Drawing.Point(700, 56)
$btnLogo.Size = New-Object System.Drawing.Size(95, 27)
$btnLogo.Anchor = 'Top,Right'

$lblMode = New-Label 'Artwork text:' 16 98 105
$rbIssue = New-Object System.Windows.Forms.RadioButton
$rbIssue.Text = 'Issue  [Expected Format: Series Name - Issue 001]'
$rbIssue.Location = New-Object System.Drawing.Point(125, 98)
$rbIssue.Size = New-Object System.Drawing.Size(650, 24)
$rbEpisodeNumber = New-Object System.Windows.Forms.RadioButton
$rbEpisodeNumber.Text = 'Episode Number  [Expected Format: Series Name - S01E01]'
$rbEpisodeNumber.Location = New-Object System.Drawing.Point(125, 126)
$rbEpisodeNumber.Size = New-Object System.Drawing.Size(650, 24)
$rbEpisodeNumber.Checked = $true
$rbEpisodeName = New-Object System.Windows.Forms.RadioButton
$rbEpisodeName.Text = 'Episode Name  [Expected Format: Series Name - S01E01 - Episode Name]'
$rbEpisodeName.Location = New-Object System.Drawing.Point(125, 154)
$rbEpisodeName.Size = New-Object System.Drawing.Size(720, 24)
$chkIncludeName = New-Object System.Windows.Forms.CheckBox
$chkIncludeName.Text = 'Include episode name with episode number (optional)'
$chkIncludeName.Location = New-Object System.Drawing.Point(145, 182)
$chkIncludeName.Size = New-Object System.Drawing.Size(470, 24)
$chkIncludeName.AutoSize = $true
$chkIncludeName.Appearance = [System.Windows.Forms.Appearance]::Normal
$chkIncludeName.AutoCheck = $true
$chkIncludeName.UseVisualStyleBackColor = $true
$chkIncludeName.Checked = $false

$lblNamingHelp = New-Object System.Windows.Forms.Label
$lblNamingHelp.Text = 'Select the format your files follow. Episode numbering is continuous across seasons. Files that do not match the selected format are skipped and listed in the log.'
$lblNamingHelp.Location = New-Object System.Drawing.Point(17, 214)
$lblNamingHelp.Size = New-Object System.Drawing.Size(850, 42)
$lblNamingHelp.Anchor = 'Top,Left,Right'
$lblNamingHelp.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$lblNamingHelp.ForeColor = [System.Drawing.Color]::DimGray

$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = 'Output location: <system folder>\media\marquee'
$lblOutput.Location = New-Object System.Drawing.Point(17, 264)
$lblOutput.Size = New-Object System.Drawing.Size(850, 24)
$lblOutput.Anchor = 'Top,Left,Right'

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = 'Create Marquees'
$btnRun.Location = New-Object System.Drawing.Point(17, 299)
$btnRun.Size = New-Object System.Drawing.Size(150, 36)
$btnRun.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(180, 306)
$progress.Size = New-Object System.Drawing.Size(687, 22)
$progress.Anchor = 'Top,Left,Right'
$progress.Minimum = 0
$progress.Value = 0

$lblLog = New-Label 'Activity log:' 17 345 120
$log = New-Object System.Windows.Forms.TextBox
$log.Location = New-Object System.Drawing.Point(17, 372)
$log.Size = New-Object System.Drawing.Size(850, 535)
$log.Multiline = $true
$log.ScrollBars = 'Vertical'
$log.ReadOnly = $true
$log.WordWrap = $false
$log.Anchor = 'Top,Bottom,Left,Right'

$form.Controls.AddRange(@($lblSource, $txtSource, $btnSource, $lblLogo, $txtLogo, $btnLogo, $lblMode, $rbIssue, $rbEpisodeNumber, $rbEpisodeName, $chkIncludeName, $lblNamingHelp, $lblOutput, $btnRun, $progress, $lblLog, $log))
$chkIncludeName.Enabled = $true
# Keep this option selectable; it is only applied when Episode Number mode is selected.


$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.ShowNewFolderButton = $false
$btnSource.Add_Click({
    $folderDialog.Description = 'Choose the system folder containing the source files'
    if (Test-Path -LiteralPath $txtSource.Text -PathType Container) { $folderDialog.SelectedPath = $txtSource.Text }
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtSource.Text = $folderDialog.SelectedPath
        $lblOutput.Text = 'Output location: ' + (Join-Path (Join-Path $folderDialog.SelectedPath 'media') 'marquee')
        $candidateLogo = Join-Path $folderDialog.SelectedPath 'logo.png'
        if (Test-Path -LiteralPath $candidateLogo -PathType Leaf) { $txtLogo.Text = $candidateLogo }
    }
})

$logoDialog = New-Object System.Windows.Forms.OpenFileDialog
$logoDialog.Title = 'Choose the logo image'
$logoDialog.Filter = 'Image files|*.png;*.jpg;*.jpeg;*.bmp;*.webp;*.gif|All files|*.*'
$btnLogo.Add_Click({
    if (Test-Path -LiteralPath $txtLogo.Text -PathType Leaf) { $logoDialog.FileName = $txtLogo.Text }
    if ($logoDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $txtLogo.Text = $logoDialog.FileName }
})

$script:OutputLogPath = $null
$script:OutputLogWriter = $null

$appendLog = {
    param([string]$Message)
    $line = $Message + [Environment]::NewLine
    $log.AppendText($line)
    $log.SelectionStart = $log.TextLength
    $log.ScrollToCaret()
    if ($script:OutputLogWriter) {
        try {
            $script:OutputLogWriter.Write($line)
            $script:OutputLogWriter.Flush()
        } catch {
            # Keep the GUI running if the output log cannot be written.
        }
    }
    [System.Windows.Forms.Application]::DoEvents()
}


function Show-GuruMeditation {
    param(
        [Parameter(Mandatory=$true)][string]$Code,
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$Details
    )
    $safeDetails = $Details
    if ([string]::IsNullOrWhiteSpace($safeDetails)) { $safeDetails = 'No further diagnostic details were supplied.' }
    if ($script:OutputLogWriter) {
        try {
            $script:OutputLogWriter.WriteLine('')
            $script:OutputLogWriter.WriteLine('*** GURU MEDITATION ERROR {0} ***' -f $Code)
            $script:OutputLogWriter.WriteLine('Title: {0}' -f $Title)
            $script:OutputLogWriter.WriteLine($safeDetails)
            $script:OutputLogWriter.Flush()
        } catch {}
    }
    $message = "GURU MEDITATION ERROR`r`n`r`nERROR CODE: $Code`r`n`r`n$Title`r`n`r`n$safeDetails`r`n`r`nMEDITATE. THEN PRESS BUTTON."
    $formError = New-Object System.Windows.Forms.Form
    $formError.Text = 'Guru Meditation — Marquee Creator'
    $formError.StartPosition = 'CenterParent'
    $formError.Size = New-Object System.Drawing.Size(620, 350)
    $formError.BackColor = [System.Drawing.Color]::Black
    $formError.ForeColor = [System.Drawing.Color]::Red
    $formError.Font = New-Object System.Drawing.Font('Consolas', 10, [System.Drawing.FontStyle]::Bold)
    $formError.FormBorderStyle = 'FixedDialog'
    $formError.MaximizeBox = $false
    $formError.MinimizeBox = $false
    $display = New-Object System.Windows.Forms.TextBox
    $display.Multiline = $true
    $display.ReadOnly = $true
    $display.ScrollBars = 'Vertical'
    $display.BackColor = [System.Drawing.Color]::Black
    $display.ForeColor = [System.Drawing.Color]::Red
    $display.BorderStyle = 'None'
    $display.Font = New-Object System.Drawing.Font('Consolas', 10, [System.Drawing.FontStyle]::Bold)
    $display.Location = New-Object System.Drawing.Point(16, 16)
    $display.Size = New-Object System.Drawing.Size(570, 245)
    $display.Text = "============================================================`r`n                 GURU MEDITATION ERROR`r`n============================================================`r`n`r`n$message"
    $button = New-Object System.Windows.Forms.Button
    $button.Text = 'BUTTON'
    $button.Size = New-Object System.Drawing.Size(120, 34)
    $button.Location = New-Object System.Drawing.Point(240, 270)
    $button.BackColor = [System.Drawing.Color]::DarkRed
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Add_Click({ $formError.Close() })
    $formError.Controls.Add($display)
    $formError.Controls.Add($button)
    [void]$formError.ShowDialog($form)
    $formError.Dispose()
}

$script:CursorVisible = $true
$script:CursorTimer = New-Object System.Windows.Forms.Timer
$script:CursorTimer.Interval = 500
$script:CursorTimer.Add_Tick({
    if ($log.IsDisposed) { $script:CursorTimer.Stop(); return }
    $prefix = '============================================================' + [Environment]::NewLine +
              '             Marquee Creator v1.3 by Cutter81' + [Environment]::NewLine +
              '============================================================' + [Environment]::NewLine + [Environment]::NewLine +
              'READY.' + [Environment]::NewLine
    $script:CursorVisible = -not $script:CursorVisible
    $log.Text = $prefix + $(if ($script:CursorVisible) { [string][char]0x2588 } else { ' ' })
    $log.SelectionStart = $log.TextLength
    $log.ScrollToCaret()
})

$writeBanner = {
    & $appendLog '============================================================'
    & $appendLog '             Marquee Creator v1.3 by Cutter81'
    & $appendLog '============================================================'
    & $appendLog 'READY.'
    # The blinking C64 block is drawn only in the GUI, not written to the disk log.
    $log.Text = '============================================================' + [Environment]::NewLine +
                '             Marquee Creator v1.3 by Cutter81' + [Environment]::NewLine +
                '============================================================' + [Environment]::NewLine +
                'READY.' + [Environment]::NewLine + [string][char]0x2588
    $log.SelectionStart = $log.TextLength
    $log.ScrollToCaret()
    $script:CursorTimer.Start()
}

# Show the project credit and READY prompt in the GUI activity/output window at startup.
$form.Add_Shown({ & $writeBanner })
$form.Add_FormClosed({ if ($script:CursorTimer) { $script:CursorTimer.Stop(); $script:CursorTimer.Dispose() } })

$btnRun.Add_Click({
    $sourceDir = $txtSource.Text.Trim()
    $logoPath = $txtLogo.Text.Trim()
    if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
        [System.Windows.Forms.MessageBox]::Show('Choose a valid system folder first.', 'Folder required', 'OK', 'Warning') | Out-Null
        return
    }
    if (-not (Test-Path -LiteralPath $logoPath -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show('Choose a valid logo image first.', 'Logo required', 'OK', 'Warning') | Out-Null
        return
    }
    $magick = Get-Command magick.exe -ErrorAction SilentlyContinue
    if (-not $magick) { $magick = Get-Command magick -ErrorAction SilentlyContinue }
    if (-not $magick) {
        Show-GuruMeditation -Code '0xRCCU-1001' -Title 'ImageMagick has vanished into the digital void.' -Details 'magick.exe was not found on PATH. Install ImageMagick or repair PATH, then try again.'
        return
    }

    $mode = if ($rbIssue.Checked) { 'Issue' } elseif ($rbEpisodeName.Checked) { 'EpisodeName' } else { 'EpisodeNumber' }
    $includeName = ($mode -eq 'EpisodeNumber' -and $chkIncludeName.Checked)
    $outputDir = Join-Path (Join-Path $sourceDir 'media') 'marquee'
    try {
        if (-not (Test-Path -LiteralPath $outputDir -PathType Container)) {
            New-Item -ItemType Directory -Path $outputDir -Force -ErrorAction Stop | Out-Null
        }
    } catch {
        Show-GuruMeditation -Code '0xRCCU-1002' -Title 'Output folder creation failed.' -Details $_.Exception.ToString()
        return
    }

    $log.Clear()
    if ($script:OutputLogWriter) {
        try { $script:OutputLogWriter.Dispose() } catch {}
        $script:OutputLogWriter = $null
    }
    $script:OutputLogPath = Join-Path $sourceDir '000-Marquee-Creator-Output.txt'
    try {
        $script:OutputLogWriter = New-Object System.IO.StreamWriter($script:OutputLogPath, $false, [System.Text.Encoding]::UTF8)
        $script:OutputLogWriter.AutoFlush = $true
    } catch {
        $script:OutputLogWriter = $null
        Show-GuruMeditation -Code '0xRCCU-1003' -Title 'The logbook refuses to materialize.' -Details ("Path: {0}`r`n{1}" -f $script:OutputLogPath, $_.Exception.ToString())
    }
    & $writeBanner
    & $appendLog ("System folder: {0}" -f $sourceDir)
    & $appendLog ("Logo image: {0}" -f $logoPath)
    & $appendLog ("Full output log: {0}" -f $script:OutputLogPath)
    & $appendLog ''
    $btnRun.Enabled = $false
    $btnRun.Text = 'Working...'
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    try {
        $logoFullPath = [System.IO.Path]::GetFullPath($logoPath)
        $candidates = @(Get-ChildItem -LiteralPath $sourceDir -File -ErrorAction Stop | Where-Object {
            [System.IO.Path]::GetFullPath($_.FullName) -ne $logoFullPath -and
            $_.Extension -notmatch '^\.txt$' -and $_.Name -notmatch 'xml'
        })
        $records = @()
        $skipped = 0
        foreach ($file in $candidates) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $record = $null
            if ($mode -eq 'Issue') {
                if ($base -match '^(?<series>.+?)\s+-\s+Issue\s+(?<issue>\d+)\s*$') {
                    $record = [pscustomobject]@{ File=$file; SortSeason=0; SortEpisode=[int]$Matches.issue; Label=('Issue {0}' -f [int]$Matches.issue) }
                }
            } elseif ($mode -eq 'EpisodeNumber') {
                if ($includeName -and $base -match '^(?<series>.+?)\s+-\s+S(?<season>\d{2,})E(?<episode>\d{2,})\s+-\s+(?<name>.+?)\s*$') {
                    $records += [pscustomobject]@{ File=$file; SortSeason=[int]$Matches.season; SortEpisode=[int]$Matches.episode; EpisodeName=$Matches.name.Trim(); Label='' }
                    continue
                } elseif (-not $includeName -and $base -match '^(?<series>.+?)\s+-\s+S(?<season>\d{2,})E(?<episode>\d{2,})$') {
                    $records += [pscustomobject]@{ File=$file; SortSeason=[int]$Matches.season; SortEpisode=[int]$Matches.episode; EpisodeName=''; Label='' }
                    continue
                }
            } else {
                if ($base -match '^(?<series>.+?)\s+-\s+S(?<season>\d{2,})E(?<episode>\d{2,})\s+-\s+(?<name>.+?)\s*$') {
                    $records += [pscustomobject]@{ File=$file; SortSeason=[int]$Matches.season; SortEpisode=[int]$Matches.episode; EpisodeName=$Matches.name.Trim(); Label=$Matches.name.Trim() }
                    continue
                }
            }
            if ($record) { $records += $record } else { $skipped++; & $appendLog ("SKIP {0} — does not match selected format." -f $file.Name) }
        }

        if ($records.Count -eq 0) {
            & $appendLog 'No files matched the selected naming convention.'
            & $appendLog 'Issue: Series Name - Issue 001.ext'
            & $appendLog 'Episode Number: Series Name - S01E01.ext'
            & $appendLog 'Episode Name: Series Name - S01E01 - Episode Name.ext'
            $progress.Value = 0
        } else {
            $records = @($records | Sort-Object SortSeason, SortEpisode, @{Expression={$_.File.Name}})
            $progress.Maximum = $records.Count
            $progress.Value = 0
            & $appendLog ("Matched {0} file(s); skipped {1}. Output: {2}" -f $records.Count, $skipped, $outputDir)
            & $appendLog ("Selected mode: {0}{1}" -f $mode, $(if ($includeName) { ' + episode name' } else { '' }))
            $succeeded = 0; $failed = 0; $counter = 0
            foreach ($record in $records) {
                $file = $record.File
                $counter++
                if ($mode -eq 'Issue') {
                    $labelText = $record.Label
                } elseif ($mode -eq 'EpisodeName') {
                    $labelText = $record.EpisodeName
                } elseif ($includeName) {
                    $labelText = ('Episode {0} - {1}' -f $counter, $record.EpisodeName)
                } else {
                    $labelText = "Episode $counter"
                }
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $outputPath = Join-Path $outputDir "${baseName}-marquee.png"
                if (Test-Path -LiteralPath $outputPath -PathType Leaf) {
                    $failed++
                    & $appendLog ("SKIP {0} — output already exists; refusing to overwrite." -f $file.Name)
                    if ($progress.Value -lt $progress.Maximum) { $progress.Value++ }
                    continue
                }
                $magickArgs = @(
                    $logoPath, '-resize', '350x',
                    '(', '-size', '350x45', '-background', 'transparent',
                    '-fill', 'white', '-stroke', 'black', '-strokewidth', '1',
                    '-font', 'Arial-Bold', '-pointsize', '30', '-gravity', 'Center',
                    "caption:$labelText", ')',
                    '-append', '-gravity', 'Center', '-extent', '350x175', $outputPath
                )
                try {
                    $magickOutput = & $magick.Source @magickArgs 2>&1
                    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
                        $succeeded++
                        & $appendLog ("OK   {0} -> [{1}] {2}" -f $file.Name, $labelText, $outputPath)
                    } else {
                        $failed++
                        & $appendLog ("FAIL {0}: {1}" -f $file.Name, (($magickOutput | Out-String).Trim()))
                        Show-GuruMeditation -Code '0xRCCU-2001' -Title ('ImageMagick failed on {0}.' -f $file.Name) -Details (($magickOutput | Out-String).Trim())
                    }
                } catch {
                    $failed++
                    & $appendLog ("FAIL {0}: {1}" -f $file.Name, $_.Exception.Message)
                    Show-GuruMeditation -Code '0xRCCU-2002' -Title ('Unexpected image-generation exception: {0}' -f $file.Name) -Details $_.Exception.ToString()
                }
                if ($progress.Value -lt $progress.Maximum) { $progress.Value++ }
                [System.Windows.Forms.Application]::DoEvents()
            }
            & $appendLog ("Finished. Successful: {0}; failed/skipped during generation: {1}." -f $succeeded, $failed)
        }
    } catch {
        & $appendLog ("ERROR [0xRCCU-9001]: {0}" -f $_.Exception.Message)
        Show-GuruMeditation -Code '0xRCCU-9001' -Title 'The application encountered an unexpected error.' -Details $_.Exception.ToString()
    } finally {
        $btnRun.Enabled = $true
        $btnRun.Text = 'Create Marquees'
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
})

[void]$form.ShowDialog()
if ($script:OutputLogWriter) {
    try { $script:OutputLogWriter.Dispose() } catch {}
    $script:OutputLogWriter = $null
}
