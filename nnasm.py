
import sys

MOP_UIMM       = 0
MOP_LOGI       = 1
MOP_MEMY       = 2
MOP_JUMP       = 3

SOP_UIMM_L     = 0
SOP_UIMM_H     = 1

SOP_LOGI_ADD   = 0
SOP_LOGI_SUB   = 1
SOP_LOGI_LLS   = 2
SOP_LOGI_LRS   = 3
SOP_LOGI_ARS   = 4
SOP_LOGI_AND   = 5
SOP_LOGI_OR    = 6
SOP_LOGI_XOR   = 7

SOP_MEMY_L     = 0
SOP_MEMY_S     = 1

SOP_JUMP_EQ    = 0
SOP_JUMP_NE    = 1
SOP_JUMP_LT    = 2
SOP_JUMP_GE    = 3

cmdParse = {
	'luil': {'num':3, 'type':'I', 'mop':MOP_UIMM, 'sop':SOP_UIMM_L},
	'luih': {'num':3, 'type':'I', 'mop':MOP_UIMM, 'sop':SOP_UIMM_H},

	'add' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_ADD},
	'sub' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_SUB},
	'lls' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_LLS},
	'lrs' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_LRS},
	'ars' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_ARS},
	'and' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_AND},
	'or'  : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_OR },
	'xor' : {'num':5, 'type':'R', 'mop':MOP_LOGI, 'sop':SOP_LOGI_XOR},

	'ldr' : {'num':5, 'type':'R', 'mop':MOP_MEMY, 'sop':SOP_MEMY_L},
	'str' : {'num':5, 'type':'R', 'mop':MOP_MEMY, 'sop':SOP_MEMY_S},

	'jeq' : {'num':5, 'type':'R', 'mop':MOP_JUMP, 'sop':SOP_JUMP_EQ},
	'jne' : {'num':5, 'type':'R', 'mop':MOP_JUMP, 'sop':SOP_JUMP_NE},
	'jlt' : {'num':5, 'type':'R', 'mop':MOP_JUMP, 'sop':SOP_JUMP_LT},
	'jge' : {'num':5, 'type':'R', 'mop':MOP_JUMP, 'sop':SOP_JUMP_GE},
}

asFile = open('nnas.s')
asLines = asFile.readlines()
asFile.close()

cmdAddr = 0
cmdSymbol = {}
assCode = []
symbolUnsolv = []

for cmd in asLines:
	cmdList = cmd.strip().split()
	if not cmdList:
		continue
	if cmdList[0][-1] == ':':
		cmdSymbol[cmdList[0].replace(':', '')] = cmdAddr
		continue
	if cmdList[0][0] == '#':
		continue
	if cmdList[0] == ".data":
		if len(cmdList) != 2:
			print ('Error format, ', cmdList, 'should add data')
			sys.exit(1)
		assCode.append(int(cmdList[1], 0))
		cmdAddr = cmdAddr + 4
		continue
	if cmdList[0] not in cmdParse.keys():
		print ('Error format oper, ', cmdList)
		sys.exit(1)
	cmdParseDict = cmdParse[cmdList[0]]
	if len(cmdList) != cmdParseDict['num']:
		print ('Error format len, ', cmdList, len(cmdList), cmdParseDict['num'])
		sys.exit(1)
	if cmdParseDict['type'] == 'R':
		oper = cmdParseDict['mop'] << 5 | cmdParseDict['sop'] << 0
		rd   = int(cmdList[1].replace(',', '').replace('r', ''))
		rs1  = int(cmdList[2].replace(',', '').replace('r', ''))
		rs2  = int(cmdList[3].replace(',', '').replace('r', ''))
		sImm = int(cmdList[4].replace(',', '').replace('r', ''), 0)
		if sImm > 255 or sImm < -256:
			print ('Error format sImm, ', cmdList)
			sys.exit(1)
		assCode.append(oper << 24 | rd << 19 | rs1 << 14 | rs2 << 9 | (sImm & 0x1ff))
		cmdAddr = cmdAddr + 4
	if cmdParseDict['type'] == 'I':
		oper = cmdParseDict['mop'] << 5 | cmdParseDict['sop'] << 0
		rd   = int(cmdList[1].replace(',', '').replace('r', ''))
		if 'low' in cmdList[2] or 'high' in cmdList[2]:
			assCode.append(oper << 24 | rd << 19)
			cmdAddr = cmdAddr + 4
			symbol  = cmdList[2]
			symbolUnsolv.append({'idx':len(assCode)-1, 'name':symbol})
		else:
			uImm = int(cmdList[2], 0)
			assCode.append(oper << 24 | rd << 19 | uImm << 0)
			cmdAddr = cmdAddr + 4

for unSolv in symbolUnsolv:
	symbolName = unSolv['name'].replace('low(', '').replace('high(', '').replace(')', '')
	if symbolName not in cmdSymbol.keys():
		print ('Unsolved Symbol, ', unSolv['name'])
		sys.exit(1)
	else:
		if 'low' in unSolv['name']:
			assCode[unSolv['idx']] |= (cmdSymbol[symbolName] & 0xffff)
		else:
			assCode[unSolv['idx']] |= ((cmdSymbol[symbolName] >> 16) & 0xffff) 

ramFile = open('ram.mem', 'w')
for code in assCode:
	ramFile.write("%08x\n" %(code))
ramFile.close()
