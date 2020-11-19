function call($expr) {
    $output = Invoke-Expression $expr
    if ($LastExitCode) {
        throw $output
    }
    return $output
}

$python = if ($Env:PYTHON_BIN) { $Env:PYTHON_BIN } else { 'python3.exe' }
$origPythonPath = $Env:PYTHONPATH
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tmp > $null
try {
    if ((call "${python} -c 'import sys; print(sys.version_info >= (3, 6))'") -ne 'True') {
        throw 'python 3.6+ is required'
    }
    call "${python} -m pip download --only-binary :all: --dest ${tmp} pipx"
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
    call "${python} ${tmp}/${pipxWheel}/pipx install pipx ${args}"
} finally {
    Remove-Item $tmp -Recurse
    if ($origPythonPath) {
        $Env:PYTHONPATH = $origPythonPath
    } else {
        Remove-Item Env:PYTHONPATH -ErrorAction Ignore
    }
}
