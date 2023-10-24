$python = if ($Env:PYTHON_BIN) { $Env:PYTHON_BIN } else { 'python3.exe' }

function Invoke-Python([string[]]$arguments) {
    $output = & $python $arguments
    if ($LastExitCode) {
        throw $output
    }
    return $output
}

$origPythonPath = $Env:PYTHONPATH
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tmp > $null

try {
    if ((Invoke-Python '-c', "`"import sys; print(sys.version_info >= (3, 6))"`") -ne 'True') {
        throw 'python 3.6+ is required'
    }
    Invoke-Python '-m', 'pip', 'download', '--only-binary', ':all:', '--dest', $tmp, 'pipx'
    $pipxWheel = Get-ChildItem -Path $tmp pipx-*.whl -Name
    if (!$pipxWheel) {
        throw 'pipx wheel not found'
    }
    if ($pipxWheel -is [System.Array]) {
        throw "multiple pipx wheels found: ${pipxWheel}"
    }
    $Env:PYTHONPATH = (Get-ChildItem -Path $tmp *.whl | % { $_.FullName }) -join ';'
    if ($origPythonPath) {
        $Env:PYTHONPATH += ';' + $origPythonPath
    }
    $pipxinstall = "${tmp}/${pipxWheel}/pipx", 'install', 'pipx'
    $pipxinstall += $args
    Invoke-Python $pipxinstall
} finally {
    Remove-Item $tmp -Recurse
    if ($origPythonPath) {
        $Env:PYTHONPATH = $origPythonPath
    } else {
        Remove-Item Env:PYTHONPATH -ErrorAction Ignore
    }
}
