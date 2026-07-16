---
title: Mixing quotes in Bash
created: 2026-07-16
modified: 2026-07-16
tags:
  - bash
---
[Quotations in Bash](https://www.gnu.org/software/bash/manual/html_node/Quoting.html) can be tricky, combining single quotes `'` and double quotes `"` can result in unexpected behaviours; and _escaping_ those quotes can quickly become very confusing.

## Leading double quotes

Single quotes within the double quotes as the leading string encapsulation have no special meaning beyond the `'` character itself. Hence, the variable substitution `$result` and any process substitution `$(…)` is interpreted as such and replaced in the output.

```shell caption="Single quotes within leading double quotes"
$ result=42; echo "The quoted result is '$result'"
  The quoted result is '42'
$ result=42; echo "The quoted result is ''$result''"
  The quoted result is ''42''
$ echo "The quoted hostname is '`hostname`'"
  The quoted hostname is 'myhost'
$ echo "The quoted hostname is '$(hostname)'"
  The quoted hostname is 'myhost'
```

Double quotes within leading double quotes is already a bit tricky

```shell caption="Doubles quotes within double quotes"
$ result=42; echo "The quoted result is "$result""
  The quoted result is 42
$ echo "The quoted hostname is "$(hostname)""
  The quoted hostname is myhost
```

The second time a double quote is found, it closes the first ones opening the string. So the previous example is interpreted as _string_ + _substitution_ + _empty string_.

Printing a `"` character with leading double quotes requires to either use single quotes or escape characters (_i.e._ `\"`).

```shell caption="Solution to doubles quotes within double quotes"
# WRONG: string + $result + empty string ("")
$ result=42; echo "The quoted result is "$result""
  The quoted result is 42
# CORRECT: string + quoted double quote ('"') + variable + ('"')
$ result=42; echo "The quoted result is "'"'$result'"'
  The quoted result is "42"
# CORRECT: string with escaped double quotes
$ result=42; echo "The quoted result is \"$result\""
  The quoted result is "42"
```

## Leading single quotes

Single quotes have the special meaning of treating all encapsulated characters as literals. Including the escape characters. Hence, it is trivial to print double quotes within single quotes, but no substitution will occur.

```shell caption="Double quotes within leading single quotes"
$ result=42; echo 'The quoted result is "$result"'
  The quoted result is "$result"
$ result=42; echo 'The quoted result is \"$result\"'
  The quoted result is \"$result\"
$ echo 'The quoted hostname is "$(hostname)"'
  The quoted hostname is "$(hostname)"
```

In this case, the solution is to close the single quotes before the substitution.

```shell caption="Solution to double quotes within leading single quotes"
# string (including " quotes) + variable + string (including " quotes)
$ result=42; echo 'The quoted result is "'$result'"'
  The quoted result is "42"
```

Printing a `'` character with leading single quotes cannot be done, the second `'` will always be interpreted as the closing single quote. Even if it is escaped, as the escape character is a literal backslash. Therefore, the solution requires closing the single quotes as well and printing the single quote within another context.

```shell caption="Solution to single quotes within leading single quotes"
# WRONG: string + variable + empty string
$ result=42; echo 'The quoted result is '$result''
  The quoted result is 42
# WRONG: string (including a backslash) + variable + empty string
$ result=42; echo 'The quoted result is \'$result''
  The quoted result is \42
# CORRECT: single quoted string + double quoted string (including ' quotes)
$ result=42; echo 'The quoted result is '"'$result'"
  The quoted result is '42'
```
