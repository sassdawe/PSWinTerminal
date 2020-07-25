
if ($env:WT_SESSION) {
    $Script:PSWinTerminalConfigPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState\settings.json"
    $Script:PSWinTerminalDefaultsPath = "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.1.2021.0_x64__8wekyb3d8bbwe\defaults.json"

    if ( ( Test-Path -LiteralPath $Script:PSWinTerminalDefaultsPath) ) {
        $Script:PSWinTerminalDefaults = (Get-Content -LiteralPath $Script:PSWinTerminalDefaultsPath | Where-Object { -not $_.Trim().StartsWith('//') } ) | ConvertFrom-Json
        $Script:PSWinTerminalDefaultThemes = $Script:PSWinTerminalDefaults.schemes.name
    }
    if ( ( Test-Path -LiteralPath $Script:PSWinTerminalConfigPath) ) {
        $Script:PSWinTerminalConfig = (Get-Content -LiteralPath $Script:PSWinTerminalConfigPath | Where-Object { -not $_.Trim().StartsWith('//') } ) | ConvertFrom-Json
        $Script:PSWinTerminalThemes = $Script:PSWinTerminalConfig.schemes.name
        $Script:PSWinTerminalCurentProfile = $Script:PSWinTerminalConfig.profiles.list.GetEnumerator() | Where-Object { $_.guid -eq $env:WT_PROFILE_ID}
    }

    function Get-WTCurrentTheme {
        [CmdletBinding()]
        param (
        )
        begin {
        }

        process {
            if ($Script:PSWinTerminalCurentProfile.colorScheme) {
                $Script:PSWinTerminalCurentProfile.colorScheme
            }
            else {
                Write-Host "Campbell (Default)"
            }
        }
        
        end {
            
        }
    }

    function Get-WTTheme {
        [CmdletBinding()]
        param (
        )

        begin {

        }

        process {
            $WTThemes = New-Object System.Collections.ArrayList
            $Script:PSWinTerminalDefaultThemes | ForEach-Object { $null = $WTThemes.Add("$_") }
            $Script:PSWinTerminalThemes | ForEach-Object { $null = $WTThemes.Add("$_ *") }
            $WTThemes.ToArray() | Sort-Object
        }

        end {

        }
    }

    Export-ModuleMember -Function *
}
else {
    Throw "You need to use Windows Terminal to use PSWinTerminal"
}