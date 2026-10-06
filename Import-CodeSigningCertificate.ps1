# Export every unique signer cert found in a driver package folder
$driverRoot = 'C:\Drivers\Canon'
$certDir        = 'C:\Drivers\Certs'
New-Item -ItemType Directory -Path $certDir -Force | Out-Null

Get-ChildItem $driverRoot -Recurse -Include *.cat |
    ForEach-Object { (Get-AuthenticodeSignature $_.FullName).SignerCertificate } |
    Where-Object { $_ } |
    Sort-Object Thumbprint -Unique |
    ForEach-Object {
        $name = ($_.Subject -replace '.*CN=([^,]+).*','$1') -replace '[^\w\-]','_'
        Export-Certificate -Cert $_ -FilePath "$certDir\$name-$($_.Thumbprint.Substring(0,8)).cer" -Type CERT | Out-Null
        "{0}  {1}  expires {2}" -f $_.Thumbprint, $_.Subject, $_.NotAfter
    }

# Import certificates into Trusted Publishers
Get-ChildItem $certDir -Filter *.cer | ForEach-Object {
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($_.FullName)
    if (-not (Test-Path "Cert:\LocalMachine\TrustedPublisher\$($cert.Thumbprint)")) {
        Import-Certificate -FilePath $_.FullName -CertStoreLocation Cert:\LocalMachine\TrustedPublisher | Out-Null
        Write-Output "Added $($cert.Subject)"
    }
}