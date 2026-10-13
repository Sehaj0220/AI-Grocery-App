$raw = Get-Content 'C:\Users\A1\Desktop\app\items_data.json' -Raw
$prefix = 'const MASTER_PRODUCTS = '
$suffix = ';'
$final = $prefix + $raw + $suffix
[IO.File]::WriteAllText('C:\Users\A1\Desktop\app\products.js', $final)
Write-Host "Created products.js with size $($final.Length)"
