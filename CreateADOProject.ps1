# Simple script to create Azure DevOps Projects and add Project Administrators

# Variables

$CollectionUri = 'https://devops/DefaultCollection'
$tfsSecurityFullPath = 'C:\Program Files\Azure DevOps Server 2020\Tools\tfssecurity.exe'
$ProjectName = 'NewTestProject15'
$ProjectDescription = "My New Project"
$ProjectAdmins = "TestUser@corp.ado.net","TestUser2@corp.ado.net"
    <#
    Select TemplateTypeId from the below list

    name  id
    ----  --
    Basic b8a3a935-7e91-48b8-a94c-606d37c3e9f2
    Agile adcc42ab-9882-485e-a3ed-7678f01f66bc
    CMMI  27450541-8e31-4150-9947-dc59f998fc01
    Scrum 6b724908-ef14-45cf-84f8-768b5384da45
    #>
$templateTypeId = "adcc42ab-9882-485e-a3ed-7678f01f66bc"

# Create Project


$Params = @{
    Uri = "$CollectionUri/_apis/projects?api-version=5.0"
    Method = "Post"
    ContentType = "application/json"
    Headers = @{}
    Body = @{
        "name" = "$ProjectName"
        "description" = "$ProjectDescription"
        "capabilities" = @{
            "versioncontrol" = @{
                "sourceControlType" = "Git"
            }
            "processTemplate" = @{
                "templateTypeId" = $templateTypeId
            }
        }
    } | ConvertTo-Json -Depth 5
    UseDefaultCredentials = $True            
}

Write-Host "Creating Project $ProjectName in $($CollectionUri)" -ForegroundColor Cyan
Invoke-WebRequest @Params


# Add Project Administrators

$DefaultGroupName = "$($ProjectName) Team"

$ProjectAdmins | ForEach-Object {
    Write-Host "Adding $($_) to $($ProjectName) \ $($DefaultGroupName) " -ForegroundColor Cyan
    & $tfsSecurityFullPath /g+ "[$ProjectName]\$DefaultGroupName" n:$($_) /collection:$CollectionUri

}

Write-Host "Done!"



