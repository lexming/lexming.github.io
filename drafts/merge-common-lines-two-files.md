
Many options in https://www.baeldung.com/linux/files-common-lines

This one with `grep` is fast and does not require sort:

```
grep -Fxf modulejail.node700.conf modulejail.4.conf > modulejail.5.conf
```
