#set -x;

#'============================== The Beginning of the Copyright Notice ==========================================================
#' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;	
#' Series and Russian passport number (only the last two digits for each one): **22-****91					
#' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007					
#' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
#' Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
#' Contact: 	a.prokopyev.resume at gmail dot com
#'
#' All source code contained in this file is protected by copyright law.
#' This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#' PROVIDED FOLLOWING RESTRICTIONS APPLY:
#' Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
#' Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
#' \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
#' specific language governing permissions and limitations under the License.
#'================================= The End of the Copyright Notice =============================================================

docker_run()
{
	ContainerImageName=$1;
	ContainerName=$2;
	DockerRunCmd="docker run -dti -v $(pwd):/workspace -v /utils:/utils -w /workspace --user root --name $ContainerName $ContainerImageName";
	Result=0;
	($DockerRunCmd 2>&1; Result=$?) | cat > /dev/null;
	return $Result;
}

docker_exec()
{
	ContainerName=$1;
	
	CmdArgs="${@:2}";
	
	InText=$(timeout 0.1s ifne cat);

	if [ -n "$InText" ]; then
		Options=" -i ";
	else
		Options=" -ti ";
	fi;
	DockerExecCmd="docker exec $Options $ContainerName $CmdArgs";
	echo "===> Executing command: $DockerExecCmd";
	Result=0;
	if [ -n "$InText" ]; then
		echo -n $InText | $DockerExecCmd;
		Result=$?;
	else
		$DockerExecCmd;
		Result=$?;
	fi;
	reuturn $Result;
}	
