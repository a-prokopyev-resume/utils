#===== The beginning of the Copyright Notice =====
copyright()
{

echo -e "
'============================== The Beginning of the Copyright Notice ===========================================================================
' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;
' Series and Russian passport number (only the last two digits for each one): **22-****91
' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
' Contact: alexander.prokopyev at aulix dot com
' Copyright (c) Alexander B. Prokopyev, 2023, All Rights Reserved.
'
' All source code contained in this file is protected by copyright law.
' 
' FOLLOWING RESTRICTIONS APPLY:
'  The AUTHOR explicitly prohibits to use of this file content by any method (including but not limited to copying, distribution, modification, 
'  making any derivative works) without a prior explicit authentic written hand-signed permission of the AUTHOR.
'  This also implies that nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
'================================= The End of the Copyright Notice ==============================================================================
";

}

copyright;
#===== The end of the Copyright Notice =====

#set -x;

Dir=$1;
Account=$2;
KnownRepoNames=${@:3};

#echo $Dir;
#echo $Account;
#echo $KnownRepoNames;
#exit;

CheckGithubRepository()
{
	Repo=$1;
	if timeout 3 git ls-remote $Repo | grep HEAD; then
		return 0; # Good repo
	else
		return 1; # Bad repo
	fi;
}


#SubDir=$2;

mkdir $Dir/$Account;
cd $Dir/$Account;

for RepoName in $KnownRepoNames; do
	RepoURL="https://github.com/$Account/$RepoName";
	if CheckGithubRepository $RepoURL; then
		GoodRepoURL=$RepoURL;
		GoodRepoName=$RepoName;
		break;
	fi;
done;

if [ -z "$GoodRepoURL" ]; then
	echo "Error: Cannot find repository!" >&2;
	exit 1;
fi;

git clone $GoodRepoURL;

Result=$?;
if [ $Result == 0 ]; then
	pwd;
	cd $GoodRepoName;
	/utils/du.sh;
	chown alex:alex -R $Dir/$Account;
	ls -ald ../../$Account; 
else
	echo "Bad exit from git, exit code: $Result";
	exit $Result;
fi;
