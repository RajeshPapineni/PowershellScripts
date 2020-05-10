
$Folder2 = Get-ChildItem -Path "C:\*.ABC" | ? { $_.LastWriteTime -lt (get-date 19:00) -and $_.LastWriteTime -gt ((Get-Date 19:00).AddDays(-1)) } | Split-Path -Path "C:\*.ABC" -Leaf -Resolve
$Folder1 = Get-ChildItem -Path "C:\*.ABC" | ? { $_.LastWriteTime -lt (get-date 19:00) -and $_.LastWriteTime -gt ((Get-Date 19:00).AddDays(-1)) } | Split-Path -Path "C:\*.ABC" -Leaf -Resolve

Compare-Object -ReferenceObject $Folder1 -DifferenceObject $Folder2
