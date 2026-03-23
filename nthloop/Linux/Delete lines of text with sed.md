---
title: Delete lines of text with sed
date: 2022-07-07
update: 2026-03-23
tags:
  - regex
---
## Delete each matching line

Probably the simplest case is to delete each line of text that matches the _regex_ pattern.

```bash
sed '/pattern/d' input.txt
```

Example on sample text[^1] with line numbers kept as in the original. Lines 3 and 10 deleted:

```text
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

```text
$ sed '/Quisque/,/posuere/d' sample.txt
   1   Lorem ipsum dolor sit amet consectetur
   10   hendrerit semper vel class aptent
   11   taciti sociosqu. Ad litora torquent per
   12   conubia nostra inceptos himenaeos.
```

## Delete all lines between matching patterns, excluding the patterns

Delete each line of text between the lines that match the _regex_ pattern, but exclude the lines with the matches.

```bash
sed '/pattern1/,/pattern/{//!d}' input.txt
```

Example on sample text[^1] with line numbers kept as in the original. Lines 3 to 8 deleted:

```text
sed '/Quisque/,/posuere/{//!d}' sample.text
   1   Lorem ipsum dolor sit amet consectetur
   2   adipiscing elit. Quisque faucibus ex
   9   lacinia integer nunc posuere. Ut
   10   hendrerit semper vel class aptent
   11   taciti sociosqu. Ad litora torquent per
   12   conubia nostra inceptos himenaeos.
```

Note: the d operator can be any other sed operator

```careful with this, NEW_STUFF will be substituted on each line between the patterns
 sed '/pattern1/,/^pattern2/{//!s|.*|NEW_STUFF|}' CMakeLists.txt
```

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
