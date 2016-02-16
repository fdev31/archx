install_pkg redshift

# shift switch script
echo '
#!/bin/bash
EX=redshift
SFX="-gtk"
OK="0"
STATUS=`ps axuw |grep ${EX} |grep -v grep | wc -l`

if [ "x$1" == "xon" ]; then
    STATUS=${OK}
elif [ "x$1" == "xoff" ]; then
    STATUS="33"
fi

if [ $STATUS = ${OK} ]; then
       echo "Turning ${EX} ON"
       ${EX}${SFX} -l manual -l 43.3186:5.4084 -t 6500:3700 &
else
       echo "Turning ${EX} OFF"
       pkill ${EX} &
fi

exit 0
' | sudo dd "of=$R/bin/shift-swich"
sudo chmod 755 "$R/bin/shift-swich"

install_desktop redshift-gtk
