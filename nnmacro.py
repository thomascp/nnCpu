
import sys

def function_entry(code):
	global cur_lr
	global cur_bk_bp
	global cur_arg_0
	global cur_arg
	global cur_var
	global cur_function_name
	cur_function_name = code.split('@')[-1].split(':')[0]
	cur_arg = {}
	cur_var = {}
	ssCode.append(cur_function_name + ':')
	ssCode.append('add r29, r30, r0, 0') # bp = sp
	cur_lr = 'r29, r0, 0'
	cur_bk_bp = 'r29, r0, 4'
	cur_arg_0 = 'r29, r0, 4'

def arg_configure(code):
	global cur_arg_0
	args = code[3:].split(',')
	args_num = len(args)
	for i in range(args_num):
		args_location = 'r29, r0, ' + str((2 + args_num - i - 1) * 4)
		cur_arg[args[i].strip()] = args_location
		if i == 0:
			cur_arg_0 = args_location

def var_allocate(code):
	args = code[3:].split(',')
	args_num = len(args)
	for i in range(args_num):
		cur_var[args[i].strip()] = '_' + cur_function_name + '_' + args[i].strip()

def stack_operation(code):
	if code[0:3] == 'pop':
		if len(code.split()) == 1:
			ssCode.append('add r30, r30, r0, 4')
		else:
			param =  code.split()[-1]
			if param in cur_arg.keys():
				ssCode.append('ldr r1, r30, r0, 0')
				ssCode.append('str r1, ' + cur_arg[param])
				ssCode.append('add r30, r30, r0, 4')
			else: # cur_var
				ssCode.append('luil r1, low(' + cur_var[param] + ')')
				ssCode.append('luih r1, high(' + cur_var[param] + ')')
				ssCode.append('ldr r2, r30, r0, 0')
				ssCode.append('str r2, r1, r0, 0')
				ssCode.append('add r30, r30, r0, 4')
	else: # push
		param =  code.split()[-1]
		if param in cur_arg.keys():
			ssCode.append('ldr r1, ' + cur_arg[param])
			ssCode.append('sub r30, r30, r0, 4')
			ssCode.append('str r1, r30, r0, 0')			
		elif param in cur_var.keys(): # cur_var
			ssCode.append('luil r1, low(' + cur_var[param] + ')')
			ssCode.append('luih r1, high(' + cur_var[param] + ')')
			ssCode.append('ldr r2, r1, r0, 0')
			ssCode.append('sub r30, r30, r0, 4')
			ssCode.append('str r2, r30, r0, 0')
		else:
			ssCode.append('luil r1, ' + str(int(param, 0) & 0xffff))
			ssCode.append('luih r1, ' + str((int(param, 0) >> 16) & 0xffff))
			ssCode.append('sub r30, r30, r0, 4')
			ssCode.append('str r1, r30, r0, 0')

def alg_operation(code):
	if code == 'add' or code == 'sub' or code == 'and' or code == 'or':
		ssCode.append('ldr r1, r30, r0, 4')
		ssCode.append('ldr r2, r30, r0, 0')
		ssCode.append(code + ' r1, r1, r2, 0')
		ssCode.append('add r30, r30, r0, 4')
		ssCode.append('str r1, r30, r0, 0')
	elif code == 'not':
		ssCode.append('ldr r1, r30, r0, 0')
		ssCode.append('luil r2, 0xffff')
		ssCode.append('luih r2, 0xffff')
		ssCode.append('xor r1, r1, r2, 0')
		ssCode.append('str r1, r30, r0, 0')
	elif code == 'neg':
		ssCode.append('ldr r1, r30, r0, 0')
		ssCode.append('luil r2, 0xffff')
		ssCode.append('luih r2, 0xffff')
		ssCode.append('xor r1, r1, r2, 0')
		ssCode.append('add r1, r0, r0, 1')
		ssCode.append('str r1, r30, r0, 0')
	elif code == 'cmpeq' or code == 'cmpne' or code == 'cmpgt' or code == 'cmplt' or code == 'cmpge' or code == 'cmple':
		alg_dict = {	'cmpeq' : 'jne r31, r1, r2, 12',
				'cmpne' : 'jeq r31, r1, r2, 12',
				'cmpgt' : 'jge r31, r2, r1, 12',
				'cmplt' : 'jge r31, r1, r2, 12',
				'cmpge' : 'jlt r31, r1, r2, 12',
				'cmple' : 'jlt r31, r2, r1, 12'
				}
		ssCode.append('ldr r1, r30, r0, 4')
		ssCode.append('ldr r2, r30, r0, 0')
		ssCode.append('add r30, r30, r0, 4')
		ssCode.append('str r0, r30, r0, 0')
		ssCode.append(alg_dict[code])
		ssCode.append('add r1, r0, r0, 1')
		ssCode.append('str r1, r30, r0, 0')
	else:
		print ('unknown code ' + code)
	

def function_ret(code):
	ret_val = code.split()[-1]
	ssCode.append('add r1, r0, r0, 0')
	if len(code.split()) != 1:
		if ret_val == '~':
			ssCode.append('ldr r1, r30, r0, 0')
		elif ret_val in cur_arg.keys():
			ssCode.append('ldr r1, ' + cur_arg[ret_val])		
		elif ret_val in cur_var.keys(): # cur_var
			ssCode.append('luil r1, low(' + cur_var[ret_val] + ')')
			ssCode.append('luih r1, high(' + cur_var[ret_val] + ')')
			ssCode.append('ldr r1, r1, r0, 0')
		else:
			ssCode.append('luil r1, ' + str(int(ret_val, 0) & 0xffff))
			ssCode.append('luih r1, ' + str((int(ret_val, 0) >> 16) & 0xffff))
	ssCode.append('add r30, ' + cur_arg_0)
	ssCode.append('str r1, r30, r0, 0')
	ssCode.append('ldr r1, ' + cur_lr)
	ssCode.append('ldr r29, ' + cur_bk_bp)
	ssCode.append('jne r1, r31, r0, 0')

def function_exit(code):
	for var in cur_var.keys():
		ssCode.append(cur_var[var] + ':')
		ssCode.append('.data 0x0')

def jmp_operation(code):
	if code[0:3] == 'jmp':
		jmp_label = code.split()[-1]
		ssCode.append('luil r1, low(' + jmp_label + ')')
		ssCode.append('luih r1, high(' + jmp_label + ')')
		ssCode.append('jne r1, r31, r0, 0')
	elif code[0:2] == 'jz':
		jmp_label = code.split()[-1]
		ssCode.append('ldr r1, r30, r0, 0')
		ssCode.append('add r30, r30, r0, 4')
		ssCode.append('jne r31, r1, r0, 16') # jmp to the end
		ssCode.append('luil r1, low(' + jmp_label + ')')
		ssCode.append('luih r1, high(' + jmp_label + ')')
		ssCode.append('jne r1, r31, r0, 0')
	else:
		print ('unknown code ' + code)

def call_function(code):
	call_func = code[1:]
	ssCode.append('sub r30, r30, r0, 4')
	ssCode.append('str r29, r30, r0, 0')
	ssCode.append('sub r30, r30, r0, 4')
	ssCode.append('add r1, r31, r0, 20') # lr
	ssCode.append('str r1, r30, r0, 0')
	ssCode.append('luil r1, low(' + call_func + ')')
	ssCode.append('luih r1, high(' + call_func + ')')
	ssCode.append('jne r1, r31, r0, 0')

def pointer_operation(code):
	pointer_oper = code.split()[0]
	pointer_name = code.split()[1]
	if pointer_oper == 'str_pop':
		ssCode.append('ldr r1, r30, r0, 0')
		ssCode.append('add r30, r30, r0, 4')
		if pointer_name in cur_arg.keys():
			ssCode.append('ldr r2, ' + cur_arg[pointer_name])
			ssCode.append('str r1, r2, r0, 0')
		else: # var
			ssCode.append('luil r2, low(' + cur_var[pointer_name] + ')')
			ssCode.append('luih r2, high(' + cur_var[pointer_name] + ')')
			ssCode.append('ldr r2, r2, r0, 0')
			ssCode.append('str r1, r2, r0, 0')
	elif pointer_oper == 'ldr_push':
		if pointer_name in cur_arg.keys():
			ssCode.append('ldr r2, ' + cur_arg[pointer_name])
			ssCode.append('ldr r1, r2, r0, 0')
		else: # var
			ssCode.append('luil r2, low(' + cur_var[pointer_name] + ')')
			ssCode.append('luih r2, high(' + cur_var[pointer_name] + ')')
			ssCode.append('ldr r2, r2, r0, 0')
			ssCode.append('ldr r1, r2, r0, 0')
		ssCode.append('sub r30, r30, r0, 4')
		ssCode.append('str r1, r30, r0, 0')
	else:
		print ('unknown code ' + code)

cur_function_name = ''
cur_lr = ''
cur_bk_bp = ''
cur_arg_0 = ''
cur_arg = {}
cur_var = {}
ssCode = []
alg_num = 0

alg_oper = ['add', 'sub', 'cmpeq', 'cmpne', 'cmpgt', 'cmplt', 'cmpge', 'cmple', 'and', 'or', 'not', 'neg']
pointer_oper = ['str_pop', 'ldr_push']

siFile = open('nnas.s.i')
siLines = siFile.readlines()
siFile.close()

for code in siLines:
	code = code.strip()
	if len(code) == 0:
		continue
	if 'FUNC' in code and code[0] == 'F':
		function_entry(code)
	elif 'ENDFUNC' in code:
		function_exit(code)
	elif code[-1] == ':':
		ssCode.append(code)
	elif code[0:3] == 'var':
		var_allocate(code)
	elif code[0:3] == 'arg':
		arg_configure(code)
	elif code[0:4] == 'push' or code[0:3] == 'pop':
		stack_operation(code)
	elif code in alg_oper:
		alg_operation(code)
	elif code[0:2] == 'jz' or code[0:3] == 'jmp':
		jmp_operation(code)
	elif code[0:3] == 'ret':
		function_ret(code)
	elif code[0] == '$':
		call_function(code)
	elif code[0:7] in pointer_oper:
		pointer_operation(code)
	else:
		print ('unknown code ' + code)

ssFile = open('nnas.s', 'w')
for code in ssCode:
	if ':' in code:
		ssFile.write("%s\n" %(code))
	else:
		ssFile.write("\t%s\n" %(code))
ssFile.close()

