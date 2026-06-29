`ps` and other system tools rely on `cmdline` to work.

Find processes in `D` state or with child threads in `D` state that hand `cmdline`:
```
for pid in /proc/*; do if [ -f $pid/cmdline ]; then echo -e "\n === $pid ==="; cat $pid/cmdline; fi; done
```

Print state of child threads including their caller `wchan`
```
for thid in /proc/3254247/task/*; do if [ -f $thid/stat ]; then if grep ' D ' $thid/stat; then echo "---"; cat "$thid/wchan"; echo "==="; fi; fi; done
```

Print status
```
cat /proc/3254248/status
```