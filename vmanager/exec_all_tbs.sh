xrun -sv testbench_illegal.sv csr_if.sv csr_pkg.sv generic_csr.sv -coverage all -covtest t_illegal -covoverwrite -write_metrics
xrun -sv testbench_valid.sv csr_if.sv csr_pkg.sv generic_csr.sv -coverage all -covtest t_valid -covoverwrite -write_metrics
xrun -sv testbench_random_addr.sv csr_if.sv csr_pkg.sv generic_csr.sv -coverage all -covtest t_random -covoverwrite -write_metrics
