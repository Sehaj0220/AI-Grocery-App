$csv = Import-Csv -Path 'c:\Users\A1\Downloads\smart_grocery_items_120.csv'
$icons = @{
  'Fruits' = 'apple'
  'Vegetables' = 'carrot'
  'Dairy & Eggs' = 'egg'
  'Bread & Bakery' = 'croissant'
  'Meat & Seafood' = 'beef'
  'Rice, Pasta & Grains' = 'wheat'
  'Canned & Packaged Foods' = 'box'
  'Snacks & Sweets' = 'cookie'
  'Beverages' = 'coffee'
  'Frozen Foods' = 'snowflake'
  'Household & Cleaning' = 'sparkles'
  'Personal Care' = 'smile'
}

$counter = 1
$items = @()

foreach ($row in $csv) {
  $rawSec = $row.Section
  $cleanSec = ($rawSec -replace '\s*\(\d+\)', '').Trim()
  $itemName = $row.Item.Trim()
  $iconName = $icons[$cleanSec]
  if (-not $iconName) { $iconName = 'shopping-bag' }

  $base = 3.49
  $unit = '1 unit'
  if ($cleanSec -eq 'Fruits') { $base = 2.99; $unit = '1 lb / bag' }
  elseif ($cleanSec -eq 'Vegetables') { $base = 2.49; $unit = '1 bunch / lb' }
  elseif ($cleanSec -eq 'Dairy & Eggs') { $base = 4.29; $unit = 'pack / carton' }
  elseif ($cleanSec -eq 'Bread & Bakery') { $base = 3.29; $unit = 'package' }
  elseif ($cleanSec -eq 'Meat & Seafood') { $base = 8.99; $unit = '1 lb pack' }
  elseif ($cleanSec -eq 'Rice, Pasta & Grains') { $base = 4.49; $unit = '1 kg / box' }
  elseif ($cleanSec -eq 'Canned & Packaged Foods') { $base = 2.19; $unit = 'can / jar' }
  elseif ($cleanSec -eq 'Snacks & Sweets') { $base = 3.49; $unit = 'bag / box' }
  elseif ($cleanSec -eq 'Beverages') { $base = 3.99; $unit = 'bottle / pack' }
  elseif ($cleanSec -eq 'Frozen Foods') { $base = 5.49; $unit = 'frozen box' }
  elseif ($cleanSec -eq 'Household & Cleaning') { $base = 6.49; $unit = 'standard pack' }
  elseif ($cleanSec -eq 'Personal Care') { $base = 5.99; $unit = 'bottle / pack' }

  if ($itemName -eq 'Watermelon') { $base = 6.99 }
  if ($itemName -eq 'Steak' -or $itemName -eq 'Salmon') { $base = 12.99 }
  if ($itemName -eq 'Basmati Rice') { $base = 12.99; $unit = '10 lb bag' }
  if ($itemName -eq 'Toilet Paper' -or $itemName -eq 'Laundry Detergent') { $base = 14.99; $unit = 'pack' }

  $wPrice = [math]::Round($base * 1.0, 2)
  $fcPrice = [math]::Round($base * 0.95, 2)
  $nfPrice = [math]::Round($base * 0.88, 2)
  $cPrice = [math]::Round($base * 2.25, 2)

  $wAvail = $true
  $fcAvail = $true
  $nfAvail = $true
  $cAvail = $true
  if ($counter % 13 -eq 0) { $wAvail = $false }
  if ($counter % 17 -eq 0) { $nfAvail = $false }
  if ($counter % 23 -eq 0) { $fcAvail = $false }

  $obj = [ordered]@{
    id = [string]$counter
    name = $itemName
    category = $cleanSec
    icon = $iconName
    unit = $unit
    image = 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300&auto=format&fit=crop&q=80'
    storeData = [ordered]@{
      walmart = @{ price = $wPrice; available = $wAvail; unit = $unit }
      freshco = @{ price = $fcPrice; available = $fcAvail; unit = $unit }
      nofrills = @{ price = $nfPrice; available = $nfAvail; unit = $unit }
      costco = @{ price = $cPrice; available = $cAvail; unit = ('Bulk pack ' + $unit) }
    }
    alternative = [ordered]@{
      name = ('Everyday ' + $itemName)
      reason = 'Budget generic brand'
      priceByStore = @{
        walmart = [math]::Round($wPrice * 0.8, 2)
        freshco = [math]::Round($fcPrice * 0.8, 2)
        nofrills = [math]::Round($nfPrice * 0.8, 2)
        costco = [math]::Round($cPrice * 0.82, 2)
      }
    }
  }
  $items += $obj
  $counter++
}

$json = $items | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText('C:\Users\A1\Desktop\app\items_data.json', $json)
Write-Host "Done, total items: $($items.Count)"
