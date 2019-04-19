-- Tablespace Percentage Used

SET lines 150
SET pagesize 200 
col "Tablespace Name" format a30 
col "Datafile Name" format a70 
col "MBYTES" format 99,999,999 
col "GROUP#" format 99,999,999 
col "STATUS" format a10 
col "TYPE" format a10 
col "MEMBER" format a50 
col "IS_RECOVERY_DEST_FILE" format a20 
col member format a60

SELECT tablespace_name "Tablespace Name"
	,round(decode(Maxsize, 0, CurrentSize, Maxsize) / 1024 / 1024, 1) "Max(Extendable)"
	,round(CurrentSize / 1024 / 1024, 0) "Current Size"
	,round(decode(free, NULL, 0, free) / 1024 / 1024, 2) "Free Space"
	,round((CurrentSize - decode(free, NULL, 0, free)) / 1024 / 1024, 2) "Used Space"
	,round(100 * (CurrentSize - decode(free, NULL, 0, free)) / 1024 / 1024 / (decode(Maxsize, 0, CurrentSize, Maxsize) / 1024 / 1024), 1) "Percent Used"
FROM (
	SELECT tablespace_name
		,sum(maxbytes) Maxsize
		,sum(bytes) CurrentSize
		,(
			SELECT sum(bytes)
			FROM dba_free_space b
			WHERE b.TABLESPACE_NAME = a.TABLESPACE_NAME
			) free
	FROM dba_data_files a
	GROUP BY tablespace_name
	UNION ALL
	(
		SELECT d.tablespace_name
			,maxbytes
			,(f.bytes_free + f.bytes_used) TotalK
			,(f.Bytes_used)
		FROM SYS.V_$TEMP_SPACE_HEADER f
			,DBA_TEMP_FILES d
		WHERE f.tablespace_name(+) = d.tablespace_name
			AND f.file_id(+) = d.file_id
		)
	)
ORDER BY "Percent Used" ;




-- Simple talbespace check without considering auto extent
SELECT tablespace_name
	,sum(bytes / 1024 / 1024) sum_free_extent_size
FROM dba_free_space
GROUP BY tablespace_name
ORDER BY tablespace_name;


-- Tablespace Percentage Free

SELECT a.tablespace_name
	,SUM(a.tots) / 1024 / 1024 "Current Size(MB)"
	,SUM(a.sumb) / 1024 / 1024 "Free Space(MB)"
	,ROUND(SUM(a.sumb) * 100 / SUM(a.tots)) "Percent Free"
FROM (
	SELECT tablespace_name
		,0 tots
		,SUM(BYTES) sumb
	FROM dba_free_space a
	GROUP BY tablespace_name
	
	UNION
	
	SELECT tablespace_name
		,SUM(BYTES) tots
		,0
	FROM dba_data_files
	GROUP BY tablespace_name
	) a
GROUP BY a.tablespace_name
ORDER BY "Percent Free";

-- Resize data file
alter database datafile 'TEST.dbf' resize 100m;
-- Add a new data file
alter tablespace tablespace_name add datafile 'TEST.dbf' size 1000M autoextend on next 100m maxsize 5000m;

-- Tablespace Daily Usage
select a.name, b.*  
  from v$tablespace a,  
       (select tablespace_id,  
               trunc(to_date(rtime, 'mm/dd/yyyy hh24:mi:ss')) datetime,  
               max(tablespace_usedsize * 8 / 1024) used_size  
          from dba_hist_tbspc_space_usage  
         where trunc(to_date(rtime, 'mm/dd/yyyy hh24:mi:ss')) >  
               trunc(sysdate - 30) group by tablespace_id,  
         trunc(to_date(rtime, 'mm/dd/yyyy hh24:mi:ss')) order by  
         tablespace_id, trunc(to_date(rtime, 'mm/dd/yyyy hh24:mi:ss'))) b  
 where a.ts# = b.tablespace_id

g:markdown_fenced_languages = ['sql']
