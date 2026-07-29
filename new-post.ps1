<#
.SYNOPSIS
    Scaffold a new blog post from a template in _templates/.

.DESCRIPTION
    Creates posts/<slug>/index.<format> from _templates/post.<format>, filling in
    the title and today's date. The slug is derived from the title unless -Slug is
    given. Refuses to overwrite an existing post.

    The file is named index.* so the published URL is /posts/<slug>/ rather than
    /posts/<slug>/<slug>.html.

    From cmd.exe run new-post.cmd instead: cmd opens .ps1 files in an editor
    rather than executing them.

.PARAMETER Title
    Post title, e.g. "How I Fixed My Blog Pipeline".

.PARAMETER Format
    qmd (default) for prose posts, ipynb for posts that run code.

.PARAMETER Slug
    Override the auto-derived URL slug.

.EXAMPLE
    .\new-post.ps1 "How I Fixed My Blog Pipeline"

.EXAMPLE
    .\new-post.ps1 "Plotting Weather Data" -Format ipynb
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Title,

    [ValidateSet('qmd', 'ipynb')]
    [string]$Format = 'qmd',

    [string]$Slug
)

$ErrorActionPreference = 'Stop'

if (-not $Slug) {
    $s = $Title.ToLowerInvariant()
    # Drop apostrophes rather than turning them into dashes: "I'm" -> "im", not "i-m".
    $s = $s -replace "['‘’]", ''
    $s = $s -replace '[^a-z0-9]+', '-'
    $Slug = $s.Trim('-')
}
if (-not $Slug) {
    throw "Could not derive a slug from title '$Title'. Pass -Slug explicitly."
}

$template = Join-Path $PSScriptRoot "_templates\post.$Format"
if (-not (Test-Path $template)) {
    throw "Template not found: $template"
}

$dir  = Join-Path $PSScriptRoot "posts\$Slug"
$dest = Join-Path $dir "index.$Format"
if (Test-Path $dest) {
    throw "Post already exists: $dest"
}

# Both YAML double-quoted scalars and JSON strings take backslash escapes, so the
# same escaping is correct for .qmd front matter and .ipynb raw cells alike.
$safeTitle = $Title.Replace('\', '\\').Replace('"', '\"')

$content = [System.IO.File]::ReadAllText($template)
$content = $content.Replace('{{TITLE}}', $safeTitle).Replace('{{DATE}}', (Get-Date -Format 'yyyy-MM-dd'))

New-Item -ItemType Directory -Path $dir -Force | Out-Null
[System.IO.File]::WriteAllText($dest, $content, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Created $dest"
Write-Host ""
Write-Host "Next:"
Write-Host "  quarto preview                    # live reload while you write"
Write-Host "  (delete 'draft: true' to publish)"
Write-Host "  git add posts/$Slug"
Write-Host "  git commit -m `"New post: $Title`""
Write-Host "  git push                          # CI renders and deploys"
