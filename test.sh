
#!/bin/bash
x=1
while [ $x -le 5 ]
do
  echo "level = error, find me and fix me $x"
  echo "level = info, wow! i have been executed successful $x"
  echo "level = debug, i am a helper for developer $x"
  echo "level = no_tag, i am a invisible $x"
  x=$(( $x + 1 ))
done

