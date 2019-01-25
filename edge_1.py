#!/usr/bin/python
import sys


def buildEdgeWithFrom(overlapfile,readlengthfile,threshold1,threshold2,threshold3,
                      outputfile):
    lengthDict = {}
    outset = set()
    with open(overlapfile, 'r') as a, open(readlengthfile, 'r') as b,\
            open(outputfile,'w') as f2,open("leftread.line","w") as f3:

        for line in b:
            fields = line.split()
            readid = fields[0]
            readlength = fields[2]
            lengthDict[readid] = int(readlength)

        linenum = 0
        for line in a:
            linenum += 1
            fields = line.split()
            readid1 = fields[0]
            readid2 = fields[1]

            replength = int(fields[3])

            id1from = int(fields[4])
            #id1to = int(fields[5])

            id2from = int(fields[6])
            id2to = int(fields[7])

            id1length = lengthDict[readid1]
            id2length = lengthDict[readid2]

            fromrange1 = id1from // threshold1 * threshold1
            fromrange2 = id2from // threshold1 * threshold1


            id1strand = 0

            id2strand = 1 if id2from >= id2to else 0

            # if abs(id1replength - id2replength)> threshold3:
            #     continue

            # length difference should be less than threshold3
            if abs(id1length - id2length) > threshold2:
                continue

            #replength should not be less than a ratio of the total read length
            if replength < (id1length * threshold3) or \
                   replength < (id2length * threshold3):
                continue

            f2.write(readid1 + '_' + str(id1strand) + '_' + str(fromrange1) + ' ' +
                 readid2 + '_' + str(id2strand) + '_' + str(fromrange2) +
                 ' ' + str(replength) + ' ' + str(linenum) + '\n')

            outset.add(readid1)
            outset.add(readid2)
        totalread= set(lengthDict.keys())
        leftread=list(totalread.difference(outset))
        for read in leftread:
            f3.write(read + '\n')


ovlfile = sys.argv[1]
print("ovlfile is: ",ovlfile)
lengthfile = sys.argv[2]
print( "lengthfile is: ", lengthfile)
threshold1 = int(sys.argv[3])
print( "fromlength is: ", threshold1)
threshold2 = int(sys.argv[4])
print( "lendiff is: ", threshold2)
threshold3 = float(sys.argv[5])
print( "ratio is: ",threshold3)
outfilename = sys.argv[6]
print( "output_edge is: " ,outfilename)
#threshold1 from
#threshold2 total length
#threshold3 repeat length ratio
# ovlfile = 'all.out'
# lengthfile = 'readlength'
# threshold1 = 250
# threshold2 = 200
# threshold3 = 0.96
# outfilename = 'new.edge'



buildEdgeWithFrom(ovlfile,lengthfile,threshold1,threshold2,threshold3,
                      outfilename)

