SET termout off
SET verify off
SET feedback off
SET linesize 32767
SET trimspool on
SET pagesize 0 embedded on
SET UNDERLINE OFF
SET HEADING OFF

SPOOL /tmp/process_flow_backlog.$run_id

SELECT DISTINCT
a.so_module as "PROCESS_FLOW", a.so_job_started, sysdate,
FLOOR(((sysdate - a.so_job_started) * 1440)) AS "MINUTES",
CASE b.aw_sch_units WHEN -3 THEN 'D' WHEN -5 THEN 'M' WHEN -4 THEN 'H' WHEN 48 THEN 'C' ELSE 'U' END AS "FREQUENCY",
b.aw_sch_interval AS INTERVAL, a.so_jobid, a.so_status_name --new
FROM so_job_queue a
LEFT JOIN (SELECT c.so_chain_id, c.so_job_seq, c.so_jobid FROM so_job_queue c ) d
ON a.so_chain_id = d.so_jobid
LEFT JOIN aw_module_sched b
ON d.so_job_seq = b.aw_job_seq
WHERE a.so_status = 31
AND a.so_status_name = 'INITIATED'
AND NOT a.so_module LIKE '%CMCTCM%'
AND NOT a.so_module = 'PROCESS_FLOW_ALERTS'
ORDER BY MINUTES;


SPOOL off;

