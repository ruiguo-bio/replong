#!/usr/bin/python
import sys

def buildEdgeWithFrom(inputfile,threshold):
    with open(inputfile) as f1:
        edgefile=inputfile[0:-4] + '.edge'
        bedfile=inputfile[0:-4] + '.bed'
        with open(edgefile,'w') as f2, open(bedfile,'w') as f3:

            for line in f1:

                fields = line.split()
                readid1 = fields[0]
                readid2 = fields[1]


                #id1strand = fields[4]
                id1from = int(fields[4])
                id1to = int(fields[5])
                id1replength = id1to - id1from


                id2from = int(fields[6])
                id2to = int(fields[7])
                id2strand = '1' if id2from > id2to else '0'
                id2replength = abs(id2from - id2to)

                if id1replength < 100 or id2replength < 100 \
                        or abs(id1replength - id2replength > 600):

                    continue

                fromrange1 = id1from // threshold * threshold
                fromrange2 = id2from // threshold * threshold
                meanlength = int((id1replength+id2replength)/2)

                f2.write(readid1 + '_' + '0' + '_' + str(fromrange1) + ' ' +
                         readid2 + '_' + id2strand + '_' + str(fromrange2) +
                         ' ' + str(meanlength) + '\n')
                f3.write(readid1 + ' ' + str(id1from) + ' ' + str(id1to) + '\n')

def buildEdge(inputfile,outputfile,threshold):
    with open(inputfile) as f1:
        with open(outputfile,'w') as f2:
            for line in f1:
                fields = line.split(" ")
                readid1 = fields[0]
                readid2 = fields[1]


                id1strand = fields[4]
                id1from = int(fields[5])
                id1to = fields[6]
                id1replength = int(fields[7])

                id2strand = fields[9]
                id2from = int(fields[10])
                id2to = fields[11]
                id2replength = int(fields[12])

                if id1replength < 100 or id2replength < \
                        100 or abs(id1replength - id2replength) > 600:
                    continue

                fromrange1 = id1from // threshold * threshold
                fromrange2 = id2from // threshold * threshold

                f2.write(readid1 + '_' + id1strand + '_' + str(fromrange1) + ' ' +
                         readid2 + '_' + id2strand + '_' + str(fromrange2) +
                         ' ' + str(id1replength) + '\n')




#inputname = sys.argv[1]
#threshold = int(sys.argv[2]) #from threshold

#buildEdge(inputname,outputname,100)
buildEdgeWithFrom('120.ovl',250)