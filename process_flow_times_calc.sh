#!/bin/sh -x

sleep 1

#SET OUTPUT FILE
OUTFILE=$AW_HOME/out/long_runner.$jobid.csv

#FUNCTIONS

#REMOVE TMP FILES
REMOVE()
	{
		rm /tmp/process_flow_backlog.$1
		rm /tmp/process_flow_backlog_late.$2
	}

#TURN HOURS INTO MINUTES FUNCTION 
CALC_INTERVAL()
	{
		if [[ $FREQUENCY = "H" ]]
			then 
				((I = $INTERVAL * 60))
				INTERVAL=$I
			else
				:
		fi
	}

#Calc minutes to hours for elapsed 
CALC_MIN_TO_HR_ELAPS()
	{
		
		if [[ $1 -gt 59 ]]
			then 
				((ELAPSED = $1 / 60))
				ELAPSED="$ELAPSED HOUR(S)"
			else 
				ELAPSED="$ELAPSED MINUTE(S)"
		fi
	}

#Calc minutes to hours for average
CALC_MIN_TO_HR_AVG()
	{
		AVG=$1
		
		if [[ $AVG -gt 59 ]]
			then 
				((AVERAGE = $AVG / 60))
				AVERAGE="$AVERAGE HOUR(S)"
			else 
				AVERAGE="$AVERAGE MINUTE(S)"
		fi
	}
	
#CALC IF PROCESS FLOW IS RUNNING LONG FUNCTION
LONG_RUNNER()
	{
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

EXCEPTIONS()
	{
		PROCESS_FLOW=$1; SD=$2
		
		if [[ $PROCESS_FLOW = "UTY_GBL_SALES_RECURRING_1MIN" ]]
			then ((k = $2 + 100))
			STAND_DEV=$k
		fi
	}

#BODY
	
#FILE CHECK EXISTS
if [ -e /$AW_HOME/out/process_flow_times.$2 ] 
	then
		:
	else 
		echo "FILE `ls /$AW_HOME/out/process_flow_times.$2` DOES NOT EXIST";
		REMOVE $1 $3
		exit 1
fi

#FILE CHECK EXISTS
if [ -e /tmp/process_flow_backlog.$1 ]
	then
		: 
	else 
		echo "FILE `ls /tmp/process_flow_backlog.$1` DOES NOT EXIST"
		REMOVE $1 $3
		exit 1
fi

#FILE CHECK EXISTS
if [ -e /tmp/process_flow_backlog_late.$3 ]
	then
		: 
	else 
		echo "FILE `ls /tmp/process_flow_backlog_late.$3` DOES NOT EXIST"
		REMOVE $1 $3
		exit 1
fi

#Create output file, Set column header
echo "PROCESS FLOWS, AVERAGE, ELAPSED, FREQUENCY, RUN ID, STATUS" > $OUTFILE

#CREATE PROCESSING FILE
while read LINE 
	do 
		#SET VARIABLES
		PF=$(echo $LINE | awk '{print $1}')
		FILE=$(echo $LINE | awk '{print $1, $4, $5, $6, $7}') #PROCESS_FLOW, ELAPSED, FREQUENCY(D H M), INTERVAL(MIN), RUNID
		TIMES=$(cat /$AW_HOME/out/process_flow_times.$2 | grep -w $PF | awk '{print $4, $6}') #AVERAGE, STAND_DEV
		COMBO=$(echo "$FILE $TIMES") # 1 Process_flow, 2 ELAPSED, 3 FREQUENCY, 4 INTERVAL, 5 RUNID, 6 AVERAGE, 7 STAND_DEV
		ELAPSED=$(echo $COMBO  | awk '{print $2}'); FREQUENCY=$(echo $COMBO  | awk '{print $3}')
		INTERVAL=$(echo $COMBO  | awk '{print $4}'); RUNID=$(echo $COMBO  | awk '{print $5}')
		AVERAGE=$(echo $COMBO  | awk '{print $6}'); STAND_DEV=$(echo $COMBO  | awk '{print $7}')
		#echo $PF $ELAPSED $FREQUENCY $INTERVAL $RUNID $AVERAGE $STAND_DEV
		
		if [[ -z $AVERAGE || -z $STAND_DEV ]]
			then
				AVERAGE=0
				STAND_DEV=0
		fi
		
		#PROCESS 
		#EXCEPTIONS $PF $STAND_DEV 
		#update hour interval
				
		CALC_INTERVAL $FREQUENCY $INTERVAL
				
		#calc long runners
		LONG_RUNNER $STAND_DEV $AVERAGE $ELAPSED
					
		#remove unwanted entries
		if [[ -z $STATUS ]] || [[ $AVERAGE -eq 0 ]]
			then :
			else #REMOVE CHECK TO SEE IF MINUTES and HOURS unless it is over frequency
				if [[ $FREQUENCY != M ]] || [[ $FREQUENCY != H ]]
					then 
						CALC_MIN_TO_HR_ELAPS $ELAPSED
						CALC_MIN_TO_HR_AVG $AVERAGE
						RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS")
						echo "$RESPONSE" >> $OUTFILE
					else [[ $FREQUENCY = M || $FREQUENCY = H && $ELAPSED -gt $INTERVAL ]]
							CALC_MIN_TO_HR_ELAPS $ELAPSED
							CALC_MIN_TO_HR_AVG $AVERAGE
							RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS")
							echo "$RESPONSE" >> $OUTFILE
				fi
		fi	
	done < /tmp/process_flow_backlog.$1  

#Late starting process flows

while read LINE 
	do 
		#SET VARIABLES
		PF=$(echo $LINE | awk '{print $1}')
		FILE=$(echo $LINE | awk '{print $1, $4, $5, $6, $7, $8}') #PROCESS_FLOW, ELAPSED, FREQUENCY(D H M), INTERVAL(MIN), RUNID, STATUS
		TIMES=$(cat /$AW_HOME/out/process_flow_times.$2 | grep -w $PF | awk '{print $4, $6}') #AVERAGE, STAND_DEV
		COMBO=$(echo "$FILE $TIMES") # 1 Process_flow, 2 ELAPSED, 3 FREQUENCY, 4 INTERVAL, 5 RUNID, 6 STATUS 7 AVERAGE, 8 STAND_DEV
		ELAPSED=$(echo $COMBO  | awk '{print $2}'); FREQUENCY=$(echo $COMBO  | awk '{print $3}')
		INTERVAL=$(echo $COMBO  | awk '{print $4}'); RUNID=$(echo $COMBO  | awk '{print $5}'); STATUS=$(echo $COMBO  | awk '{print $6}')
		AVERAGE=$(echo $COMBO  | awk '{print $7}'); STAND_DEV=$(echo $COMBO  | awk '{print $8}')
		#echo $PF $ELAPSED $FREQUENCY $INTERVAL $RUNID $STATUS $AVERAGE $STAND_DEV 
		
		if [[ -z $AVERAGE || -z $STAND_DEV ]]
			then
				AVERAGE=0
				STAND_DEV=0
		fi

		CALC_MIN_TO_HR_ELAPS $ELAPSED
		CALC_MIN_TO_HR_AVG $AVERAGE
		
		#Set echo response
		RESPONSE=$(echo "$PF,$AVERAGE,$ELAPSED,$FREQUENCY,$RUNID,$STATUS LONG_")
		
		echo $RESPONSE >> $OUTFILE
		
		
	done < /tmp/process_flow_backlog_late.$3 


#set registered files
file=$OUTFILE
$AW_HOME/exec/FILESIZE $file $err
sleep 1 
#remove files from tmp
REMOVE $1 $3