#! /bin/bash
processRead() {
files=$(ls  correction/1-overlapper/results/*.ovb)
echo $files
totalfilenum=$(ls -l correction/1-overlapper/results/*.ovb | wc -l | cut -d " " -f1)
printf "the number of totalfiles is %d \n" $totalfilenum
if files=$(ls correction/1-overlapper/results/*.ovb)
	then
	echo ""
	else
	printf "no ovb files\n"
fi
fcombine=false
for i in $files
do
	echo $i
	((j++))
	printf "it's the %d file\n" $j
	line=$(basename $i .ovb | sed 's/^0*//')
	printf "the file name is %d\n" $line
	printf "$canuPath/overlapConvert\n"
	$canuPath/overlapConvert -G correction/step1.gkpStore -coords $i  >${line}.ovl
#	rm $i

	printf "make edge file\n"
	awk -v from="$fromlen" -v dif="$lendiff" ' {id1=$1;id2=$2;strand1=0;if($8-$7<0) {strand2=1;id2replen=$7-$8;id2from=$8} else {strand2=0;id2replen=$8-$7;id2from=$7};id1replen=$6-$5; if(id1replen>id2replen) {repdiff=id1replen-id2replen} else {id2replen-id1replen}; if(id1replen>from && id2replen>from &&repdiff<dif) {print id1"_"strand1"_" int($5/from)*from,id2"_"strand2"_" int(id2from/from)*from,int((id1replen+id2replen)/2)}}' ${line}.ovl > ${line}.edge
	printf "make bed file\n"
	awk  -v from="$fromlen" -v dif="$lendiff" '{if($8-$7<0) {id2replen=$7-$8;} else id2replen=$8-$7; id1replen=$6-$5; if(id1replen>id2replen) {repdiff=id1replen-id2replen} else {id2replen-id1replen}; if(id1replen>from && id2replen>from && repdiff < dif) {print $1,$5,$6}}' ${line}.ovl > ${line}.bed
#
	rm ${line}.ovl
	lines=$(wc -l ${line}.bed | cut -d " " -f1)
	printf "$lines\n"
	if [ $lines -gt 85000000 ]
	then
		if [ $fcombine = true ]
		then
			printf "combine with previous files\n"
			totallines=$(($(wc -l $((line-1)).bed | cut -d " " -f1) + $(wc -l ${line}.bed | cut -d " " -f1)))
			cat $((line-1)).edge ${line}.edge > ${line}_new.edge
			mv ${line}_new.edge ${line}.edge
			cat $((line-1)).bed ${line}.bed > ${line}_new.bed
			mv ${line}_new.bed ${line}.bed
			rm $((line-1)).edge
			rm $((line-1)).bed
			fcombine=false
		fi

		printf "file size is %d > 85000000, need split\n" $totallines
		fn=$(($lines/65000000 + 1))
		eachline=$(($lines/$fn+1))
		split ${line}.edge -l $eachline -d ${line}_ --additional-suffix=.edge
		split ${line}.bed -l $eachline -d ${line}_ --additional-suffix=.bed
		edgefiles=$(ls ${line}_[0-9]*edge)
		for file in $edgefiles
		do
			awk '{print $0,NR}' $file > ${file}_new
			rm $file
			mv ${file}_new $file
		done
		printf "find community in the graph\n"
		printf "line=%s\n" $line
		Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
		printf "extract result fasta file\n"
		printf "the extract fasta folder name is %s\n" $(pwd)
		if [ -e ${line}_00.line ]
		then
		linefiles=$(ls ${line}*.line)
		for file in $linefiles
		do
			name=${file%.line}
			printf "name=%s\n" $name
			sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
		done
		wait
		rm ${line}*.edge
		rm ${line}.bed
		find . -name "${line}_[0-9][0-9].bed" -delete
		fi
	elif [ $lines -lt 45000000 ]
	then
		if [ $j -eq $totalfilenum ]
		then
			printf "last file\n"
			if [ $fcombine = true ]
			then
				printf "combine with previous files\n"
				totallines=$(($(wc -l $((line-1)).bed | cut -d " " -f1) + $(wc -l ${line}.bed | cut -d " " -f1)))
				cat $((line-1)).edge ${line}.edge > ${line}_new.edge
				mv ${line}_new.edge ${line}.edge
				cat $((line-1)).bed ${line}.bed > ${line}_new.bed
				mv ${line}_new.bed ${line}.bed
				rm $((line-1)).edge
				rm $((line-1)).bed
				fcombine=false

				printf "totallines=%d\n" $totallines
				if [ $totallines -gt 85000000 ]
				then
					printf "the combined file need split\n"
					fn=$((${totallines}/65000000 + 1))
					eachline=$((${totallines}/$fn+1))
					split ${line}.edge -l $eachline -d ${line}_ --additional-suffix=.edge
					split ${line}.bed -l $eachline -d ${line}_ --additional-suffix=.bed
					edgefiles=$(ls ${line}_[0-9]*edge)
					for file in $edgefiles
					do
						awk '{print $0,NR}' $file > ${file}_new
						rm $file
						mv ${file}_new $file
					done
					printf "find community in the graph\n"
#					line=9
					printf "line=%s\n" $line
					Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
					printf "extract result fasta file\n"
					printf "the extract fasta folder name is %s\n" $(pwd)
					if [ -e ${line}_00.line ]
					then
					linefiles=$(ls ${line}*.line)
					for file in $linefiles
					do
						name=${file%.line}
						printf "name=%s\n" $name
						sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
					done
					wait
					rm ${line}*.edge
					rm ${line}.bed
					find . -name "${line}_[0-9][0-9].bed" -delete
					fi
				else
					file=${line}.edge
					awk '{print $0,NR}' $file > ${file}_new
					rm $file
					mv ${file}_new ${line}_00.edge
					mv ${line}.bed ${line}_00.bed
					printf "find community in the graph\n"
					printf "line=%s\n" $line
					Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
					printf "extract result fasta file\n"
					printf "the extract fasta folder name is %s\n" $(pwd)
					if [ -e ${line}_00.line ]
					then
					linefiles=$(ls ${line}*.line)
					for file in $linefiles
					do
						name=${file%.line}
						printf "name=%s\n" $name
						sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
					done
					wait
					rm ${line}*.edge
					find . -name "${line}_[0-9][0-9].bed" -delete
					fi
				fi
			else
				printf "last file and not combine\n"
				file=${line}.edge
				awk '{print $0,NR}' $file > ${file}_new
				#rm $file
				mv ${file}_new ${line}_00.edge
				mv ${line}.bed ${line}_00.bed
				printf "find community in the graph\n"
				printf "line=%s\n" $line
				Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
				printf "extract result fasta file\n"
				printf "the extract fasta folder name is %s\n" $(pwd)
				if [ -e ${line}_00.line ]
				then
				linefiles=$(ls ${line}*.line)
				for file in $linefiles
				do
					name=${file%.line}
					printf "name=%s\n" $name
					sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
				done
				wait
				#rm ${line}*.edge
				#find . -name "${line}_[0-9][0-9].bed" -delete
				fi
			fi
		else
			printf "not last file\n"
			if [ $fcombine = true ]
			then
				printf "combine with previous files\n"
				totallines=$(($(wc -l $((line-1)).bed | cut -d " " -f1) + $(wc -l ${line}.bed | cut -d " " -f1)))
				cat $((line-1)).edge ${line}.edge > ${line}_new.edge
				mv ${line}_new.edge ${line}.edge
				cat $((line-1)).bed ${line}.bed > ${line}_new.bed
				mv ${line}_new.bed ${line}.bed
				rm $((line-1)).edge
				rm $((line-1)).bed
				fcombine=false

				printf "totallines=%d\n" $totallines
				if [ $totallines -gt 85000000 ]
				then
					printf "the combined file need split\n"
					fn=$((${totallines}/65000000 + 1))
					eachline=$((${totallines}/$fn+1))
					split ${line}.edge -l $eachline -d ${line}_ --additional-suffix=.edge
					split ${line}.bed -l $eachline -d ${line}_ --additional-suffix=.bed
					edgefiles=$(ls ${line}_[0-9]*edge)
					for file in $edgefiles
					do
						awk '{print $0,NR}' $file > ${file}_new
						rm $file
						mv ${file}_new $file
					done
					printf "find community in the graph\n"
					printf "line=%s\n" $line
					Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
					printf "extract result fasta file\n"
					printf "the extract fasta folder name is %s\n" $(pwd)
					if [ -e ${line}_00.line ]
					then
					linefiles=$(ls ${line}*.line)
					for file in $linefiles
					do
						name=${file%.line}
						printf "name=%s\n" $name
						sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
					done
					wait
					rm ${line}*.edge
					rm ${line}.bed
					find . -name "${line}_[0-9][0-9].bed" -delete
					fi
				elif [ $totallines -lt 45000000 ]
				then
					printf "need more files to combine\n"
					fcombine=true
				else
					file=${line}.edge
					awk '{print $0,NR}' $file > ${file}_new
					rm $file
					mv ${file}_new ${line}_00.edge
					mv ${line}.bed ${line}_00.bed
					printf "find community in the graph\n"
					printf "line=%s\n" $line
					Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
					printf "extract result fasta file\n"
					printf "the extract fasta folder name is %s\n" $(pwd)
					if [ -e ${line}_00.line ]
					then
					linefiles=$(ls ${line}*.line)
					for file in $linefiles
					do
						name=${file%.line}
						printf "name=%s\n" $name
						sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
					done
					wait
					rm ${line}*.edge
					find . -name "${line}_[0-9][0-9].bed" -delete
					fi
				fi
			else
				printf "not last file and not combine, set combine=true\n"
				fcombine=true
			fi
		fi
	else
		printf "file size is ok,just process\n"
		file=${line}.edge
		awk '{print $0,NR}' $file > ${file}_new
		rm $file
		mv ${file}_new ${line}_00.edge
		mv ${line}.bed ${line}_00.bed
		printf "find community in the graph\n"
		printf "line=%s\n" $line
		Rscript --vanilla  ${DIR}/communityNew.R $line $degree $commu_size $n1 $n2 $breaks $drops
		printf "extract result fasta file\n"
		printf "the extract fasta folder name is %s\n" $(pwd)
		if [ -e ${line}_00.line ]
		then
		linefiles=$(ls ${line}*.line)
		for file in $linefiles
		do
			name=${file%.line}
			printf "name=%s\n" $name
			sed -n $(cat ${name}.line) ${name}.bed > ${name}_new.bed &
		done
		wait
		rm ${line}*.edge
		find . -name ${line}_[0-9][0-9].bed -delete
		fi
	fi
#fi
done

printf "merge the bed file\n"
cat *new.bed > all.bed
awk -v window=$window '{print $1,int($2/window)*window,int($3/window)*window}' all.bed | sort -k1,1n -k2n -u  > merged.bed
if [ $cor = true ]
then
rm step1.correctedReads.fasta.gz
cat  correction/2-correction/correction_outputs/*.fasta > all.fa
rm -rf correction/2-correction/correction_outputs
rm -rf correction/1-overlapper/queries
awk '{id="read"$1"_0";print id,$2,$3}' merged.bed > merged.new.bed
$faidxPath/faidx -b merged.new.bed -l all.fa > new.fa
else
rm -rf correction/1-overlapper/blocks
rm -rf correction/1-overlapper/queries
cut -d " " -f1 merged.bed > merged.line
split merged.line -l 3500 -d merged_ --additional-suffix=.line
for file in $(ls merged_*.line)
do
	Rscript --vanilla  ${DIR}/linenum.R $file 
done
printf "Find original read names\n"
for file in $(ls merged_*.sed)
do
	sed -n $(cat $file) correction/step1.gkpStore/readNames.txt > ${file}.name
done
cat *.name > merged.name
paste <(cut -f2 merged.name) <(cut -d " " -f2-3 merged.bed) > merged.name.bed
awk '{if($3 > $2) print $0}' merged.name.bed > merged.name.bed1
mv merged.name.bed1 merged.name.bed
printf "extract repeat sequences\n"
printf "orifile=%s\n" $home/$orifile
$faidxPath/faidx -b merged.name.bed -l $home/$orifile > new.fa
fi
newSize=$(du new.fa | cut -f1)
printf "%s\n" $newSize
printf "use ovl to find overlap\n"
if ((newSize/10))>100
then 
	newSize=$((newSize*100)) 
else
	newSize=1M
fi
$canuPath/canu -correct -p "step2" -d "temp" genomeSize=$newSize coroutcoverage=400 cormincoverage=0 maxThreads=$maxThreads maxMemory=$maxMemory overlapper=ovl gnuplottested=true minreadlength=100 minoverlaplength=20 stopafter=overlap -pacbio-corrected new.fa
if [ -e all.out ]
then
	rm all.out
fi
for i in temp/correction/1-overlapper/001/*.ovb
do

	echo $i
	$canuPath/overlapConvert -G temp/correction/step2.gkpStore -coords ${i}  >> all.ovl ;
done

printf "filter overlap file to merge repeat\n"
python ${DIR}/edge_1.py all.ovl temp/correction/step2.gkpStore/reads.txt $fromlen $lendiff $ratio new.edge
printf "use community detection to merge repeat\n"
Rscript --vanilla  ${DIR}/merge.R
awk '{print $1,$5,$6}'  all.ovl > new.bed
split new.line -l 500 -d new_ --additional-suffix=.line 
for file in $(ls new_*.line)
do
	Rscript --vanilla ~/replong/linenum.R $file
done
for file in $(ls new_*.sed)
do
	name=${file#new_}
	name=${name%.line.sed}
	sed -n $(cat $file) new.bed > new_${name}.bed &
done
wait
for file in $(ls new_*.bed)
do
	name=${file#new_}
	name=${name%.bed}
	sort -k1,1n $file > new_${name}_sorted.bed &
done
wait

for file in $(ls new_*_sorted.bed)
do
	name=${file#new_}
        name=${name%_sorted.bed}
	cut -d " " -f1 $file > new_${name}_sorted.line
	Rscript --vanilla  ${DIR}/linenum.R  new_${name}_sorted.line
	sed -n $(cat new_${name}_sorted.line.sed) temp/correction/step2.gkpStore/readNames.txt > new_${name}_sorted.name
done

printf "Find original read names\n"
cat new_*.name > new_sorted.name

cat  new_*_sorted.bed > new_sorted.bed


paste <(cut -f2 new_sorted.name) <(cut -d " " -f2-3 new_sorted.bed) > new.name.bed
printf "extract repeat sequences\n"
$faidxPath/faidx -b new.name.bed new.fa > result.fa
awk '/^>/{print ">" ++i; next}{print}' < result.fa > rename.fa
rm result.fa
mv rename.fa result.fa
cp result.fa ${home}/
echo $temp
#rm -rf temp
}
