SET termout off
SET verify off
SET feedback off
SET linesize 32767
SET trimspool on
SET pagesize 0 embedded on
SET UNDERLINE OFF
SET HEADING OFF

SPOOL /tmp/process_flow_backlog_late.$run_id


SELECT DISTINCT
a.so_module as "PROCESS FLOW",
a.so_request_date as TIME_REQUESTED, 
sysdate,
FLOOR(((sysdate - a.so_request_date) * 1440)) AS "MINUTES",
CASE e.aw_sch_units WHEN -3 THEN 'D' WHEN -5 THEN 'M' WHEN -4 THEN 'H' ELSE to_char(e.aw_sch_units) END AS "FREQUENCY",
e.aw_sch_interval AS INTERVAL,
a.so_jobid,
a.so_status_name as Status
FROM so_job_queue a 
LEFT JOIN
so_job_table b
ON a.so_job_seq = b.so_job_seq
LEFT JOIN
(SELECT c.so_job_seq, c.so_jobid FROM so_job_queue c ) d
ON so_chain_id = d.so_jobid 
LEFT JOIN
aw_module_sched e
ON d.so_job_seq = e.aw_job_seq
WHERE
b.so_command_type = 'CHAIN'
AND
((a.so_request_date < (sysdate) -20/24
AND e.aw_sch_units = -3) --DAILY
OR
(a.so_request_date < (sysdate) -15/24
AND e.aw_sch_units = -4) --HOUR
OR
(a.so_request_date < (sysdate) -6/24
AND e.aw_sch_units = -5) --MINUTES
OR
(a.so_request_date < (sysdate) -23/24
AND e.aw_sch_units NOT IN (-5 , -4, -3))) --Catchem all
AND NOT a.so_module like '%_CMCTCM%'
AND NOT a.so_status_name = 'INITIATED'
AND NOT a.so_module like 'PROCESS_FLOW_ALERTS'
ORDER BY a.SO_JOBID;

SPOOL off;