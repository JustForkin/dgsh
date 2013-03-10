#
#  Copyright 2012-2013 Diomidis Spinellis
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

ifdef DEBUG
CFLAGS=-g -DDEBUG -Wall
else
CFLAGS=-O -Wall
endif

EXECUTABLES=sgsh sgsh-tee sgsh-writeval sgsh-readval

%.png: %.sh
	./sgsh -g $< | dot -Tpng >$@

all: $(EXECUTABLES)

test-sgsh: sgsh sgsh-writeval sgsh-readval
	./sgsh -p . example/code-metrics.sh test/code-metrics/in/ >test/code-metrics/out.test
	diff -b test/code-metrics/out.ok test/code-metrics/out.test
	./sgsh -p . example/duplicate-files.sh test/duplicate-files/ >test/duplicate-files/out.test
	diff test/duplicate-files/out.ok test/duplicate-files/out.test
	./sgsh -p . example/word-properties.sh file://`pwd`/test/word-properties/LostWorldChap1-3 >test/word-properties/out.test
	diff -b test/word-properties/out.ok test/word-properties/out.test

test-tee: sgsh-tee charcount test-tee.sh
	./test-tee.sh

test-kvstore: test-kvstore.sh
	# Make versions that will exercise the buffers
	$(MAKE) clean
	$(MAKE) DEBUG=1
	./test-kvstore.sh
	# Remove the debug build versions {{{1
	$(MAKE) clean

sgsh: sgsh.pl
	perl -c sgsh.pl
	install sgsh.pl sgsh

charcount: charcount.sh
	install charcount.sh charcount

png: sgsh
	for i in example/*.sh ; do \
		./sgsh -g $$i | dot -Tpng >`basename $$i .sh`.png ; \
	done

# Regression test based on generated output files
test-regression:
	# Sort files by size to get the easiest problems first
	# Generated dot graphs
	for i in `ls -rS example/*.sh` ; do \
		perl sgsh.pl -g $$i >test/regression/graphs/`basename $$i .sh`.test ; \
		diff -b test/regression/graphs/`basename $$i .sh`.* || exit 1 ; \
	done
	# Generated code
	for i in `ls -rS example/*.sh` ; do \
		perl sgsh.pl -o - $$i >test/regression/scripts/`basename $$i .sh`.test ; \
		diff -b test/regression/scripts/`basename $$i .sh`.* || exit 1 ; \
	done

# Seed the regression test data
regression-seed:
	for i in example/*.sh ; do \
		perl sgsh.pl -o - $$i >test/regression/scripts/`basename $$i .sh`.ok ; \
		perl sgsh.pl -g $$i >test/regression/graphs/`basename $$i .sh`.ok ; \
	done

clean:
	rm -f *.o *.exe $(EXECUTABLES)
