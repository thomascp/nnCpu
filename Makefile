
clean:
	rm -rf ram.mem*
	rm -rf nnRv
	rm -rf test
	rm -rf test.vcd

nnRv_sim:
	iverilog -o nnRv nnRv.v test.v

nnas:
	python nnasm.py

sim: nnas nnRv_sim
	vvp nnRv
	gtkwave test.vcd &
