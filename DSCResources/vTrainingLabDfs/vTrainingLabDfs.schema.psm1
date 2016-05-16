#requires -Version 5

configuration  vShowcaseLabDfs {
    param (
        ## Collection of folders
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Folders,
        
        ## Domain credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## DFS root share
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DFSRoot = 'DFS',
        
        ## Domain root FQDN used to AD paths
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DomainName = 'lab.local',
        
        ## File server FQDN containing the user's home directories and profile shares
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $FileServer = 'controller.lab.local',
        
        ## Collections of departments to create department DFS shares
        [Parameter()]
        [System.String[]] $Departments
    )
    
    Import-DscResource -Module xDfs;
    
    $dfsRoot = $Folders | Where { $_.DfsRoot -eq $true } | Select -First 1;
    
    if ($dfsRoot) {
        
        $rootId = $dfsRoot.Path.Replace(':','').Replace(' ','').Replace('\','_');
        xDFSNamespaceRoot $rootId {
            Path = '\\{0}\{1}\{2}' -f $DomainName, $DFSRoot;
            TargetPath = '\\{0}\{1}' -f $FileServer, $folder.Share;
            Description = $folder.Description;
            Type = 'DomainV2';
            Ensure = 'Present'; 
            PsDscRunAsCredential = $Credential;
        }
        
        ## Create the DFS folders
        $dfsFolders = $Folders | Where { $_.DfsPath };
        foreach ($dfsFolder in $dfsFolders) {
            
            $folderId = 'DFS_{0}' -f $dfsFolder.Path.Replace(':','').Replace(' ','').Replace('\','_');
            xDFSNamespaceFolder $folderId {
                Path = '\\{0}\{1}\{2}' -f $DomainName, $DFSRoot, $dfsFolder.DfsPath;
                TargetPath = '\\{0}\{1}' -f $FileServer, $dfsFolder.Share;
                Description = $dfsFolder.Description;
                Ensure = 'Present';
                PsDscRunAsCredential = $Credential;
                DependsOn = "[xDFSNamespaceRoot]$rootId";
            }
            
        } #end foreach DFS folder
        
        ## Create the department DFS folders
        foreach ($department in $Departments) {
            
            $folderId = 'DFS_Department_{0}' -f $department.Replace(' ','');
            xDFSNamespaceFolder $folderId {
                Path = '\\{0}\DFS\Departments\{1}' -f $DomainName, $DFSRoot, $department;
                TargetPath = '\\{0}\{1}' -f $FileServer, $department;
                Description = '{0} Department' -f $department;
                Ensure = 'Present';
                PsDscRunAsCredential = $Credential;
                DependsOn = "[xDFSNamespaceRoot]$rootId";
            }
            
        } #end foreach department folder
        
    } #end if DFS Root
    
} #end configuration vShowcaseLabDfs