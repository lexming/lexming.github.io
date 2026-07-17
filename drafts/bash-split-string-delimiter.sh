```
while IFS=';' read -ra ADDR; do
  for i in "${ADDR[@]}"; do
    # process "$i"
  done
done <<< "$IN"
```
