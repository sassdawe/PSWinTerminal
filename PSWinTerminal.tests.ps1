$Global:ModuleName = "PSWinTerminal"
# Write-Warning "`$ModuleName $ModuleName"
$Global:ModuleManifestName = "$ModuleName.psd1"
# Write-Warning "`$ModuleManifestName $ModuleManifestName"
$Global:ModuleManifestPath = "$PSScriptRoot\$ModuleManifestName"
# $ModuleManifestPathExists = Test-Path -LiteralPath $ModuleManifestPath
# Write-Warning "`$ModuleManifestPath $ModuleManifestPath`t$ModuleManifestPathExists"
$Global:ModuleScriptName = "$ModuleName.psm1"
# Write-Warning "`$ModuleScriptName $ModuleScriptName"
$Global:ModuleScriptPath = "$PSScriptRoot\$ModuleScriptName"
# $ModuleScriptPathExists = Test-Path -LiteralPath $ModuleScriptPath
# Write-Warning "`$ModuleScriptPath $ModuleScriptPath`t$ModuleScriptPathExists"
Get-Module $ModuleName | Remove-Module -force
Import-Module $ModuleManifestPath

InModuleScope -ModuleName "PSWinTerminal" {
    Describe -Name "Validation tests of $ModuleName" -Tag "Script" -Fixture {
        Context -Name "Validation of file" -Fixture {
            It "$ModuleScriptName is a valid script file" {
                $script = Get-Content -LiteralPath $ModuleScriptPath -ErrorAction Stop
                $errors = $null
                [System.Management.Automation.PSParser]::Tokenize($script, [ref]$errors) | Out-Null
                $errors.Count | Should Be 0
            }
        }
        Context -Name "Public functions" -Fixture {
            ForEach ( $function in (Get-Module PSWinTerminal).ExportedCommands.Keys ) {
                $functionDefinition = (Get-Command -Name $function).Definition
                It "Function $function is advanced" {
                    $functionDefinition | Should -Match "CmdletBinding()"
                    $functionDefinition | Should -Match ".SYNOPSIS"
                }
            }
        }
        Context "Global Variable" -Fixture {
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
}