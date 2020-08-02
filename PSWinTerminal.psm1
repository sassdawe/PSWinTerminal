
if ($env:WT_SESSION -and ($IsWindows -or ($PSVersionTable.PSVersion.Major -le 5))) {
    Write-Verbose "Identify WT version"
    if ($IsWindows) {
        Write-Verbose "PowerShell 6+"
        $Script:PSWinTerminalProcessPathFolder = (Get-Process -id $PID).Parent.Path | Split-Path
    }
    else {
        Write-Verbose "Windows PowerShell"
        $Script:PSWinTerminalProcessPathFolder = (Get-Process -id $((Get-CimInstance -Query "SELECT * FROM Win32_Process WHERE ProcessID = $pid").ParentProcessID)).Path | split-path
    }
    Write-Verbose "Setting path to json files."
    if ( $Script:PSWinTerminalProcessPathFolder.contains('WindowsTerminalPreview') ) {
        $Script:PSWinTerminalConfigPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        $Script:PSWinTerminalDefaultsPath = "$Script:PSWinTerminalProcessPathFolder\defaults.json"
    }
    else {
        $Script:PSWinTerminalConfigPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $Script:PSWinTerminalDefaultsPath = "$Script:PSWinTerminalProcessPathFolder\defaults.json"
    }

    if ( ( Test-Path -LiteralPath $Script:PSWinTerminalDefaultsPath) ) {
        $Script:PSWinTerminalDefaults = (Get-Content -LiteralPath $Script:PSWinTerminalDefaultsPath | Where-Object { -not $_.Trim().StartsWith('//') } ) | ConvertFrom-Json
        $Script:PSWinTerminalDefaultThemes = $Script:PSWinTerminalDefaults.schemes.name
    }

    if ( ( Test-Path -LiteralPath $Script:PSWinTerminalConfigPath) ) {
        $Script:PSWinTerminalOriginalConfig = Get-Content $Script:PSWinTerminalConfigPath
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
                    $Script:PSWinTerminalCurentProfileHasColorScheme = $true
                }
                else {
                    $Script:PSWinTerminalCurentProfileHasColorScheme = $false
                }
            }
        }
        end {
        }
    }

    function Restore-WTConfig {
        <#
            .SYNOPSIS
                Restore-WTConfig will restore your Windows Terminal configuration.
            .DESCRIPTION
                Restore-WTConfig will restore your Windows Terminal configuration to a backup which was created when the module was loaded into your current session.

                The backup is stored in memory, and will be deleted when you close the current PowerShell session.
            .INPUTS
                None.
            .OUTPUTS
                None.
            .EXAMPLE
                Restore-WTConfig

                Restore-WTConfig will restore your Windows Terminal configuration
            .LINK
                https://github.com/sassdawe/PSWinTerminal
        #>
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
        param (
        )

        begin {
        }

        process {
            If ($PSCmdlet.ShouldProcess("Windows Terminal settings", "Restore")) {
                try {
                    $Script:PSWinTerminalOriginalConfig | Set-Content -LiteralPath $Script:PSWinTerminalConfigPath
                    Initialize-PSWinTerminalConfig
                }
                catch {
                    Write-Warning "Oh something went sideways: $_"
                }
            }
        }

        end {
        }
    }

    function Get-WTTheme {
        <#
            .SYNOPSIS
                Get-WTTheme will get the current Windows Terminal theme
            .DESCRIPTION
                Get-WTTheme will get the current Windows Terminal theme, if these is no theme configured it'll return the default theme.
            .INPUTS
                These is no input for Get-WTTheme
            .OUTPUTS
                Name of the current theme
            .EXAMPLE
                Get-WTTheme

                Get-WTTheme will get the current Windows Terminal theme
            .LINK
                https://github.com/sassdawe/PSWinTerminal
        #>
        [CmdletBinding()]
        param (
        )
        begin {
        }

        process {
            if ($Script:PSWinTerminalCurentProfileHasColorScheme) {
                $Script:PSWinTerminalCurentProfile.colorScheme
            }
            else {
                Write-Output "Campbell"
            }
        }
        end {
        }
    }

    function Show-WTTheme {
        <#
            .SYNOPSIS
                Show-WTTheme will show all available Windows Terminal themes
            .DESCRIPTION
                Show-WTTheme will show all available Windows Terminal themes.
            .INPUTS
                These is no input for Show-WTTheme
            .OUTPUTS
                Array of available themes, the custom themes will have a (*) next to their names.
            .EXAMPLE
                Show-WTTheme

                Show-WTTheme will show all available Windows Terminal themes
            .LINK
                https://github.com/sassdawe/PSWinTerminal
        #>
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
    function Initialize-WTThemeList {
        <#
            .SYNOPSIS
                Initialize-WTThemeList
            .DESCRIPTION
                Initialize-WTThemeList
            .INPUTS
                These is no input for Initialize-WTThemeList
            .OUTPUTS
                Array of available themes.
            .EXAMPLE
            .LINK
                https://github.com/sassdawe/PSWinTerminal
        #>
        [CmdletBinding()]
        param (
        )

        begin {

        }

        process {
            $WTThemes = New-Object System.Collections.ArrayList
            $Script:PSWinTerminalDefaultThemes | ForEach-Object { $null = $WTThemes.Add("$_") }
            $Script:PSWinTerminalThemes | ForEach-Object { $null = $WTThemes.Add("$_") }
            Write-Verbose $WTThemes.Count
            $WTThemes.ToArray() | Sort-Object
        }

        end {

        }
    }
    function Set-WTTheme {
        <#
            .SYNOPSIS
                Set-WTTheme will change current Windows Terminal theme
            .DESCRIPTION
                Set-WTTheme will change the current Windows Terminal theme.
            .INPUTS
                Name of the theme we want to use for the current Windows Terminal profile
            .OUTPUTS
                None.
            .EXAMPLE
                Set-WTTheme "Campbell Powershell"

                Set-WTTheme will set current Windows Terminal theme to 'Campbell Powershell'
            .LINK
                https://github.com/sassdawe/PSWinTerminal
        #>
        [CmdletBinding(SupportsShouldProcess = $true)]
        param (
            # Name of theme
            [Parameter(Mandatory = $true)]
            <#[ArgumentCompleter(
                {
                    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)

                    if ($FakeBoundParams.Theme) {
                        ( Initialize-WTThemeList | where-object { $_ -like $FakeBoundParams.Theme } ) | foreach-object { "`'$_`'" }
                    } else {
                        Initialize-WTThemeList | foreach-object { "`'$_`'" }
                    }
                }
            )]#>
            [ValidateScript(
                {
                    $_ -in (Initialize-WTThemeList)
                }
            )]
            [System.String]
            $Theme
        )

        begin {
            Write-Verbose "Set-WTTheme - begin: $Theme"
        }

        process {
            If ($PSCmdlet.ShouldProcess("WT Theme to $Theme", "Set")) {
                if ( $Script:PSWinTerminalCurentProfileHasColorScheme -eq $false ) {
                    Write-Verbose "Set-WTTheme - PSWinTerminalCurentProfileHasColorScheme FALSE"
                    ( Get-Content -LiteralPath $Script:PSWinTerminalConfigPath | ForEach-Object { if ( $_.contains("`"guid`": `"$env:WT_PROFILE_ID`"") ) { "$_`n`t`t`t`t`"colorScheme`": `"$Theme`"," } else { $_ } } ) | Set-Content -LiteralPath $Script:PSWinTerminalConfigPath -PassThru:$false
                    Initialize-PSWinTerminalConfig
                    $Script:PSWinTerminalCurentProfileHasColorScheme = $true
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
                        if ( ($i -ge $currentProfileStartLine - 1) -and ($i -lt $currentProfileEndLine) ) {
                            if ( $content[$i].Contains("colorScheme") ) {
                                Write-Verbose "Old $( Get-WTTheme )"
                                $content[$i].Replace("`"colorScheme`": `"$( Get-WTTheme )`"", "`"colorScheme`": `"$Theme`"")
                                Write-Verbose "New $Theme"
                            }
                            else {
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
        }
        end {
            Write-Verbose "Set-WTTheme - end"
        }
    }

    Register-ArgumentCompleter -CommandName 'Set-WTTheme' -ParameterName 'Theme' -ScriptBlock { param($commandName,$parameterName,$stringMatch) Initialize-WTThemeList | Where-Object { $_ -like "$stringMatch*"} | Where-Object {-not [System.String]::IsNullOrEmpty($_)} | ForEach-Object {"`'$_`'"} }

    Initialize-PSWinTerminalConfig

    Export-ModuleMember -Function * -Variable 'PSWinTerminalCurentProfileHasColorScheme'
}
else {
    Throw "You need to use Windows Terminal to use PSWinTerminal, and Windows"
}