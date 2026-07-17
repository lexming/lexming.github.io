---
title: Passing from find to sub-shells
created: 2026-07-17
modified: 2026-07-17
tags:
  - bash
---
Assume you have the following files with cursed names:

```
.
├── file1.txt
├── file "double" and spaces.txt
├── file 'quotes' and spaces.txt
└── file spaces.txt
```

If you hit any of those files on a `find` command , it is easy to operate on them with the `-exec` option and filenames will be properly protected along the way.

```shell
find . -type f -exec ls {} \;
```
```
./file1.txt
'./file spaces.txt'
"./file 'quotes' and spaces.txt"
'./file "double" and spaces.txt'
```

## Sub-shell in find exec

More complex operations than a single command such as `ls` might need to launch a sub-shell and pass those filenames to it as arguments, which might bring trouble.

> [!info] 
> In the following examples I keep using a simple `ls` command in the _bash_ sub-shell, but that can be a script of any complexity.

```shell
find . -type f -exec bash -c 'ls {}' \;
```
```
./file1.txt
ls: cannot access './file': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
ls: cannot access './file': No such file or directory
ls: cannot access 'quotes': No such file or directory
ls: cannot access 'and': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
ls: cannot access './file': No such file or directory
ls: cannot access 'double': No such file or directory
ls: cannot access 'and': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
```

### Protecting the arguments fails

The previous errors with the sub-shell are clearly due to a bad protection of the arguments, leading `ls` to recognise each white space as an argument separator. Hence, only the simple filename `file1.txt` hits the target.

This issue can be improved by escaping the _special_ characters in the filenames such as white spaces and quotes. A common utility to automatically escape strings is `printf "%q"`

```shell
printf "%q" "file 'quotes' and spaces.txt"
  file\ \'quotes\'\ and\ spaces.txt
```

Therefore, we can try to escape all arguments passed by `find` to the sub-shell. We first create a command that escapes the filenames into a variable called `$protname` and then executes `ls` on those protected filenames:

```shell
cmd='protname=$(printf "%q" "{}");
     echo == targeting $protname;
     ls $protname';
find . -type f -exec bash -c "$cmd" \;
```
```
== targeting ./file1.txt
./file1.txt
== targeting ./file\ spaces.txt
ls: cannot access './file\': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
== targeting ./file\ \'quotes\'\ and\ spaces.txt
ls: cannot access './file\': No such file or directory
ls: cannot access '\'\''quotes\'\''\': No such file or directory
ls: cannot access 'and\': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
== targeting ./file\ double\ and\ spaces.txt
ls: cannot access './file\': No such file or directory
ls: cannot access 'double\': No such file or directory
ls: cannot access 'and\': No such file or directory
ls: cannot access 'spaces.txt': No such file or directory
```

However, `ls` still fails to recognise the escaped characters. We can partially improve this outcome by generating a string with the full command and interpreting that string with `eval`:

```shell
cmd='protname=$(printf "%q" "{}");
     eval "echo == targeting $protname; ls $protname"';
find . -type f -exec bash -c "$cmd" \;
```
```
== targeting ./file1.txt
./file1.txt
== targeting ./file spaces.txt
'./file spaces.txt'
== targeting ./file 'quotes' and spaces.txt
"./file 'quotes' and spaces.txt"
== targeting ./file double and spaces.txt
ls: cannot access './file double and spaces.txt': No such file or directory
```

Now we managed to hit 3 of 4 targets. Which is an improvement, but it still fails on the filename with double quotes. This failure is caused by the double quotes used in the `printf` command to handle the arguments from _find_ in `"{}"`. They become the leading quotes of the argument string and following the [[Mixing quotes in Bash|quote parsing convention in bash]], any additional double quotes in the argument itself will be paired with the leading quotes; making them disappear from the output string.

Replacing the double quotes with single quotes just shifts the issue to another case. Removing the quotes is not an option either, as the arguments passed into `printf` are not escaped.

The real problem with this approach is that the variable substitution happens before the execution of the command. First, the `$cmd` variable in the `find` command gets replaced, and then the execution of `find` will replace `{}` with each _result_ found. Therefore, we are embedding the _results_ into the command line of the sub-shell itself, which cannot avoid losing some quote characters in the process as we need to use some leading quotes. **So this is the wrong approach.**

### Properly passing arguments to sub-shells

The solution to the previous issues is to properly pass the results of the _find_ command as actual arguments of the sub-shell.

```shell
find . -type f -exec bash -c 'ls "$@"' _ {} \;
```
```
./file1.txt
'./file spaces.txt'
"./file 'quotes' and spaces.txt"
'./file "double" and spaces.txt'
```

Here the arguments are **not** part of the command line, but they are arguments of the sub-shell itself. Hence, they can be handled as usual with `$@`. We just need to pass `_` as argument zero `$0`.

This approach can be made as complex as needed with the use of functions.

```shell
function listfile {
    ls "$@";
};
export -f listfile;
find . -type f -exec bash -c 'listfile "$@"' _ {} \;
```
```
./file1.txt
./'file spaces.txt'
./"file 'quotes' and spaces.txt"
./'file "double" and spaces.txt'
```
