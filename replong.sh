#! /bin/bash
SECONDS=0
DIR=$( cd $(dirname $0) ; pwd -P )
printf "script path = %s\n" $DIR
#source ${DIR}/generateFasta.sh
source ${DIR}/processRead.sh 
# set flog vars to empty
lines=65000000 genomeSize= range=250 file= temp= lendiff=200 fromlen=250 ratio=0.96 drops=3 n1=3 n2=8 degree=10 commu_size=10 window=100 cor=false breaks=200 outputfile="replong.log" canuPath="" faidxPath=""
while getopts f:s:n:l:t:b:q:w:d:x:c:g:a:m:z:u: opt
do
	case $opt in
		f)	file=$OPTARG
			;;
		s)	genomeSize=$OPTARG
			;;
		n)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))
			continue
			fi
			range=$OPTARG
			;;
		l)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			lines=$OPTARG
			;;
		t)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			temp=$OPTARG
			;;
		b)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			breaks=$OPTARG
			;;
		x)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			drops=$OPTARG
			;;
		q)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			n1=$OPTARG
			;;
		w)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			n2=$OPTARG
			;;
		d)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			degree=$OPTARG
			;;
		u)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			canuPath=$OPTARG
			;;
		a)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			faidxPath=$OPTARG
			;;
		g)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			lendiff=$OPTARG
			;;
		c)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			cor=$OPTARG
			;;
		m)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			fromlen=$OPTARG
			;;
		z)	if [[ $OPTARG = -* ]]; then
			((OPTIND--))  
			continue
			fi
			outputfile=$OPTARG
	esac
done
shift $((OPTIND - 1))
printf "file=%s\n" $file
printf "genomeSize=%s\n" $genomeSize
#printf "range=%s\n"	$range
printf "correction=%s\n" $cor
#printf "lines=%s\n" $lines
printf "temp folder=%s\n" ${temp}
#printf "breaks=%d\n" ${breaks}
#printf "n1=%d\n" $n1
#printf "n2=%d\n" $n2
#printf "degree=%d\n" $degree
#printf "commu_size=%d\n" $commu_size
#printf "drops=%d\n" $drops
#printf "lendiff=%d\n" $lendiff
#printf "ratio=%s\n" $ratio
#printf "window=%d\n" $window
#printf "fromlen=%d\n" $fromlen
#printf "outputfile=%s\n" $outputfile
printf "canu path is %s\n" $canuPath
printf "faidx path is %s\n" $faidxPath
home=$(pwd)
orifile=$file 
printf "original place=%s\n" $home
mkdir $temp
if [ -z $canuPath ]
then
	canuPath=$(which canu)	
fi
if [ -z $faidxPath ]
then
	faidxPath=$(which faidx)	
fi

if [ $cor = true ]
then
	
	printf "Use raw reads\n"
	canu -correct -p "step1" -d $temp genomeSize="$genomeSize"  saveReadCorrections=T corOutCoverage=400 gnuplotTested=true corMinCoverage=0 -pacbio-raw "$file"
	printf "the folder is %s\n" $temp
	cd $temp
	printf "process reads\n"
	processRead
else
	printf "Use corrected reads\n"
	canu -correct -p "step1" -d $temp genomeSize="$genomeSize" corOutCoverage=400 gnuplotTested=true corMinCoverage=0  stopAfter=overlap -pacbio-corrected "$file"
	printf "the folder is %s\n" $temp
	cd $temp
	printf "process reads\n"
	processRead
fi	
echo $parameters >> ${home}/${outputfile}
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed." >> ${home}/${outputfile}
rm -rf correction
rm -rf temp
rm *.bed
rm *.line
cd $home
