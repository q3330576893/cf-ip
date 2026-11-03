# keepalive.ps1 - prevent Windows idle sleep / screensaver / cloud-idle shutdown
# Runs forever; refreshes execution state and simulates a tiny mouse move each minute.
$ErrorActionPreference = 'SilentlyContinue'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $dir 'keepalive.log'

Add-Type -Namespace Wk -Name Native -MemberDefinition @'
[DllImport("kernel32.dll")]
public static extern uint SetThreadExecutionState(uint esFlags);
[DllImport("user32.dll")]
public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
'@

$ES_CONTINUOUS = [uint32]2147483648
$ES_SYSTEM_REQUIRED = [uint32]1
$ES_DISPLAY_REQUIRED = [uint32]2
$MOUSEEVENTF_MOVE = 0x0001

function Write-Log([string]$msg) {
    try {
        if ((Test-Path $log) -and ((Get-Item $log).Length -gt 200KB)) { Clear-Content $log }
        Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg) -Encoding UTF8
    } catch {}
}

Write-Log "keepalive started (pid=$PID)"

$lastBeat = Get-Date
while ($true) {
    try {
        [void][Wk.Native]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED)
        [Wk.Native]::mouse_event($MOUSEEVENTF_MOVE, 1, 0, 0, 0)
        Start-Sleep -Milliseconds 80
        [Wk.Native]::mouse_event($MOUSEEVENTF_MOVE, -1, 0, 0, 0)
    } catch {
        Write-Log ("keepalive error: " + $_.Exception.Message)
    }

    if (((Get-Date) - $lastBeat).TotalMinutes -ge 30) {
        Write-Log "heartbeat ok"
        $lastBeat = Get-Date
    }
    Start-Sleep -Seconds 55
}
