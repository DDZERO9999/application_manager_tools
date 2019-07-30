SET termout off
SET verify off
SET feedback off
SET linesize 32767
SET trimspool on
SET pagesize 0 embedded on
SET UNDERLINE ON
SET HEADING ON
SPOOL /$AW_HOME/out/process_flow_times.$run_id
SELECT MODULE, COUNT(*) AS "COUNT", 
FLOOR(MEDIAN(((so_job_finished - so_job_started) * 1440))) AS "MEDIAN", 
FLOOR(AVG(((so_job_finished - so_job_started) * 1440))) AS AVERAGE, 
FLOOR(STATS_MODE(((so_job_finished - so_job_started) * 1440))) AS "MODE",
FLOOR(STDDEV(((so_job_finished - so_job_started) * 1440))) AS "STAND_DEV"
FROM aw_jh_view
WHERE so_command_type = 'CHAIN'
AND so_status = 32
AND aw_sch_name IS NOT NULL
AND so_reason IS NULL
GROUP BY MODULE
HAVING COUNT(*) > 7;
SPOOL off;

