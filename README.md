# 7zMark

Simple 7z Benchmark with PowerShell

## Quick Run

```pwsh
Invoke-Expression ./7zMark.ps1
```

## Parameters

| parameters    | options   | def   | default
|-   |- |-   |-
| `type`  | `7z`/`zip`    | archive type  | `7z`    |
| `setupclean`    | `y`/`n`   | clean setup files after benchmark.    | `n` |
| `lines` | `0`-`999999`  | Number of lines in the text file. | `20000` |
| `fileCount` | `0`-`999999`  | Number of files to be duplicated. | `100000`    |

## Run

Clean setup after benchmark with default settings

```pwsh
Invoke-Expression ./7zMark.ps1 -setupclean y
```

With custom setup data

```pwsh
Invoke-Expression ./7zMark.ps1 -lines 1000 -fileCount 1000 -type zip
```
