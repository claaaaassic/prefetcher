CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

GIT_HOOKS := .git/hooks/applied

all: $(GIT_HOOKS) $(EXEC) $(astyle)

EXEC = naive_transpose sse_transpose sse_prefetch_transpose

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

naive_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DNAIVE -o $@ $(SRCS_common)

sse_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DSSE -o $@ $(SRCS_common)

sse_prefetch_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DSSE_PREFETCH -o $@ $(SRCS_common)

# r014c : LOAD_HIT_PRE.SW_PF
# r024c : LOAD_HIT_PRE.HW_PF
# r01d1 : MEM_LOAD_UOPS_RETIRED.L1_HIT
# r02d1 : MEM_LOAD_UOPS_RETIRED.L2_HIT
cache-test: $(EXEC)
	for method in $(EXEC);do \
	perf stat --repeat 10 \
		-e cache-misses,cache-references,instructions,cycles\
		-e L1-icache-load-misses,L1-dcache-load-misses,r014c,r024c,r01d1,r02d1\
		./$$method;\
	done

clean:
	$(RM) $(EXEC)
