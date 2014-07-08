xquery version "1.0";

import module namespace scheduler  = "http://exist-db.org/xquery/scheduler";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace system="http://exist-db.org/xquery/system";


import module namespace localsettings="http://parliament.politicalmashup.nl/local/settings" at "xmldb:exist:///db/local/settings.xqm";


declare function local:runbackup($incremental, $max, $output){
    let $jobname := "backup-run"
    let $period := 2000
    let $delay := 2000
    let $repeat := 0
    let $resource := "xmldb:exist:///db/backup/backup.xql"
    let $parameters :=  <parameters>
                            <param name="jobname" value="{$jobname}"/>
                            <param name="incremental" value="{$incremental}"/>
                            <param name="max" value="{$max}"/>
                            <param name="output" value="{$output}"/>
                            <param name="type" value="run"/>
                        </parameters>
    (: Delete job if one was still scheduled. :)
    let $null := system:as-user($localsettings:user, $localsettings:pass, scheduler:delete-scheduled-job($jobname))
    return
        system:as-user($localsettings:user, $localsettings:pass, scheduler:schedule-xquery-periodic-job($resource, $period, $jobname, $parameters, $delay, $repeat))
};

<result>{local:runbackup('yes', 7, $localsettings:backupdir)}</result>