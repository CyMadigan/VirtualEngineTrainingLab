configuration vTrainingLabScheduledTasks {
    param (
        ## Scheduled task state
        [Parameter(Mandatory)] [ValidateSet('Enabled','Disabled')]
        [System.String] $State
    )
    
    Import-DscResource -Name vScheduledTasks;
    
    foreach ($scheduledTask in @('Idle Maintenance','Maintenance Configurator')) {
        
        $scheduledTaskId = $scheduledTask.Replace(' ','');
        
        vScheduledTask  $scheduledTaskId {
            TaskName = $scheduledTask;
            TaskPath = '\Microsoft\Windows\TaskScheduler\';
            State = $State;
        }
    } #end foreach scheduled task

} #end configuration vTrainingLabScheduledTasks