
clean:
	rm -rf ram.mem*
	rm -rf nnRv
	rm -rf test
	rm -rf test.vcd
	rm -rf nnRv.v

nnRv:
	python ram_init_proc.py

nnas:
	python nnasm.py

nexys-a7: nnas nnRv
	@echo 'all done! now you can start vivado'
