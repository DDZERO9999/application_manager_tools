#!/bin/sh -x

#################################
#Modified 06/17/2020 Dave DeSalvo
#################################
###########VARIABLES#############
#SET OUTPUT FILE
OUTFILE=$AW_HOME/out/long_runner.$jobid.csv

#SET POSITIONAL VARIABLES
PF_BL_RUNID=/tmp/process_flow_backlog.$1
PF_TIMES_RUNID=/$AW_HOME/out/process_flow_times.$2
PF_BL_LATE_RUNID=/tmp/process_flow_backlog_late.$3

######FUNCTIONS##########
REMOVE()
	{
		#REMOVE TMP FILES
		rm $PF_BL_RUNID
		rm $PF_BL_LATE_RUNID
	}

CHECK_FILES()
	{
		#FILE CHECK EXISTS
		if [[ -e $PF_TIMES_RUNID ]] 
			then
				:
		else 
			echo "FILE $(ls $PF_TIMES_RUNID) DOES NOT EXIST"
			REMOVE
			exit 1
		fi
		#FILE CHECK EXISTS
		if [[ -e $PF_BL_RUNID ]]
			then
				: 
		else 
			echo "FILE $(ls $PF_BL_RUNID) DOES NOT EXIST"
			REMOVE
			exit 1
		fi
		#FILE CHECK EXISTS
		if [[ -e $PF_BL_LATE_RUNID ]]
			then
				: 
		else 
			echo "FILE $(ls $PF_BL_LATE_RUNID) DOES NOT EXIST"
			REMOVE
			exit 1
		fi
	}

CALC_INTERVAL()
	{
		#TURN HOURS INTO MINUTES FUNCTION
		if [[ $FREQUENCY = "H" ]]
			then 
				((I = $INTERVAL * 60))
				INTERVAL=$I
			else
				:
		fi
	}
 
CALC_MIN_TO_HR_ELAPS()
	{
		#Calc minutes to hours for elapsed
		if [[ $1 -gt 59 ]]
			then 
				((ELAPSED = $1 / 60))
				ELAPSED="$ELAPSED HOUR(S)"
			else 
				ELAPSED="$ELAPSED MINUTE(S)"
		fi
	}

CALC_MIN_TO_HR_AVG()
	{
		#Calc minutes to hours for average
		AVG=$1
		
		if [[ $AVG -gt 59 ]]
			then 
				((AVERAGE = $AVG / 60))
				AVERAGE="$AVERAGE HOUR(S)"
			else 
				AVERAGE="$AVERAGE MINUTE(S)"
		fi
	}
	
LONG_RUNNER()
	{
		#CALC IF PROCESS FLOW IS RUNNING LONG FUNCTION
		((z = $1 * 3 + $2))
		if [[ $z -lt 10 ]]
			then
				((z = $z + 30))
		elif [[ $z -lt 45 ]]
			then	
				((z = $z + 30))
			else 
				:
		fi
		if [[ $z -lt $3 ]]; 
			then STATUS="RUNNING LONG_" 
			else STATUS=
		fi
	}		

LOOP_TIMES_FILE()
	{
		#SET VARIABLES
		PF=$(echo $LINE | awk '{print $1}')
		FILE=$(echo $LINE | awk '{print $1, $4, $5, $6, $7, $8}') #PROCESS_FLOW, ELAPSED, FREQUENCY(D H M), INTERVAL(MIN), RUNID, STATUS
		TIMES=$(cat $PF_TIMES_RUNID | grep -w $PF | awk '{print $4, $6}') #AVERAGE, STAND_DEV
		COMBO=$(echo "$FILE $TIMES") # 1 Process_flow, 2 ELAPSED, 3 FREQUENCY, 4 INTERVAL, 5 RUNID, 6 AVERAGE, 7 STAND_DEV
		ELAPSED=$(echo $COMBO  | awk '{print $2}'); FREQUENCY=$(echo $COMBO  | awk '{print $3}')
		INTERVAL=$(echo $COMBO  | awk '{print $4}'); RUNID=$(echo $COMBO  | awk '{print $5}'); STATUS=$(echo $COMBO  | awk '{print $6}')
		AVERAGE=$(echo $COMBO  | awk '{print $7}'); STAND_DEV=$(echo $COMBO  | awk '{print $8}')

		#Makes Averate and Standard Deviation zero where there is no value
		if [[ -z $AVERAGE || -z $STAND_DEV ]]
			then
				AVERAGE=0
				STAND_DEV=0
		fi
	}

PROCESS_BACKLOG_FILE()
	{
	while read LINE 
		do 
			LOOP_TIMES_FILE 				
			CALC_INTERVAL $FREQUENCY $INTERVAL				
			LONG_RUNNER $STAND_DEV $AVERAGE $ELAPSED				
			#remove unwanted entries
			if [[ -z $STATUS ]] || [[ $AVERAGE -eq 0 ]]
				then :
				else #REMOVE CHECK TO SEE IF MINUTES and HOURS unless it is over frequency
					if [[ $FREQUENCY = M || $FREQUENCY = H && $ELAPSED -gt $INTERVAL ]]
						then
							CALC_MIN_TO_HR_ELAPS $ELAPSED
							CALC_MIN_TO_HR_AVG $AVERAGE
							RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS")
							echo "$RESPONSE" >> $OUTFILE
					elif [[ $FREQUENCY != M || $FREQUENCY != H ]]
						then	
							CALC_MIN_TO_HR_ELAPS $ELAPSED
							CALC_MIN_TO_HR_AVG $AVERAGE
							RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS")
							echo "$RESPONSE" >> $OUTFILE
					fi
			fi	
		done < $PF_BL_RUNID  
	}

PROCESS_LATE_FILE()
	{
	while read LINE 
		do 
			LOOP_TIMES_FILE
			CALC_MIN_TO_HR_ELAPS $ELAPSED
			CALC_MIN_TO_HR_AVG $AVERAGE
			#Set echo response
			RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS LONG_")		
			echo $RESPONSE >> $OUTFILE		
		done < $PF_BL_LATE_RUNID 
	}

REGISTER_FILE()
	{
		file=$OUTFILE
		$AW_HOME/exec/FILESIZE $file $err
	}

MAIN()
	{
		CHECK_FILES
		#CREATE CSV FILE, Set column header
		echo "PROCESS FLOWS, AVERAGE, ELAPSED, FREQUENCY, RUN ID, STATUS" > $OUTFILE 
		PROCESS_BACKLOG_FILE #LONG RUNNERS
		PROCESS_LATE_FILE #WAITING TO RUN
		REGISTER_FILE #REGISTER FILE
		REMOVE #REMOVE TMP FILES
	}

MAIN