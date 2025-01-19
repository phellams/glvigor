# Define your GitLab instance details
$GitLabUrl = "https://$($ENV:GITLAB_HOST)"
$ProjectId = 207
$AccessToken = $ENV:GITLAB_API_KEY

# Labels
$LabelsFile = ".\gitlab_labels_with_colors.json"

# Retrieve all existing labels
$Labels = Invoke-RestMethod -Method Get -Uri "$GitLabUrl/api/v4/projects/$ProjectId/labels?per_page=100" -Headers @{
    "PRIVATE-TOKEN" = $AccessToken
}

# Iterate over each label and delete it
foreach ($Label in $Labels) {
    $LabelName = $Label.name

    # Delete the label
    $Response = Invoke-RestMethod -Method Delete -Uri "$GitLabUrl/api/v4/projects/$ProjectId/labels/$($LabelName)" -Headers @{
        "PRIVATE-TOKEN" = $AccessToken
    }

    if ($Response -eq $null) {
        [Console]::WriteLine("Label '$LabelName' deleted successfully.")
    }
    else {
        [Console]::WriteLine("Failed to delete label '$LabelName'.")
    }
}

[Console]::WriteLine("All labels deleted successfully.")