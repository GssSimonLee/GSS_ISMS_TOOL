#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$prefix = "{0}\" -f $env:COMPUTERNAME
$inventoryLog = "InventoryLog_{0}_{1}.txt" -f $env:COMPUTERNAME, (Get-Date -Format yyyyMMdd)

function Get-GroupMember{
    param(
        [parameter(mandatory)]
        [string] $GroupName
    )
    $member = Get-LocalGroupMember -Name $GroupName |where {$_.PrincipalSource -ne 'Unknown'}
    $filter = $member| select  Name, ObjectClass , @{Name='Groups';Expression={ "{0}" -f $GroupName }}
    return $filter
}

function Is-LocalAccountEnabled{
    param(
        [parameter(mandatory)]
        [string] $AccountName
    )
    #網域帳號不處理
    If($AccountName.StartsWith($env:COMPUTERNAME) -ne $true -and $AccountName.Contains('\')){
        return ''
    }
    $name = $AccountName.Replace($prefix,"")
    $enabled = (Get-LocalUser -Name $name).Enabled
    return $enabled
}

# loop 出所有群組的成員
$groups = @()
Get-LocalGroup| foreach{
    # 部分失效帳號只看得到 SID 的, 會造成 GetGroupMember 查詢發生 Failed to compare two elements in the array.
    $groups += Get-GroupMember -GroupName $_.Name  -ErrorAction SilentlyContinue
}

$groupby = $groups | Group {$_.Name}

$groupMembers =  $groupby `
| Select @{ Name = '帳號'; Expression = { $_.Name.Replace($prefix,"") } } `
                , @{ Name = '特權帳號'; Expression = { $_.Group.Groups.Contains('Administrators') } } `
                , @{Name = '帳號啟用'; Expression = { Is-LocalAccountEnabled -AccountName $_.Name}} `
                , @{Name = '隸屬群組'; Expression = { $_.Group | Foreach Groups}} `
                


#清查未在群組的成員
$allName = ($groupby | Select  @{Name='Name'; Expression = { $_.Name.Replace($prefix,"")}}).Name

$orphan = Get-LocalUser | where {$allName.Contains($_.Name) -eq $false }

$orphans = $orphan | Select  @{ Name = '帳號'; Expression = { $_.Name} } `
                , @{ Name = '特權帳號'; Expression = {'False'} }`
                , @{ Name = '帳號啟用'; Expression = { Is-LocalAccountEnabled -AccountName $_.Name} } `
                , @{ Name = '隸屬群組'; Expression = {'未在群組中'} } `
                

"清查主機:`t $env:COMPUTERNAME" |Out-File -FilePath $inventoryLog

("清查時間:`t {0}" -f (Get-Date -Format 'yyyy/MM/dd hh:mm:ss')) |Out-File -FilePath $inventoryLog  -Append

$groupMembers + $orphans | sort 帳號 | Out-File -FilePath $inventoryLog  -Append

Write-Host "已完成清查, 清查結果位於: "
Write-Host ''
Write-Host ("{0}\{1} " -f [System.IO.Path]::GetDirectoryName( $MyInvocation.MyCommand.Definition), $inventoryLog)
Write-Host ''
Write-Host "請再確認帳號清單內容合理性, 並填寫至「IS-D-019 帳號清查紀錄表」"
Write-Host ''
CMD /c PAUSE
