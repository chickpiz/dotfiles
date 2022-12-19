#!/usr/bin/bash

DST=$1
SRC=$2

SYNC_DELAY=3
SYNC_INTERVAL=3600

LOG=/tmp/rclone-sync.log

function rclone_sync {
    rclone sync $DST $SRC

    # It only syncs the changed file
    set -x

    while : 
    do
        MOVING=false

        inotifywait -m -r -q --timeout $SYNC_INTERVAL -e create,modify,delete,move --format '%e %w%f' $SRC | while read OUT;
    do
        # Something changed

        sleep $SYNC_DELAY

        ARR=($OUT)

        OP=${ARR[0]}
        FILE=${ARR[1]//$SRC\//}
        PARENT=$(dirname $FILE)
        if [ $PARENT = "." ]; then
            PARENT=""
        fi

        if [ $OP = "CREATE" ]; then
            rclone copy $SRC/$FILE $DST/$PARENT
        elif [ $OP = "MODIFY" ]; then
            rclone copy $SRC/$FILE $DST/$PARENT
        elif [ $OP = "DELETE" ]; then
            rclone delete $DST/$FILE
        elif [ $OP = "MOVED_FROM" ]; then
            rclone delete $DST/$FILE
        elif [ $OP = "MOVED_TO" ]; then
            rclone copy $SRC/$FILE $DST/$PARENT
        elif [ $OP = "CREATE,ISDIR" ]; then
            rclone copy $SRC/$FILE $DST/$FILE
        elif [ $OP = "DELETE,ISDIR" ]; then
            rclone purge $DST/$FILE
        elif [ $OP = "MOVED_FROM,ISDIR" ]; then
            MOVING=true
            OLDFILE=$FILE
        elif [ $OP = "MOVED_TO,ISDIR" ]; then
            if ! $MOVING; then
                notify-send "[error] MOVING not set"
                echo "[error] MOVING not set" >> $LOG
            else
                MOVING=false
                rclone moveto $DST/$OLDFILE $DST/$FILE
            fi
        fi

        notify-send "synchronized $OP $FILE"
        echo "$OP $FILE" >> $LOG
    done

    # Timeout, sync!
    rclone sync $DST/ $SRC/
    echo "synchronized entire directory" >> $LOG

    done
}

rclone_sync
