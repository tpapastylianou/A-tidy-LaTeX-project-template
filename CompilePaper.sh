#!/bin/bash

########################### --- CompilePaper.sh --- ###########################
#
# This script performs all the necessary steps required to compile the
# manuscript (i.e. running pdflatex and bibtex in the order required to generate
# a validly referenced manuscript) and then cleans up any unnecessary files
# created by tex. It is intended to be used from within texworks, but should
# also work as a standalone script; in the latter case, make sure it is run in
# the same folder as the 'main.tex' file.
#
# To run from a terminal, use the following syntax:
#
#     ./CompilePaper.sh -synctex=1 main.tex main
#
#
# To set this script up as a 'compilation processor' for use within texworks,
# add it as an entry under Preferences -> Typesetting -> Processing tools, then
# 'Edit' this entry and set the following strings as its arguments, in this
# order:
#  1. $synctexoption
#  2. $fullname
#  3. $basename
#
# Make sure the absolute path is used to refer to the script within texworks.
#
# Note: this script makes use of the 'play' command from the 'sox' package, to
# play appropriate 'bell' sounds indicating successful compilation or failure.
# If you don't have sox already installed, please install it in your system
# first. Alternatively, if you prefer to not have sounds, comment out the
# relevant lines making use of the 'play' command below.
#
# Note: The end of the script defines a 'cleanup phase', consisting of a list of
# files to remove following a successful compilation attempt. Edit as
# appropriate to keep files you want / remove files you don't want.
#
################################################################################


### -------------------------------------------------------------------------------------------------
### Print usage options if called with --help or compile using default options if no input parameters
### -------------------------------------------------------------------------------------------------

if test "${#@}" -eq 0   # if number of positional parameters given is equal to 0
then
    echo "Running with default arguments:"
    set -- '-synctex=1' 'main.tex' 'main'
    echo "  $1"
    echo "  $2"
    echo "  $3"
elif test "$1" = "--help" || test "$1" = "-h" || test "$1" = "-help"
then
    echo "Syntax:"
    echo "   ./CompilePaper.sh -synctex=1 main.tex main"
    echo
    echo "(see inside script for details)"
    exit 1
fi


### --------------------------------------------------------------------------------
### Compile with error checking and appropriate sound notifications in case of error
### --------------------------------------------------------------------------------

## First pass
echo
echo "-----------------------------"
echo "Starting First pdflatex pass."
echo "-----------------------------"
echo

pdflatex -halt-on-error -interaction=errorstopmode -file-line-error $1 $2
if test $? -ne 0   # if the above command did not complete successfully
then
    echo "First pass failed"
    play -qV0 "./dependencies/sounds/error.oga"
    exit 1
else
    echo
    echo "----------------------------------"
    echo "First pass completed successfully!"
    echo "----------------------------------"
    echo
fi


## Create bibliography files
echo
echo "---------------"
echo "Running bibtex."
echo "---------------"
echo

bibtex $3

## Catch missing citations as errors and stop execution
MISSINGCITATIONS="$(grep "Warning--I didn't find a database entry for \".*\"" ${3}.blg)"
if test -n "$MISSINGCITATIONS"   # if $MISSINGCITATIONS is not an empty string
  then
    echo -e "\n***" ERROR -- Missing citation $(grep "Warning--I didn't find a database entry for \".*\"" main.blg | grep -o \".*\") 1>&2
    play -qV0 "./dependencies/sounds/error.oga"
    exit 1
else
    echo
    echo "----------------------------------"
    echo "Bibtex completed successfully!"
    echo "----------------------------------"
    echo
fi


## Second pass, if no errors encountered previously - required by bibtex for some bizzare reason
echo
echo "------------------------------"
echo "Starting Second pdflatex pass."
echo "------------------------------"
echo

pdflatex -halt-on-error -interaction=nonstopmode -file-line-error $1 $2
if test $? -ne 0   # if the above command did not complete successfully
then
    echo "Second pass failed"
    play -qV0 "./dependencies/sounds/error.oga"
    exit 1
else
    echo
    echo "-----------------------------------"
    echo "Second pass completed successfully!"
    echo "-----------------------------------"
    echo
fi


## Third pass, if no errors encountered previously - required by bibtex for some even MORE bizzare reason
echo
echo "------------------------------"
echo "Starting Third pdflatex pass."
echo "------------------------------"
echo

# The following line is purely for the sake of texworks: texworks parses the output of pdflatex to detect lines
# containing 'warnings', and creates a convenient 'Errors and Warnings' tab. Unfortunately, the first and second passes
# will generate a lot of irrelevant warnings relating to not finding references, since these do not get linked with
# bibtex until the third pass. Since warnings are generated on the 'Errors and Warnings' tab in the order they are
# processed, this warning can serve as a visual marker, to clearly distinguish any warnings generated in the third pass.
# This is useful because these warnings are more likely to relate to genuine problems that need to be addressed.
echo "LaTeX Warning: === THIRD PASS STARTS HERE ===."

# Continue with processing third pass
pdflatex -halt-on-error -interaction=nonstopmode -file-line-error $1 $2
if test $? -ne 0    # if the above command did not complete successfully
then
    echo "Third pass failed"
    play -qV0 "./dependencies/sounds/error.oga"
    exit 1
else
    echo
    echo
    echo "-----------------------------------"
    echo "Third pass completed successfully!"
    echo "-----------------------------------"
    echo
fi


## Cleanup -- edit as appropriate
rm -f main.aux
rm -f main.log
rm -f main.out
rm -f resources/bibliography/ExampleBibliography.bib.bak
rm -f main.bbl
rm -f main.blg
#rm -f main.pdf
#rm -f main.synctex.gz


## If no error, notify that compilation is complete
play -qV0 "./dependencies/sounds/complete.oga"
