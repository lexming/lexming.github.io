https://chrisshennan.com/blog/fixing-08-value-too-great-for-base-error-token-is-08

Summary

Bash script displays an error similar to:

08: value too great for base (error token is "08")

Reason

The is attempting to do a calculation like $item = $item - 1 and $item is a string value - in this case "08". This can be a result of trying to get the month using a date function. i.e.

item = $(date +%m)

Resolution

Explicitly state the base of a number using base#number so the item is 8 rather that 08.

item = $(date +%m)
item = $((10#$item))

or

item = $((10#$(date +%m)))


My case (tensec)

```
while read day hour min sec watts endtag; do
    ts=$(( ( 10#$hour * 3600 ) + ( 10#$min * 60 ) + 10#$sec ))
    pt=$(( ts - ts0 ))
done < $1
```
