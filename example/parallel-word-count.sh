#!/usr/bin/env dgsh
#
# SYNOPSIS Parallel word count
# DESCRIPTION
# Count number of times each word appears in the specified input file(s)
# Demonstrates parallel execution mirroring the Hadoop WordCount example
# via the dgsh-parallel command.
#
#  Copyright 2014-2016 Diomidis Spinellis
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

# Number of processes
N=8

# Collation order for sorting
export LC_ALL=C

# Scatter input
dgsh-tee -s |
# Emulate Java's default StringTokenizer, sort, count
dgsh-parallel -n $N "tr -s ' \t\n\r\f' '\n' | sort -S 512M | uniq -c" |
# Merge sorted counts by providing N input channels
dgsh-merge-sum $(for i in $(seq $N) ; do printf '<| ' ; done)
