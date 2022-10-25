
```
echo '''#!/bin/bash
 x=1
 touch /tmp/demo.log
 while [ $x -le 5 ]
 do
   echo "level = error, find me and fix me $x" >> /tmp/demo.log
   echo "level = info, wow! i have been executed successful $x" >> /tmp/demo.log
   echo "level = debug, i am a helper for developer $x" >> /tmp/demo.log
   echo "level = no_tag, i am a invisible $x" >> /tmp/demo.log
   x=$(( $x + 1 ))
 done
 ''' > /tmp/input.sh
```


```
chmod +x /tmp/input.sh
```