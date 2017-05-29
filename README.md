# RepLong

RepLong is used to find repetitive elements in the genome using long reads. It uses a fork of canu(https://github.com/marbl/canu/) and depends on R with library "igraph" and faidx(https://pypi.python.org/pypi/pyfaidx).

## Install:
To install canu, follow the instruction below:

	git clone https://github.com/ruiguo-bio/canu
	cd canu/src
	make -j <number of threads>

After compiling, canu should be add to the user path for RepLong to call.

## Run:
	./replong.sh -f <long reads input> -s <an estimate of the whole genome size> -t <place of temporary files>  

For example,
	./replong.sh -f dmel.polished.fa -s 165M  -t ~/temp

Please replace the "./replong.sh" with the actual path of replong to run it.

The result fasta file will be place in the current folder, and the temporary files will be deleted.
