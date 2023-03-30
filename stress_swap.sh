#!/bin/bash

# Examples of usage:
# ./stress_swap.sh --help
# ./stress_swap.sh --swappiness="30 50 70" --mem=98% --time=30

# Arg passing source code location: https://gitlab.mbedsys.org/mbedsys/bashopts/-/blob/master/bashopts.sh
source /utils/dev/bashopts.sh; # shall be placed here in advance for example by wget

#===== The beginning of the Copyright Notice =====
copyright()
{

echo -e "
'============================== The Beginning of the Copyright Notice ==========================================================
' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;	
' Series and Russian passport number (only the last two digits for each one): **22-****91					
' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007					
' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
' Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
' Contact: 	a.prokopyev.resume at gmail dot com
'
' All source code contained in this file is protected by copyright law.
' This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
' PROVIDED FOLLOWING RESTRICTIONS APPLY:
' Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
' Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
' \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
' specific language governing permissions and limitations under the License.
'================================= The End of the Copyright Notice =============================================================
";

}

#copyright;
#===== The end of the Copyright Notice =====

bashopts_setup \
	-n "stress_swap.sh" \
	-d "SWAP stress demo. Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved." \
	-u "
		./stress_swap.sh --help 
		./stress_swap.sh --swappiness=\"30 50 70\" --mem=99% --time=30
	";
	bashopts_declare -n SwappinessSet 	-l swappiness 	-o s	-t string -v "0 30 50 70 99 100" -d "Variants of explored swappiness";
	bashopts_declare -n MemAmount 		-l mem 		-o m 	-t string -v 98% -d "Amount of RAM being stressed, the same as --vm-bytes";	
	bashopts_declare -n StressTime 		-l time 	-o t	-t number -v 30 -d "Duration of stress execution (in seconds), shall be at least 30 to allow swapping to start";
	bashopts_declare -n WaitFreeMem		-l pause 	-o p	-t number -v 5 -d "Pause to wait to free memory after stress completes (in seconds)";
	bashopts_declare -n StressTimeAdjustment -l adjust 	-o a	-t string -v 1.03 -d "Script lag compensation ratio";
	bashopts_declare -n ShallShowCopyright 	-l copyright 	-o c	-t boolean -v false -d "Whether to show copyright notice and licensed rights";
bashopts_parse_args "$@"; bashopts_process_opts;

if $ShallShowCopyright; then
	copyright;
	exit;
fi;

#exit;

#SwappinessSet="0 30 50 70 99 100"; # variants of explored swappiness
#StressTime=30; # in seconds
#WaitFreeMem=5; # in seconds
#MemAmount="98%"; # Amount of RAM being stressed, the same as --vm-bytes
#StressTimeAdjustment=1.09; # Script lag compensation ratio

stressor()
{
	AdjustedStressTime=$(echo $StressTime*$StressTimeAdjustment | bc -l);

	Stressor="--vm-bytes $MemAmount --vm-keep -m 1";
#	Stressor=" --brk 2 --stack 2 --bigheap 2";
#	Stressor=" --vm 1 --vm-bytes $MemAmount --vm-method all --verify -v
#	Stressor=" --vm 1 --vm-hang 0"
#	Stressor=" --vm 8"
#	Stressor=" --vm 2 --vm-bytes 2G --mmap 2 --mmap-bytes 2G --page-in" # Generating a virtual memory pressure
#	Stressor=" --userfaultfd 0 --perf" # Generating major page faults in a program

set -x;
	stress-ng $Stressor --timeout $AdjustedStressTime;
set +x;	
}

printf_vmstat()
{
	LineNumber=$1;
	Label=$2; 
	printf "%4s" $Label; vmstat -a --timestamp | awk "NR == $LineNumber { print; }";
}

vmstat_header()
{
	printf_vmstat 1 "----";
        printf_vmstat 2 "----";
}

vmstat_line()
{
	LN=$1;
	printf_vmstat 3 "$LN:";
}

clean_swap()
{
	echo "Please wait for clearing SWAP by swapoff and swapon commands ...";
	swapoff -a;
	swapon -a;
	free;
}

for S in $SwappinessSet; do
	echo "======= Beginning new test pass for vm.swappiness=$S at $(date):";
	echo -n "=> "; sysctl vm.swappiness=$S;
	clean_swap;
	
	stressor &

	sleep 0.05s; # Wait for background stressor execution to avoid breaking vmstat header

	vmstat_header;
	for ((i=1;i<=StressTime+WaitFreeMem;i++)); do
		sleep 1s; vmstat_line $i;
		if [ $i == $((StressTime-1)) ]; then
			free; # Show current stat before stressor completion
		fi;
	done;
	echo; # New empty line
done;
