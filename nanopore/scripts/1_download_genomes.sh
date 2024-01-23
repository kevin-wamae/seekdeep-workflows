#!/bin/bash

# download reference genome files
# source: https://seekdeep.brown.edu/usages/genTargetInfoFromGenomes_usage.html

# get working directory
wd=$(pwd)

# download to genomes archive and save in p.falciparum.tar.gz
wget http://seekdeep.brown.edu/data/plasmodiumData/pf.tar.gz \
	-P $wd/input/genomes \
	-O $wd/input/genomes/pfalciparum.tar.gz

# extract contents of pf.tar.gz to input/genomes directory and remove the first directory in the path
tar -zxvf $wd/input/genomes/pfalciparum.tar.gz \
	-C $wd/input/genomes \
	--strip-components=1
