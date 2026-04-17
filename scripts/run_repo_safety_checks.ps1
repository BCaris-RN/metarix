$ErrorActionPreference = "Stop"

python .\scripts\scan_non_leak.py
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

flutter analyze
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

flutter test
exit $LASTEXITCODE
