Explain until in bash

```
wait_gpfs_fs() {
    until [ "$(stat -c%d $GPFS_FS_MOUNT)" != "$(stat -c%d /)" ]; do
        echo_log "Waiting for $GPFS_FS_MOUNT mount..."
        sleep 2
    done
}
```
