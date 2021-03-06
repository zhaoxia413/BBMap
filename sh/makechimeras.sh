#!/bin/bash
#makechimeras in=<infile> out=<outfile>

usage(){
echo "
Written by Brian Bushnell
Last modified February 17, 2015

Description:  Makes chimeric sequences from nonchimeric sequences.
Designed for PacBio reads.

Usage:        makechimeras.sh in=<input> out=<output> chimeras=<integer>


Input Parameters:
in=<file>       The input file containing nonchimeric reads.
unpigz=t        Decompress with pigz for faster decompression.

Output Parameters:
out=<file>      Fasta output destination.
chimeras=-1     Number of chimeras to create (required parameter).
forcelength=0   If a positive number X, one parent will be length X, and the other will be length-X.

Java Parameters:
-Xmx            This will be passed to Java to set memory usage, overriding the program's automatic memory detection.
                -Xmx20g will specify 20 gigs of RAM, and -Xmx200m will specify 200 megs.  The max is typically 85% of physical memory.

Please contact Brian Bushnell at bbushnell@lbl.gov if you encounter any problems.
"
}

pushd . > /dev/null
DIR="${BASH_SOURCE[0]}"
while [ -h "$DIR" ]; do
  cd "$(dirname "$DIR")"
  DIR="$(readlink "$(basename "$DIR")")"
done
cd "$(dirname "$DIR")"
DIR="$(pwd)/"
popd > /dev/null

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CP="$DIR""current/"

z="-Xmx1g"
z2="-Xms1g"
EA="-ea"
set=0

if [ -z "$1" ] || [[ $1 == -h ]] || [[ $1 == --help ]]; then
	usage
	exit
fi

calcXmx () {
	source "$DIR""/calcmem.sh"
	parseXmx "$@"
	if [[ $set == 1 ]]; then
	return
	fi
	freeRam 800m 82
	z="-Xmx${RAM}m"
	z2="-Xms${RAM}m"
}
calcXmx "$@"

makechimeras() {
	if [[ $NERSC_HOST == genepool ]]; then
		module unload oracle-jdk
		module load oracle-jdk/1.7_64bit
		module load pigz
	fi
	local CMD="java $EA $z -cp $CP jgi.MakeChimeras $@"
	echo $CMD >&2
	eval $CMD
}

makechimeras "$@"
