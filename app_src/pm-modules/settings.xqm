module namespace settings="http://politicalmashup.nl/modules/settings";

declare variable $settings:data-root := "/db/data/permanent";
declare variable $settings:local-references := true();
(:declare variable $settings:local-resolver := '/exist/apps/resolver/';:)
declare variable $settings:local-resolver := '../resolver/';

(: Settings below can probably be removed.. :)
declare variable $settings:schedules := doc("/db/schedule/schedule.xml");
declare variable $settings:backups := doc("/db/backup/backup.xml");
declare variable $settings:logdoc := collection("/db/logs/pipelines/");
