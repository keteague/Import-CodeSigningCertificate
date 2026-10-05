# Import-DriverSigningCertificate

A PowerShell script that pulls the signing certificates out of a driver package and adds them to the machine's **Trusted Publishers** store. Once a publisher is trusted, Windows installs its drivers without showing the *"Would you like to install this device software?"* prompt. That makes the script useful when you deploy drivers silently, for example printer drivers pushed by RMM, Intune, GPO or a task sequence.

## What it does

1. Recursively searches the driver folder for `.cat` (catalog) files.
2. Reads the Authenticode signer certificate from each catalog.
3. Removes duplicates by thumbprint and exports each unique certificate as a `.cer` file. It prints the thumbprint, subject and expiry date of each one.
4. Imports every `.cer` in the certificate folder into `Cert:\LocalMachine\TrustedPublisher`, skipping any certificate that is already there.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ on Windows
- Run the script **as Administrator**, because it writes to the LocalMachine certificate store

## Usage

Edit the two paths at the top of the script:

```powershell
$driverRoot = 'C:\Drivers\Canon'   # extracted driver package to scan
$certDir    = 'C:\Drivers\Certs'   # where the exported .cer files go
```

Then run it from an elevated prompt:

```powershell
.\Import-DriverSigningCertificate.ps1
```

Example output:

```
A1B2C3D4...  CN=Canon Inc., O=Canon Inc., C=JP  expires 3/14/2027 11:59:59 PM
Added CN=Canon Inc., O=Canon Inc., C=JP
```

The second step imports *every* `.cer` file in `$certDir`. You can export certificates once on a reference machine, then copy the `.cer` files to other machines and run only the import section there.

## Security note

When you add a certificate to Trusted Publishers, Windows silently trusts **all** drivers signed with that certificate, not just the package you scanned. Only run the script on driver packages from vendors you trust, and check the exported certificates before you deploy them widely.
