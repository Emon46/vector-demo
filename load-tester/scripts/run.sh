#!/bin/bash
 x=1
 rg=${MAX_RANGE:-10}
 while [ $x -le $rg ]
 do
   echo "level = error, find me and fix me $x"
   echo "level = info, wow! i have been executed successful $x"
   echo "level = debug, i am debugger for developer $x"
   echo "level = no_tag, i am invisible $x"
   x=$(( $x + 1 ))
   sleep 0.0020
 done