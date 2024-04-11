#!/bin/bash

# download p. falciparu reference genome files
# NB: ensure to run it while in the seekdeep-workflows/resources directory
# --------------------------------------------------
# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/resources$ ]]; then
	echo "Please run this script from this directory: seekdeep-workflows/resources/"
	exit 1
fi

# --------------------------------------------------
# source: https://seekdeep.brown.edu/usages/genTargetInfoFromGenomes_usage.html

# download to genomes archive and save in p.falciparum.tar.gz
# --------------------------------------------------
wget http://seekdeep.brown.edu/data/plasmodiumData/pf.tar.gz \
	-O pfalciparum.tar.gz

# extract contents of pf.tar.gz to input/genomes directory and remove the first directory in the path
# --------------------------------------------------
tar -zxvf pfalciparum.tar.gz \
	--strip-components=1
