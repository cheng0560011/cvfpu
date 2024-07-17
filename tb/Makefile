
# Makefile to build a testbench and DUT

export VERDI_HOME=/home/yutung/.toolsmgr/verdi
export LD_LIBRARY_PATH:=${LD_LIBRARY_PATH}:${VERDI_HOME}/share/PLI/VCS/LINUX64:${VERDI_HOME}/share/PLI/lib/LINUX64
$(info set Environment done)

DEBUG ?= 0
VCS = vcs -sverilog -timescale=1ns/1ns -l build.log -debug_access+all -assert svaext
SIMV = ./simv -l run.log

all: compile run verify

compile:
	$(VCS) -top cvfpu_tb -f flist

run:
	rm -f ./output.txt
	$(SIMV) +DEBUG=$(DEBUG)

verify:
	$(info Verify operation results)
	(cmp output.txt golden.txt) && echo "PASS" || echo "FAIL"

waveform:
	verdi -f file.f -ssf top.fsdb &

clean:
	rm -rf core csrc simv* vc_hdrs.h ucli.key urg* *.log *.fsdb novas.* verdiLog output.txt
