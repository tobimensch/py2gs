#!/bin/bash
# * Licensed under terms of MIT license (see LICENSE-MIT)
# * Copyright (c) 2014 Tobias Glaesser
#
#converts python source file into
#      to genie  source file
#-
#don't expect this to be perfect from
#bash script, this is just a rough
#transformation to save some typing
#---
#if any transformation is wrong
#or unwanted just change it or comment it out

COMPILE="false"
if [ "$1" == "c" ]
then
    COMPILE="true"
    FILE=$2
else
    FILE=$1
fi

rm -f $FILE.tmp
cat $FILE >> $FILE.tmp

function _sed
{
	cat $FILE.tmp | sed "$@" > $FILE.tmp2
	mv $FILE.tmp2 $FILE.tmp
}

function _perl
{
	cat $FILE.tmp | perl "$@" > $FILE.tmp2
	mv $FILE.tmp2 $FILE.tmp
}

#removes import statement
_sed '/import\s.*/d'

#removes from statement
_sed '/from\s.*/d'

#change class Window(Base):
#into   class Window : Base
_sed 's/\(.*class [^(]*\)(\([^)]*\).*/\1 : \2/'

#change __init(self):
#into init
_sed 's/\(.*\)def __init__(self):/\1init/'
_sed 's/\(.*\)def __init__(self, parent):/\1init/'
_sed 's/\(.*\)def __init__(self, \*\*kwargs):/\1init/'
 
#removes self, from def func(self,)...
_sed 's/\(.*def.*(\)self,\s*\(.*\)/\1\2/'

#removes self. calls
_sed 's/\(.*\s\)self\.\(.*\)/\1\2/'
_sed 's/\(.*(\)self\.\(.*\)/\1\2/'
_sed 's/\(.*,\)self\.\(.*\)/\1\2/'

#replace # comments with // comments
_sed 's/\([\s]*\)#\(.*\)/\1\/\/\2/'

#remove : behind functions/methods
_sed 's/\(def.*\):/\1/'

#remove : behind if
_sed 's/\(if\s.*\):/\1/'

#remove : behind else
_sed 's/\(else\s.*\):/\1/'
_sed 's/\(else\):/\1/'

#remove : behind try/except
_sed 's/\(try\):/\1/'
_sed 's/\(except\):/\1/'

#remove : behind for loops
_sed 's/\(for\s.*\):/\1/'

#remove : behind while loops
_sed 's/\(while\s.*\):/\1/'

#convert ''' ''' literals into multiline """ """ literals
#if preceded by operator
_perl -0777 -pe "s/(=)([^\n]*)(''')(.*?)(''')/\1\2\"\"\"\4\"\"\"/sg"

#convert ''' ''' literals into /* */ comments
#this assumes that comments is the most common
#use case for '''... result needs to be fixed
#for actual literals
_perl -0777 -pe "s/(''')(.*?)(''')/\/\*\2\*\//sg"

#_sed "s/\('''\)\(.*\)\('''\)/\\\*\2\*\//g"
#_sed "s/\('''\)\(.*\)\('''\)/test/g"

#convert 'literal' to "literal"
#summary: very greedy
#_sed 's/\(.*\)\x27\(.*\)\x27\(.*\)/\1"\2"\3/g'
_perl -pe 's/\x27(.*?)\x27/"\1"/g'

#add var token before all assignment statements
#that's by far too greedy, but most assignments tend
#to happen in declarations ... disable this if this
#is wrong... needs manual fixing in any case
#summary: very greedy
_sed 's/^\(\s*\)\([[:alnum:]|_]*\)\s*=\s*/\1var \2 = new /'


#convert python style False True to
#        c      style false true
#summary: very greedy
_sed 's/False/false/g'
_sed 's/True/true/g'

#change all function/method parameters to have
#static typing syntax...
#defaulting everything to string
#obviously there's manual fixing needed
_sed 's/\(.*\sdef\s.*(\)\([[:alnum:]]\+\)\(,.*\)/\1\2 : string \3/'

#add [indent=4] at beginning of file
sed -i '1s/^/\[indent=4\]\n/' $FILE.tmp

#remove double newlines
sed -i 'N;/^\n$/d;P;D' $FILE.tmp

cat $FILE.tmp

if [ "$COMPILE" == "true" ]
then
    cp $FILE.tmp $FILE.tmp.gs
    valac --pkg gtk+-3.0 $FILE.tmp.gs
    rm -f $FILE.tmp.gs  
fi

rm -f $FILE.tmp


