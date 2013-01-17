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

all: sgsh teebuff

test: sgsh teebuff
	./sgsh -t ./teebuff example/code-metrics.sh test/code-metrics/in/ >test/code-metrics/out.test
	diff -b test/code-metrics/out.ok test/code-metrics/out.test
	./sgsh -t ./teebuff example/duplicate-files.sh test/duplicate-files/ >test/duplicate-files/out.test
	diff test/duplicate-files/out.ok test/duplicate-files/out.test

test-teebuff: teebuff
	./teebuff -b 64 <teebuff.c a b
	diff teebuff.c a
	diff teebuff.c b
	rm a b


sgsh: sgsh.pl
	perl -c sgsh.pl
	install sgsh.pl sgsh
