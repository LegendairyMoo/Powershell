# Get a list of all files across all changesets inside of a given query in TFS

# Ever find yourself needing to know all of the files that were changed as part of a group of work items 
# because...  reasons
# Well this script will help you out as it will go through each of them and emit the files in each change set
# duplicates will appear if the same file is used across several changesets, but you can always filter them out
# in another program.

#  You'll need to Install-Module -Name TfsCmdlets to use the Get-TfsWorkItemLink portion 

$TFSServerUrl = ""  # URL for your TFS server and collection
$TFSProject = "" # Name of your TFS project
$StoredQuery = "" # Path to your query.   Be sure to include "My Queries" or "Shared Queries" as part of the path
 
#Get the ID of the query
$QueryID = (Invoke-RestMethod -Method Get -UseDefaultCredentials -uri "$($TfsServerUrl)/$($TFSProject)/_apis/wit/queries/$($StoredQuery)?api-version=2.2").id
 
#Get Workitem IDs from the query
$QueryResult = (Invoke-RestMethod -Method Get -UseDefaultCredentials -uri "$($TfsServerUrl)/$($TFSProject)/_apis/wit/wiql/$($QueryID)?api-Version=1.0").workitems

foreach($item in $QueryResult)
{

    $Changesets = Get-TfsWorkItemLink -Collection $TFSServerUrl -WorkItem $item.id

    foreach($changeset in $changesets)
    {
        if($changeset.LinkType -eq "Changeset")
        {

            $FileChanges = (Invoke-RestMethod -Method Get -UseDefaultCredentials -uri "$($TfsServerUrl)/_apis/tfvc/changesets/$($changeset.LinkTarget)/changes").value | Select-Object #-ExpandProperty Fields


            foreach($file in $FileChanges)
            {
                Write-host $file.item.path
            }

        }
    }
}
