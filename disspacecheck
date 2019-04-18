--------------------------------------------------
-- check disk space left
EXEC MASTER..xp_fixeddrives
--------------------------------------------------

--------------------------------------------------
-- Show drive space and avaialble free space
--------------------------------------------------
SELECT DISTINCT vs.volume_mount_point AS [Drive], vs.logical_volume_name AS [Drive Name], vs.total_bytes / 1024 / 1024 AS [Drive Size MB], vs.available_bytes / 1024 / 1024 AS [Drive Free Space MB]
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
ORDER BY vs.volume_mount_point;

