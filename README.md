# RepLong

RepLong is used to find repetitive elements in the genome using long reads. It uses a fork of canu(https://github.com/marbl/canu/) and depends on R with library "igraph", python and faidx(https://pypi.python.org/pypi/pyfaidx). RepLong is tested on Linux Ubuntu 14.04 and CentOS 7, with GNU awk and split.

## Install:
To install RepLong, follow the instruction below:

	git clone https://github.com/ruiguo-bio/replong
	./install.sh

This operation will clone the RepLong and Canu 1.4 which is used by RepLong. Please do not install the latest canu by yourself. install.sh will install canu 1.4 automatically.

Please install R and R library "igraph", python(2.7 or 3.4 above), and faidx to run RepLong.

Canu depends on Java 8, please add Java path into Path variable or set in the RepLong parameter -j.

The faidx path should be add to the Path variable or set in the RepLong parameters -a. If the faidx path is added to the Path variable, the -a option can be skipped.



## Run:
	./replong.sh -f <long reads fasta> -s <an estimate of the whole genome size> -t <place of temporary files> [-a <faidx path>] [-j <java path>] [-r minimum read length] [-o minimum overlap length] [-h maximum thread] [-e maximum memory] [-c true]

The mandatory parameters are -f , -s and -t. The input file should be a fasta file, and for each sequence the sequence name should not contain white space. For example, it should be like:

\>homoNewSens_16752710
AGGTATCCTGCCGTGGGGTGAACCCTGCATAGAGATGGAGGCAGGGTCCGTAAAGGGCTGGGTGCAGGCATAAATCCCTTCTTCCCTGAACATCAGGCGGGAGTCTGGGCTGTGATACCTTGACACACCTGTGGCCCTAAACTTTCCCCATTTATTTATTTGGCTGTAATTAAATCCTGTTTCTTCCAGATGCTGGAGGTACCAGCCTAGCCCTAAAGAGACCAGGGAAGTGGGCTGGAAAGAAACAAAGGCAGGCTTGGAGGATTAATCTGTGATACCTTTATAGAAACTGTGAAAGGAAGGAAAGCCTGACTTGCTACAGCACAGAGGAGCCCGGAGGACATTATGCTCGATTAAATAAGCCCGTCCCCAAACGACAGGTATTATATGATTTTACAAATATAAAATGTATGGTCCCTAGAGGGGCCAGAGTCACAGAGATGGAAAGTGGAATGGCGGGTGCCGGGGCTGGGGAGCTACTGTGCAGGGGACAGAGCTTTAGTTCTGCAAGATGAAACAGTTCTGGAGATGGACGGTGGGGATGGGGGCCCAGCAATGGGAACGTGCTTAATGCCACTGAACTGGGCACTTAAACGTGGTGAAAACTGTAAAAGTCATGTGTATTTTTCTACAATTAAAAA

The -s parameter is an estimate of the whole genome size. For drosophila input, it may be set to 165M, and for human input, it may be set to 3G. Actually that parameter is not quite relevant in RepLong, and it is used in Canu for the assembly step. So it is feasible to set that parameter to a small number, like 50M for drosophila and 500M for human, and that can repress the error if Canu says the resource is not enough.

The -t parameter is to set the place to place temporary files of RepLong. That folder should be large enough, typically 100G space for human input of 2G and 50G for drosophila input of 7G. If the input sequences are large, that space requirement is higher.

The -c parameter is used to enable read correction step. The default is false and that can be set to true. If the raw reads is used as input, it is recommended to set -c to true.

The minimum read length and mininum overlap length to calculate in RepLong can be set by parameters -r and -o. The default is 1000bp and 500bp.

The max thread number and max memory usage can be set by parameter -h and -e. For example -h 20 -e 5 means 20 threads and 5G memory usage. The default use all the resources available. Those parameters are connected with the -s parameter, soif there are messages like the resources are not enough to run canu, please set a smaller -s parameter, or do not set -h and -e parameters.

For example, to use corrected long reads:

	./replong.sh -f human_100k.fa -s 500M -t /2T/hum_100k

To use raw long reads:

	./replong.sh -f dro_100k.fa -s 100M -t /2T/dro_100k -c true


The human test file of 100k reads can be downloaded from https://drive.google.com/open?id=0B90UmIY8m2PYblAyQ0tnQ0E3MDA

The drosophila test file of 100k reads can be downloaded from https://drive.google.com/open?id=0B90UmIY8m2PYcTl6WVpyQmdfM3c

The drosophila repeat result using raw sequences, 800k reads sampled from http://gembox.cbcb.umd.edu/mhap/raw/dmel_filtered.fastq.gz can be found on https://drive.google.com/open?id=0B90UmIY8m2PYWWdhVjFpLXU3cFU

The human repeat result using polished sequences, 900k reads sampled from http://gembox.cbcb.umd.edu/mhap/data/human.polished.fastq.bz2 can ben found on https://drive.google.com/open?id=0B90UmIY8m2PYVlRxME5FV0loelE

Please replace the "./replong.sh" with the actual path of replong to run it and specify an empty folder for the temp file.

## Result:
The result fasta file will be place in the current folder, and the temporary files will be deleted. 

If the repeat number of each repeat is needed, please blast the repeat read to the input long read. The number of blast matches for each read is the coverage of that read. That coverage divides the average coverage of long read input can give the copy number of each repeat read.

## Issues report

If you find replong issues, please run it again, with "2>&1 | tee replong.log" in the end of your command (without quote). Then send the replong.log together with the description of your issue.
