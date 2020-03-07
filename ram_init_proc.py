
import sys

rvorgFile = open('nnRv_org.v')
rvorgLines = rvorgFile.readlines()
rvorgFile.close()

nnbinFile = open('ram.mem')
nnbinLines = nnbinFile.readlines()
nnbinFile.close()

rvFile = open('nnRv.v', 'w')

for code in rvorgLines:
        if 'RAM_INIT_PROCESS' in code:
            mcodeidx = 0
            for mcode in nnbinLines:
                rvFile.write("\t\tRAM[%04d]=32'h%s;" %(mcodeidx, mcode))
                mcodeidx = mcodeidx + 1;
        else:
            rvFile.write(code)

rvFile.close()
