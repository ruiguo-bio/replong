# RepLong

RepLong is used to find repetitive elements in the genome using long reads. It uses a fork of canu(https://github.com/marbl/canu/) and depends on R with library "igraph", python and faidx(https://pypi.python.org/pypi/pyfaidx).

## Install:
To install canu, follow the instruction below:

	git clone https://github.com/ruiguo-bio/canu
	cd canu/src
	make -j <number of threads>

Canu depends on Java 8, please add Java path into Path variable or set in the RepLong parameter -j.

Please install R and R library "igraph", python, and faidx to run RepLong.

After compiling, canu and faidx path should be add to the Path variable or set in the replong parameters -u and -a.

If the canu and faidx path is added to the Path variable, the -u and -a option can be skipped.

The minimum read length and mininum overlap length to calculate in RepLong can be set by parameters -r and -o. The default is 1000bp and 500bp.

## Run:
	./replong.sh -f <long reads input> -s <an estimate of the whole genome size> -t <place of temporary files>  [-u <canu path>] [-a <faidx path>] [-j <java path>] [-r minimum read length] [-o minimum overlap length]

For example:
	./replong.sh -f dmel.polished.fa -s 165M  -t ~/temp -u ~/software/canu-1.4/Linux-amd64/bin -a /usr/local/bin


Please replace the "./replong.sh" with the actual path of replong to run it and specify an empty folder for the temp file.

The result fasta file will be place in the current folder, and the temporary files will be deleted.
