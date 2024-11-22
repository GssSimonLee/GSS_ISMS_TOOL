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
    #����b�����B�z
    If($AccountName.StartsWith($env:COMPUTERNAME) -ne $true -and $AccountName.Contains('\')){
        return ''
    }
    $name = $AccountName.Replace($prefix,"")
    $enabled = (Get-LocalUser -Name $name).Enabled
    return $enabled
}

# loop �X�Ҧ��s�ժ�����
$groups = @()
Get-LocalGroup| foreach{
    # �������ıb���u�ݱo�� SID ��, �|�y�� GetGroupMember �d�ߵo�� Failed to compare two elements in the array.
    $groups += Get-GroupMember -GroupName $_.Name  -ErrorAction SilentlyContinue
}

$groupby = $groups | Group {$_.Name}

$groupMembers =  $groupby `
| Select @{ Name = '�b��'; Expression = { $_.Name.Replace($prefix,"") } } `
                , @{ Name = '�S�v�b��'; Expression = { $_.Group.Groups.Contains('Administrators') } } `
                , @{Name = '�b���ҥ�'; Expression = { Is-LocalAccountEnabled -AccountName $_.Name}} `
                , @{Name = '���ݸs��'; Expression = { $_.Group | Foreach Groups}} `
                


#�M�d���b�s�ժ�����
$allName = ($groupby | Select  @{Name='Name'; Expression = { $_.Name.Replace($prefix,"")}}).Name

$orphan = Get-LocalUser | where {$allName.Contains($_.Name) -eq $false }

$orphans = $orphan | Select  @{ Name = '�b��'; Expression = { $_.Name} } `
                , @{ Name = '�S�v�b��'; Expression = {'False'} }`
                , @{ Name = '�b���ҥ�'; Expression = { Is-LocalAccountEnabled -AccountName $_.Name} } `
                , @{ Name = '���ݸs��'; Expression = {'���b�s�դ�'} } `
                

"�M�d�D��:`t $env:COMPUTERNAME" |Out-File -FilePath $inventoryLog

("�M�d�ɶ�:`t {0}" -f (Get-Date -Format 'yyyy/MM/dd hh:mm:ss')) |Out-File -FilePath $inventoryLog  -Append

$groupMembers + $orphans | sort �b�� | Out-File -FilePath $inventoryLog  -Append

Write-Host "�w�����M�d, �M�d���G���: "
Write-Host ''
Write-Host ("{0}\{1} " -f [System.IO.Path]::GetDirectoryName( $MyInvocation.MyCommand.Definition), $inventoryLog)
Write-Host ''
Write-Host "�ЦA�T�{�b���M�椺�e�X�z��, �ö�g�ܡuIS-D-019 �b���M�d������v"
Write-Host ''
CMD /c PAUSE
