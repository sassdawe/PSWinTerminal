
if ($env:WT_SESSION) {
    $Script:PSWinTerminalConfigPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState\settings.json"
    $Script:PSWinTerminalDefaultsPath = "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.1.2021.0_x64__8wekyb3d8bbwe\defaults.json"

    if ( ( Test-Path -LiteralPath $Script:PSWinTerminalDefaultsPath) ) {
        $Script:PSWinTerminalDefaults = (Get-Content -LiteralPath $Script:PSWinTerminalDefaultsPath | Where-Object { -not $_.Trim().StartsWith('//') } ) | ConvertFrom-Json
        $Script:PSWinTerminalDefaultThemes = $Script:PSWinTerminalDefaults.schemes.name
    }


    function Initialize-PSWinTerminalConfig {
        [CmdletBinding()]
        param (
        )
        begin {
        }
        process {
            if ( ( Test-Path -LiteralPath $Script:PSWinTerminalConfigPath) ) {
                $Script:PSWinTerminalConfig = (Get-Content -LiteralPath $Script:PSWinTerminalConfigPath | Where-Object { -not $_.Trim().StartsWith('//') } ) | ConvertFrom-Json
                $Script:PSWinTerminalThemes = $Script:PSWinTerminalConfig.schemes.name
                $Script:PSWinTerminalCurentProfile = $Script:PSWinTerminalConfig.profiles.list.GetEnumerator() | Where-Object { $_.guid -eq $env:WT_PROFILE_ID }

                if ($Script:PSWinTerminalCurentProfile.colorScheme) {
                    $Global:PSWinTerminalCurentProfileHasColorScheme = $true
                }
                else {
                    $Global:PSWinTerminalCurentProfileHasColorScheme = $false
                }
            }
        }
        end {
        }
    }
    function Get-WTCurrentTheme {
        [CmdletBinding()]
        param (
        )
        begin {
        }

        process {
            if ($Global:PSWinTerminalCurentProfileHasColorScheme) {
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

    function Set-WTTheme {
        [CmdletBinding()]
        param (
            # Name of theme
            [Parameter(Mandatory)]
            [System.String]
            $Theme
        )

        begin {
            Write-Verbose "Set-WTTheme - begin"
        }

        process {
            if ( $Global:PSWinTerminalCurentProfileHasColorScheme -eq $false ) {
                Write-Verbose "Set-WTTheme - PSWinTerminalCurentProfileHasColorScheme FALSE"
                ( Get-Content -LiteralPath $Script:PSWinTerminalConfigPath | ForEach-Object { if ( $_.contains("`"guid`": `"$env:WT_PROFILE_ID`"") ) { "$_`n`t`t`t`t`"colorScheme`": `"$Theme`"," } else { $_ } } ) | Set-Content -LiteralPath $Script:PSWinTerminalConfigPath -PassThru:$false
                Initialize-PSWinTerminalConfig
                $Global:PSWinTerminalCurentProfileHasColorScheme = $true
            }
            else {
                Write-Verbose "Set-WTTheme - PSWinTerminalCurentProfileHasColorScheme TRUE"
                $currentProfileGuidLine = 0
                $content = Get-Content -LiteralPath $Script:PSWinTerminalConfigPath
                :guid Foreach ( $line in $content ) {
                    if ( $line.contains("`"guid`": `"$env:WT_PROFILE_ID`"") ) {
                        $currentProfileGuidLine += 1
                        break guid
                    }
                    else {
                        $currentProfileGuidLine += 1
                    }
                }
                Write-Verbose "Set-WTTheme - Guid is in line: $currentProfileGuidLine"
                for ($i = $currentProfileGuidLine - 1; $i -gt 0; $i--) {
                    # "$i" + $content[$i]
                    if ( $content[$i].Trim() -eq '{' ) {
                        $currentProfileStartLine = $i + 1
                        break
                    }
                }
                Write-Verbose "Set-WTTheme - Start is in line: $currentProfileStartLine"
                for ($i = $currentProfileStartLine - 1; $i -lt $content.Length; $i++ ) {
                    # "$i" + $content[$i]
                    if ( $content[$i].Trim() -eq '},' ) {
                        $currentProfileEndLine = $i + 1
                        break
                    }
                }
                Write-Verbose "Set-WTTheme - End is in line: $currentProfileEndLine"
                $newConfig = for ($i = 0; $i -lt $content.Length; $i++ ) {
                    if ( ($i -ge $currentProfileStartLine -1) -and ($i -lt $currentProfileEndLine) ) {
                        if ( $content[$i].Contains("colorScheme") ) {
                            Write-Verbose "Old $( Get-WTCurrentTheme )"
                            $content[$i].Replace("`"colorScheme`": `"$( Get-WTCurrentTheme )`"","`"colorScheme`": `"$Theme`"")
                            Write-Verbose "New $Theme"
                        } else {
                            $content[$i]
                        }
                    }
                    else {
                        $content[$i]
                    }
                }
                $newConfig | Set-Content -LiteralPath $Script:PSWinTerminalConfigPath -PassThru:$false


                Initialize-PSWinTerminalConfig
            }
        }
        end {
            Write-Verbose "Set-WTTheme - end"
        }
    }

    Initialize-PSWinTerminalConfig

    Export-ModuleMember -Function *
}
else {
    Throw "You need to use Windows Terminal to use PSWinTerminal"
}