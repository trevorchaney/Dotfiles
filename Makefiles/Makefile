##
# @file Makefile
# @author Trevor Chaney (tlc) (trevorchaney@gmail.com)
# @date
# @brief

.SILENT: clean
.PHONY: all clean

## Make flags
# MAKEFLAGS := --jobs=$(shell nproc) --output-sync=target --load-average

## Run 'make -p -f /dev/null' to get the implicit rules and variables that make is using.

## Default CXX is g++
# CXX = clang
CXXSPEC = c++03
SHELL = bash

## Use '-m32' to build 32-bit binaries.
CXXFLAGS = -Wall -Wextra -Wshadow -Wsign-conversion -pipe -std=$(CXXSPEC) #-m32
CFLAGS = $(CXXFLAGS)
LDFLAGS =
LDLIBS = -lstdc++
OPTIMIZATION = -O2 -march=native -mtune=native -flto -fuse-linker-plugin -fdata-sections -ffunction-sections -Wl,--gc-sections
# SUPER_OPTIMIZE_GCC = -O3 -mavx2 -funsafe-math-optimization
# SUPER_OPTIMIZE_CLANG = -O3 -march=core-avx2 -m64 -cl-fast-relaxed-math
# SUPER_OPTIMIZE_INTEL = -Ofast -march=core-avx2 -m64
# SUPER_OPTIMIZE_MSVC = -O3 /arch:AVX2 /Ox /fp:fast

SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
EXCLUDES =

DEBUG = yes
DEBUGVERBOSE = no
PEDANTIC = yes
PROFILE = yes
PROFILE_GUIDED_OPTIMIZATION = yes
SUPER_OPTIMIZATION

ifeq ($(DEBUG), yes)
ifeq ($(DEBUGVERBOSE), yes)
	CXXFLAGS += -DDEBUGLOGGING
endif
	CXXFLAGS += -ggdb3
	OPTIMIZATION = -O0
endif

ifeq ($(PEDANTIC), yes)
	CXXFLAGS += -Wpedantic
endif

ifeq ($(PROFILE), yes)
ifeq ($(PROFILE_GUIDED_OPTIMIZATION), yes)
ifneq ($(wildcard *.gcda), )
	CXXFLAGS += -fprofile-use
else
	CXXFLAGS += -fprofile-generate
endif
endif
## Use '-p' for prof and '-pg' for gprof
	CXXFLAGS += -pg
endif

CXXFLAGS += $(OPTIMIZATION)


#==============================================================================
# ░▀█▀░█▀█░█▀▄░█▀▀░█▀▀░▀█▀░█▀▀
# ░░█░░█▀█░█▀▄░█░█░█▀▀░░█░░▀▀█
# ░░▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀
#==============================================================================

all: project
	@echo MAKEFLAGS: $(MAKEFLAGS)

project: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

shared: $(OBJECTS)
	$(CXX) $(OBJECTS) $(CXXFLAGS) $(LDLIBS) -shared -o libshared_lib_out.so

dox: project
	doxygen .

profile: project
	./a.out
	gprof a.out gmon.out > gprof_profile.out
	prof record ./a.out

mem_analysis: project
	valgrind --leak-check=full --show-reachable=yes --num-callers=20 --track-fds=yes --track-origins=yes -s --log-file="valgrind_analysis.out" ./a.out

static_analysis: project
	cppcheck --enable=all -i $(EXCLUDES) -j $(shell nproc) --std=$(CXXSPEC)

reports: profile static_analysis mem_analysis

clean:
	rm -rf *.out *.gcda *.xml $(OBJECTS) logs dox *.so *.gch core.* obj-lin-*

rebuild: clean all
