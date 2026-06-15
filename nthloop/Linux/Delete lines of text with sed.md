---
title: Delete lines of text with sed
created: 2022-07-07
modified: 2026-03-23
tags:
  - regex
---
## Delete each matching line

Probably the simplest case is to delete each line of text that matches the _regex_ pattern.

```bash
sed '/pattern/d' input.txt
```

Example on sample text[^1] with line numbers kept as in the original. Lines 3 and 10 deleted:

```shell
$ sed '/sem/d' sample.txt

   1   Lorem ipsum dolor sit amet consectetur
   2   adipiscing elit. Quisque faucibus ex
   4   In id cursus mi pretium tellus duis
   5   convallis. Tempus leo eu aenean sed
   6   diam urna tempor. Pulvinar vivamus
   7   fringilla lacus nec metus bibendum
   8   egestas. Iaculis massa nisl malesuada
   9   lacinia integer nunc posuere. Ut
  11   taciti sociosqu. Ad litora torquent per
  12   conubia nostra inceptos himenaeos.
```

## Delete all lines between matching patterns

Delete each line of text that matches the _regex_ pattern and all lines in between them.

```bash
sed '/pattern1/,/pattern2/d' input.txt
```

Example on sample text[^1] with line numbers kept as in the original. Lines 2 to 9 deleted:

```shell
$ sed '/Quisque/,/posuere/d' sample.txt

1   Lorem ipsum dolor sit amet consectetur
10  hendrerit semper vel class aptent
11  taciti sociosqu. Ad litora torquent per
12  conubia nostra inceptos himenaeos.
```

## Delete all lines between matching patterns, excluding the patterns

Delete each line of text between the lines that match the _regex_ pattern, but exclude the lines with the matches.

```bash
sed '/pattern1/,/pattern/{//!d}' input.txt
```

The _sed command_ `{//!d}` reuses the same pattern from the _outside_ command and deletes `d`  all lines that do not match `!`  the pattern. Example on sample text[^1] with line numbers kept as in the original. Lines 3 to 8 deleted:

```shell
$ sed '/Quisque/,/posuere/{//!d}' sample.text

1   Lorem ipsum dolor sit amet consectetur
2   adipiscing elit. Quisque faucibus ex
9   lacinia integer nunc posuere. Ut
10  hendrerit semper vel class aptent
11  taciti sociosqu. Ad litora torquent per
12  conubia nostra inceptos himenaeos.
```

> [!info] More complex _sed_ operations
> [[Complex operations in sed]] can be used in the previous examples as well. The delete command `d` can be replaced by any other sequence of _sed commands_. Example replacing all lines in between the matching pattern with the text `PLACEHOLDER`:
> ```shell
> sed '/Quisque/,/posuere/{//!s|.*|PLACEHOLDER|}' sample.text
> ```

[^1]: Sample text

    1 Lorem ipsum dolor sit amet consectetur
    2 adipiscing elit. Quisque faucibus ex
    3 sapien vitae pellentesque sem placerat.
    4 In id cursus mi pretium tellus duis
    5 convallis. Tempus leo eu aenean sed
    6 diam urna tempor. Pulvinar vivamus
    7 fringilla lacus nec metus bibendum
    8 egestas. Iaculis massa nisl malesuada
    9 lacinia integer nunc posuere. Ut
    10 hendrerit semper vel class aptent
    11 taciti sociosqu. Ad litora torquent per
    12 conubia nostra inceptos himenaeos.
