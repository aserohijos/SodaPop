#!/bin/bash

##### PARSE INPUT FROM C++ MAIN OR CMD LINE
OUT=$1
MAXGEN=$2
POPSIZE=$3
DT=$4
FORMAT=$5
GENE_COUNT=$6
##GENE_COUNT=1
LONG=0

##### CREATE DIRECTORIES FOR RESULTS
rm -rf out/$OUT/barcodes; mkdir out/$OUT/barcodes
rm -rf out/$OUT/graph; mkdir out/$OUT/graph
PREFIX=out/$OUT
HOME=../..

echo Begin analysis.

if [ "$FORMAT" -eq "$LONG" ]; then
	echo Using long format.
else
	echo Using short format.
fi

echo Gene count = $6.

echo Working in $PREFIX.

cd $PREFIX

echo Extracting barcodes from $PREFIX/snapshots/...

## CONVERT BINARY SNAPSHOTS TO TEXT FILES
FILES=snapshots/*.snap.gz
for filename in $FILES
do
	gunzip $filename
	y="$(basename $filename .gz)"
	./$HOME/sodasnap snapshots/$y snapshots/$y.txt $FORMAT
	rm snapshots/$y
	gzip -f snapshots/$y.txt
done

FACTOR=2
let "FACTOR += 2*$GENE_COUNT"

COL=3
let "COL += $FORMAT"

#### EXTRACT AND SORT BARCODES
rm -f avg_fitness.txt
FILES=snapshots/*.snap.txt.gz
for filename in $FILES
do
	y=${filename%%.txt.gz}
	gunzip -c $filename | awk 'NR>1 {print $0}' - | awk -v N=$FACTOR 'NR%N==2' - | cut -f1 | sort > barcodes/${y##*/}.barcodes
	#### SUM POPULATION FITNESS FOR EACH TIME POINT AND DIVIDE BY POP SIZE
	if [ "$FORMAT" -eq "$LONG" ]; then
		gunzip -c $filename | awk 'NR>1 {print $0}' - | awk -v N=$FACTOR 'NR%N==2' - | awk -v N=$3 -v C=$COL '{sum += $C} END {print sum/N}' - >> avg_fitness.txt
    else
		gunzip -c $filename | awk 'NR>1 {print $0}' - | awk -v N=$FACTOR 'NR%N==2' - | awk -v N=$3 -v C=$COL '{sum += $C} END {print sum/N}' - >> avg_fitness.txt
    fi
	
done

echo Parsing unique barcodes...

#### PARSE UNIQUE BARCODES
FILES=barcodes/*.barcodes
for filename in $FILES
do
	y=${filename%%.barcodes}
	uniq -c $filename | awk -F' ' '{t = $1; $1 = $2; $2 = t; print; }' > barcodes/${y##*/}.unique

	#### BREAK AT FIXATION POINT IF IT OCCURS
	if ! $(read -r && read -r)
	then
		#### OUTPUT FIXATION GENERATION TO FILE
	  	echo Fixation at ${y##*/} > fixation.txt
	  	echo Fixation at ${y##*/}
	  	break
	fi < barcodes/${y##*/}.unique
done

cat barcodes/$OUT.gen0000000001.snap.unique > barcodes/start.txt

echo Combining time series...

i=0
j=1

cat barcodes/start.txt > barcodes/series$i.txt

#### JOIN TIME FRAMES IN A SUITABLE FORMAT
for filename in `find barcodes/ -maxdepth 1 -name "*.unique"`
do
	join -t' ' -e 0 -a 1 -1 1 -2 1 -o 2.2 barcodes/series$i.txt $filename | paste -d' ' barcodes/series$i.txt - > barcodes/series$j.txt
	rm -f barcodes/series$i.txt
	((i++))
	((j++))
done

cat barcodes/series$i.txt | cut -d " " -f 1,3- > ALL_generations.txt

rm -f barcodes/series*.txt

rm -f snapshots/*.snap

cd $HOME

#### PLOT RESULTS IN R SCRIPTS
Rscript tools/polyclonal_structure.R /out/$OUT/ $DT

echo Done.