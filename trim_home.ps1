$file = 'c:\xampp\htdocs\dualnback\lib\features\home\home_screen.dart'
$lines = Get-Content $file
$kept = $lines[0..360] + $lines[523..($lines.Length-1)]
Set-Content -Path $file -Value $kept -Encoding UTF8
Write-Host "Done: $($kept.Length) lines remaining"
