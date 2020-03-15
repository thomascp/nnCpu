
clean:
	rm -rf ram.mem*
	rm -rf nnRv nnRv.v
	rm -rf test tcc
	rm -rf test.vcd
	rm -rf lex.yy.o lex.yy.c
	rm -rf y.tab.o y.tab.c y.tab.h y.output
	rm -rf nnas.s.i
	rm -rf nnas.s

nnRv:
	python ram_init_proc.py

nnRv_sim:
	iverilog -o nnRv nnRv.v sim.v

nnas: parser.y scanner.l
	bison -vdty parser.y
	flex scanner.l
	gcc -c -o lex.yy.o lex.yy.c
	gcc -c -o y.tab.o y.tab.c
	gcc -o tcc lex.yy.o y.tab.o
	./tcc < nexys-a7.c > nnas.s.i
	python nnmacro.py
	python nnasm.py

nnas-vga: parser.y scanner.l
	bison -vdty parser.y
	flex scanner.l
	gcc -c -o lex.yy.o lex.yy.c
	gcc -c -o y.tab.o y.tab.c
	gcc -o tcc lex.yy.o y.tab.o
	./tcc < nexys-a7-vga.c > nnas.s.i
	python nnmacro.py
	python nnasm.py

nexys-a7-vga: nnas-vga nnRv
	@echo 'all done! now you can start vivado'

nexys-a7: nnas nnRv
	@echo 'all done! now you can start vivado'

sim: nnas nnRv nnRv_sim
	vvp nnRv
	gtkwave test.vcd &
