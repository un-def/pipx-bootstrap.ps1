# pipx-bootstrap.ps1

A PowerShell script for installing pipx with pipx

## Other Versions

  * [POSIX Shell](https://github.com/un-def/pipx-bootstrap.sh)

## Usage

Download `pipx-bootstrap.ps1` and run it:

```powershell
(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/un-def/pipx-bootstrap.ps1/master/pipx-bootstrap.ps1', 'pipx-bootstrap.ps1')
.\pipx-bootstrap.sh
```

or (in one step):

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/un-def/pipx-bootstrap.ps1/master/pipx-bootstrap.ps1')
```

Script arguments are passed to `pipx install pipx` command, e.g.,

```powershell
.\pipx-bootstrap.sh --verbose --force
```

is equivalent to

```powershell
pipx install pipx --verbose --force
```

The script uses `python3` binary by default. It can be overriden with the environment variable `PYTHON_BIN`:

```powershell
$Env:PYTHON_BIN=X:\path\to\python
.\pipx-bootstrap.sh
```
