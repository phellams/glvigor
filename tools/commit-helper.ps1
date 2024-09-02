<# Commit Fusion template file use to create large detailed commits #>
$params = @{
  Type              = "feat";
  Scope             = "cmdlets/functions";
  Description       = "Expand module scope";
  Notes             = @(
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  );
  #Footer=$true
  GitUser           = "sgkens";
  GitGroup          = "powershell";
  # FeatureAdditions  = @(
  #   ""
  # );
  # BugFixes          = @(
  #   "",
  #   ""
  # );
  # BreakingChanges   = @();
  # FeatureNotes      = @(
  #   ""
  # );
  AsString          = $true #Default is $true
  # footer            = $true
}

# ACTIONS
# -------

# ConventionalCommit with params sent commit
New-Commit @params

# ConventionalCommit with params sent commit
#New-Commit @Params | Set-Commit

# ConventionalCommit with params, written to changelog and sent commit
#New-Commit @Params | Format-FusionMD | Update-ChangeLog -logfile .\changelog.md | Set-Commit