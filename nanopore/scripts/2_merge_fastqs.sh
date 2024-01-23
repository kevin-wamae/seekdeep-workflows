#!/bin/bash

# download reference genome files
# source: https://seekdeep.brown.edu/usages/genTargetInfoFromGenomes_usage.html

# get working directory
wd=$(pwd)

# genome archive
gz=http://seekdeep.brown.edu/data/plasmodiumData/pf.tar.gz
# use wget to download http://seekdeep.brown.edu/data/plasmodiumData/pf.tar.gz to genomes directory
wget -P $wd/genomes

tar -zxvf pf.tar.gz
wget http://seekdeep.brown.edu/data/SeekDeepTutorialData/ver2_6_0/CamThaiGhanaDRC_2011_2013_drugRes/ids.tab.txt
SeekDeep genTargetInfoFromGenomes --gffDir pf/info/gff --genomeDir pf/genomes/ --primers ids.tab.txt --numThreads 7 --pairedEndLength 250 --dout extractedRefSeqs
