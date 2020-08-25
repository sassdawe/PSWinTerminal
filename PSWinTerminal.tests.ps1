$Global:ModuleName = "PSWinTerminal"
# Write-Warning "`$ModuleName $ModuleName"
$Script:ModuleManifestName = "$ModuleName.psd1"
# Write-Warning "`$ModuleManifestName $ModuleManifestName"
$Script:ModuleManifestPath = "$PSScriptRoot\$ModuleManifestName"
# $ModuleManifestPathExists = Test-Path -LiteralPath $ModuleManifestPath
# Write-Warning "`$ModuleManifestPath $ModuleManifestPath`t$ModuleManifestPathExists"
$Script:ModuleScriptName = "$ModuleName.psm1"
# Write-Warning "`$ModuleScriptName $ModuleScriptName"
$Global:ModuleScriptPath = "$PSScriptRoot\$ModuleScriptName"
# $ModuleScriptPathExists = Test-Path -LiteralPath $ModuleScriptPath
# Write-Warning "`$ModuleScriptPath $ModuleScriptPath`t$ModuleScriptPathExists"
Get-Module $ModuleName | Remove-Module -force
Import-Module $ModuleManifestPath

InModuleScope -ModuleName $ModuleName {
    Describe -Name "Validation tests of $ModuleName" -Tag "Module" -Fixture {
        Context -Name "Validation of file" -Fixture {
            It "$ModuleScriptName is a valid script file" {
                $script = Get-Content -LiteralPath $ModuleScriptPath -ErrorAction Stop
                $errors = $null
                [System.Management.Automation.PSParser]::Tokenize($script, [ref]$errors) | Out-Null
                $errors.Count | Should Be 0
            }
        }
        Context -Name "Public functions" -Fixture {
            ForEach ( $function in (Get-Module $ModuleName).ExportedCommands.Keys ) {
                $functionDefinition = (Get-Command -Name $function).Definition
                It "Function $function is advanced" {
                    $functionDefinition | Should -Match "CmdletBinding()"
                    $functionDefinition | Should -Match ".SYNOPSIS"
                }
            }
        }
    }
    Describe -Name "Validation tests of $ModuleName" -Tag "Functions" -Fixture {
        Context "Script Variable" -Fixture {
            It "PSWinTerminalCurentProfileHasColorScheme" {
                { (Get-Variable -Name 'PSWinTerminalCurentProfileHasColorScheme' -ErrorAction Stop).Name } | Should -Not -Throw
                (Get-Variable -Name 'PSWinTerminalCurentProfileHasColorScheme').Name | Should -BeExactly 'PSWinTerminalCurentProfileHasColorScheme'
            }
        }
        Context "Get-WTTheme" {
            It "Should return something" {
                Get-WTTheme | Should -not -BeNullOrEmpty
                Get-WTTheme | Should -BeOfType "System.String"
            }
        }
        Context "Show-WTTheme" {
            It "Should return array" {
                Show-WTTheme | Should -not -BeNullOrEmpty
                $themes = Show-WTTheme
                $themes.count | Should -BeGreaterThan 1
                $themes -is [system.array] | Should -BeTrue
            }
        }
        Context "Set-WTTheme" {
            $originalTheme = Get-WTTheme
            It "Set-Theme to random" {
                (Show-WTTheme | Where-Object { $_.replace(' *','') -ne $originalTheme } ) | Get-Random | ForEach-Object { Set-WTTheme $($_.replace(' *',''))}
                Start-Sleep -Seconds 1
                Get-WTTheme | Should -not -Be $originalTheme
            }
            It "Set-Theme to previous" {
                Set-WTTheme $originalTheme
                Start-Sleep -Seconds 1
                Get-WTTheme | Should -Be $originalTheme
            }
        }
    }
    Describe -Name "Specific tests of $ModuleName" -Tag "Importer" -Fixture {
        $Global:Error.Clear()
        Context "Import-WTTheme" {
            It "Import-WTTheme Good" {
                '{"name": "X Dotshare","black": "#101010","red": "#E84F4F","green": "#B8D68C","yellow": "#E1AA5D","blue": "#7DC1CF","purple": "#9B64FB","cyan": "#6D878D","white": "#DDDDDD","brightBlack": "#404040","brightRed": "#D23D3D","brightGreen": "#A0CF5D","brightYellow": "#F39D21","brightBlue": "#4E9FB1","brightPurple": "#8542FF","brightCyan": "#42717B","brightWhite": "#DDDDDD","background": "#151515","foreground": "#D7D0C7"}' | clip.exe
                Start-Sleep -Seconds 1
                Import-WTTheme -Verbose:$false | Should -BeExactly "X Dotshare"
                Start-Sleep -Seconds 1
                Set-WTTheme 'X Dotshare'
                Start-Sleep -Seconds 1
                Get-WTTheme | Should -BeExactly "X Dotshare"
                Start-Sleep -Seconds 1
            }
            It "Import-WTTheme Bad: Existing name" {
                '{"acrylicOpacity" : 0.5,"backgroundImage" : "Sitecore-Dark2.png","backgroundImageOpacity" : 0.80000001192092896,"backgroundImageStretchMode" : "uniformToFill","closeOnExit" : true,"colorScheme" : "Campbell","commandline" : "powershell.exe","cursorColor" : "#FFFFFF","cursorShape" : "bar","fontFace" : "Consolas","fontSize" : 10,"guid" : "{0caa0dad-35be-5f56-a8ff-afceeeaa6102}","historySize" : 9001,"icon" : "sitecore-icon.png","name" : "Campbell","padding" : "0, 0, 0, 0","snapOnInput" : true,"startingDirectory" : "%USERPROFILE%","useAcrylic" : false}' | clip.exe
                Start-Sleep -Seconds 1
                { Import-WTTheme } | Should -Throw
            }
            It "Import-WTTheme Bad: Missing name" {
                '{"acrylicOpacity" : 0.5,"backgroundImage" : "Sitecore-Dark2.png","backgroundImageOpacity" : 0.80000001192092896,"backgroundImageStretchMode" : "uniformToFill","closeOnExit" : true,"colorScheme" : "Campbell","commandline" : "powershell.exe","cursorColor" : "#FFFFFF","cursorShape" : "bar","fontFace" : "Consolas","fontSize" : 10,"guid" : "{0caa0dad-35be-5f56-a8ff-afceeeaa6102}","historySize" : 9001,"icon" : "sitecore-icon.png","padding" : "0, 0, 0, 0","snapOnInput" : true,"startingDirectory" : "%USERPROFILE%","useAcrylic" : false}' | clip.exe
                Start-Sleep -Seconds 1
                { Import-WTTheme } | Should -Throw
            }
            It "Import-WTTheme Bad" {
                '{"acrylicOpacity" : 0.5,"backgroundImage" : "Sitecore-Dark2.png","backgroundImageOpacity" : 0.80000001192092896,"closeOnExit" : true,"colorScheme" : "Campbell","commandline" : "powershell.exe","cursorColor" : "#FFFFFF","cursorShape" : "bar","fontFace" : "Consolas","fontSize" : 10,"guid" : "{0caa0dad-35be-5f56-a8ff-afceeeaa6102}","historySize" : 9001,"icon" : "sitecore-icon.png","name" : "Sitecore","padding" : "0, 0, 0, 0","snapOnInput" : true,"startingDirectory" : "%USERPROFILE%","useAcrylic" : false}' | clip.exe
                Start-Sleep -Seconds 1
                { Import-WTTheme } | Should -Throw
            }
            It "Import-WTTheme Bad 2" {
                'P4S$W0rd!' | clip.exe
                Start-Sleep -Seconds 1
                { Import-WTTheme } | Should -Throw
            }
        }
        Restore-WTConfig -Verbose -Confirm:$false
        "" | clip.exe
    }

    Describe -Name "Specific tests of $ModuleName" -Tag "Marketplace" -Fixture {
        Context "Marketplace functions" {
            It "Find-WTTheme" {
                {Get-Command -Name "Find-WTTheme" -ErrorAction Stop} | Should -Not -Throw
            }
            It "Get-WTThemeSource" {
                {Get-Command -Name "Get-WTThemeSource" -ErrorAction Stop} | Should -Not -Throw
            }
            It "Register-WTThemeSource" {
                {Get-Command -Name "Register-WTThemeSource" -ErrorAction Stop} | Should -Not -Throw
            }
            It "Unregister-WTThemeSource" {
                {Get-Command -Name "Unregister-WTThemeSource" -ErrorAction Stop} | Should -Not -Throw
            }
            It "Install-WTTheme" {
                {Get-Command -Name "Install-WTTheme" -ErrorAction Stop} | Should -Not -Throw
            }
        }
    }
}