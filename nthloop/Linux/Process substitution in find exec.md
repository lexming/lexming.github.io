Process substitution `$(...)` gets executed first, so it cannot be passed into a `find -exec` command.

Solution 

```bash
dirs_acl_cmd='nameq=$(printf "%q" "{}"); reset_acl '"$dirs_acl"' "$nameq"'
fd -j $THREADS -u -td . $vo_dir --exec bash -c "$dirs_acl_cmd"
```