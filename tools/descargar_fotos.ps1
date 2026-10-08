# Descarga fotos libres (Wikimedia Commons) de buses escolares de ~18 asientos.
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path assets\images | Out-Null

$UA = @{ 'User-Agent' = 'TransporteMaranata/1.0 (school transport app)' }

$fotos = @(
    @{ Name = 'bus-coaster-2016.jpg';  Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Toyota_Coaster_School_Bus_2016.jpg/1280px-Toyota_Coaster_School_Bus_2016.jpg' },
    @{ Name = 'bus-coaster-escolar.jpg'; Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Toyota_Coaster_%28School_bus%29.jpg/1280px-Toyota_Coaster_%28School_bus%29.jpg' },
    @{ Name = 'bus-foton-18.jpg';      Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/2018_Foton-AUV_BJ6571_school_bus%2C_front_8.7.18.jpg/1280px-2018_Foton-AUV_BJ6571_school_bus%2C_front_8.7.18.jpg' },
    @{ Name = 'bus-ankai-minibus.jpg'; Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Ankai_HFF6609KDE5FB_minibus_IMG001.jpg/1280px-Ankai_HFF6609KDE5FB_minibus_IMG001.jpg' },
    @{ Name = 'flota-wetherby.jpg';    Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Minibuses_at_Wetherby_High_School_%2815th_October_2022%29.jpg/1280px-Minibuses_at_Wetherby_High_School_%2815th_October_2022%29.jpg' },
    @{ Name = 'interior-asientos.jpg'; Url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Thomas_C2_interior_seats.jpg/1280px-Thomas_C2_interior_seats.jpg' }
)

foreach ($f in $fotos) {
    $dest = Join-Path 'assets\images' $f.Name
    # Si ya existe y pesa más de 50 KB, no se vuelve a descargar.
    if ((Test-Path $dest) -and ((Get-Item $dest).Length -gt 50KB)) {
        Write-Output ("SKIP {0} (ya descargada)" -f $f.Name)
        continue
    }
    Start-Sleep -Seconds 5
    try {
        Invoke-WebRequest -Uri $f.Url -OutFile $dest -Headers $UA -TimeoutSec 60
        $len = (Get-Item $dest).Length
        Write-Output ("OK {0} ({1} KB)" -f $f.Name, [math]::Round($len / 1KB))
    } catch {
        Write-Output ("FAIL {0}: {1}" -f $f.Name, $_.Exception.Message)
    }
}
