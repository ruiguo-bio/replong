# RepLong

RepLong is used to find repetitive elements in the genome using long reads. It uses a fork of canu(https://github.com/marbl/canu/) and depends on R with library "igraph", python  and faidx(https://pypi.python.org/pypi/pyfaidx).

## Install:
To install canu, follow the instruction below:

	git clone https://github.com/ruiguo-bio/canu
	cd canu/src
	make -j <number of threads>

After compiling, canu and faidx path should be add to the user path or set in the replong parameters.

## Run:
	./replong.sh -f <long reads input> -s <an estimate of the whole genome size> -t <place of temporary files>  -u <canu path> -a <faidx path> 

For example:
	./replong.sh -f dmel.polished.fa -s 165M  -t ~/temp -u ~/software/canu-1.4/Linux-amd64/bin//canu -a /usr/local/bin/faidx

Please replace the "./replong.sh" with the actual path of replong to run it and specify an empty folder for the temp file.

The result fasta file will be place in the current folder, and the temporary files will be deleted.
