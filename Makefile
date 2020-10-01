TESTS = test_common

TEST_DATA = s Tai

CFLAGS = -O0 -Wall -Werror -g

# Control the build verbosity
ifeq ("$(VERBOSE)","1")
    Q :=
    VECHO = @true
else
    Q := @
    VECHO = @printf
endif

GIT_HOOKS := .git/hooks/applied

.PHONY: all clean out_dir

all: $(GIT_HOOKS) $(TESTS)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

OBJS_LIB = \
    tst.o bloom.o

OBJS := \
    $(OBJS_LIB) \
    test_common.o \

deps := $(OBJS:%.o=.%.o.d)


out_dir:
	mkdir -p measurement img inputs

test_%: test_%.o $(OBJS_LIB)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) $(LDFLAGS)  -o $@ $^ -lm

%.o: %.c
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF .$@.d $<


test:  $(TESTS)
	echo 3 | sudo tee /proc/sys/vm/drop_caches;
	sudo perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./test_common --bench CPY $(TEST_DATA)
	sudo perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
	        ./test_common --bench REF $(TEST_DATA)

bench: $(TESTS)
	@echo "COPY mechanism"
	@for test in $(TESTS); do \
	    echo -n "$$test => "; \
	    ./$$test --bench CPY $(TEST_DATA) | grep "searched prefix "; \
	done
	@echo "REFERENCE mechanism"
	@for test in $(TESTS); do \
	    echo -n "$$test => "; \
	    ./$$test --bench REF $(TEST_DATA) | grep "searched prefix "; \
	done

plot: $(TESTS)
	echo 3 | sudo tee /proc/sys/vm/drop_caches;
	sudo perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./test_common --bench CPY $(TEST_DATA) \
		| grep 'ternary_tree, loaded 206849 words'\
		| grep -Eo '[0-9]+\.[0-9]+' > cpy_data.csv
	sudo perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
				./test_common --bench REF $(TEST_DATA)\
		| grep 'ternary_tree, loaded 206849 words'\
		| grep -Eo '[0-9]+\.[0-9]+' > ref_data.csv

clean:
	$(RM) $(TESTS) $(OBJS)
	$(RM) $(deps)
	$(RM) bench_cpy.txt bench_ref.txt ref.txt cpy.txt
	$(RM) *.csv

cities_split_uniq.txt: cities.txt
	cat cities.txt | tr ',' '\n' | awk '{$$1=$$1};1' | awk '!seen[$$0]++' > cities_split_uniq.txt


img/l-full.png: out_dir test_all cities_split_uniq.txt
	match=full . data_scripts/l-data.sh
	match=full gnuplot data_scripts/l.gp


img/l-almost.png: out_dir test_all cities_split_uniq.txt
	match=almost . data_scripts/l-data.sh
	match=almost gnuplot data_scripts/l.gp

	
img/l-none.png: out_dir test_all cities_split_uniq.txt
	match=none . data_scripts/l-data.sh
	match=none gnuplot data_scripts/l.gp

img/n-full.png: out_dir test_all cities_split_uniq.txt
	export match=full; ./data_scripts/n-data.sh
	match=full gnuplot data_scripts/n.gp

img/n-almost.png: out_dir test_all cities_split_uniq.txt
	export match=almost; ./data_scripts/n-data.sh
	match=almost gnuplot data_scripts/n.gp
	
img/n-none.png: out_dir test_all cities_split_uniq.txt
	export match=none; ./data_scripts/n-data.sh
	match=none gnuplot data_scripts/n.gp


-include $(deps)
