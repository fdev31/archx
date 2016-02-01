source ./strapfuncs.sh
install_pkg slock

# comp switch script
echo '
#!/bin/bash
BACKEND=xrender

PROG=compton
STATUS=`ps nc -C $PROG | wc -l`
BENCH=""
TIME=""

if [ "x$1" == "xon" ]; then
    STATUS="1"
elif [ "x$1" == "xtest" ]; then
    STATUS="1"
    BENCH="--benchmark 400"
    TIME="time"
elif [ "x$1" == "xoff" ]; then
    STATUS="0"
elif [ -n "$1" ]; then
    echo "Options:"
    echo "on: enable composition"
    echo "off: disable composition"
    echo "test: run benchmark"
    exit 1
fi

# unredir may cause flicker, optimize fullscreen displays

if [ $STATUS = "1" ]; then
       echo "Turning xcompmgr ON"
       pkill $PROG
       $TIME $PROG $BENCH --config ~/.config/awesome/compton.cfg $OPTIONS &
       PID=$!
       if [ -n "$TIME" ] ; then
           wait $PID
       fi
else
       echo "Turning xcompmgr OFF"
       pkill $PROG &
fi

exit 0
' | sudo dd "of=$R/bin/comp-swich"
sudo chmod 755 "$R/bin/comp-swich"


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

