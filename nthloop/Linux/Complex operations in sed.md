---
title: Complex operations in sed
created: 2022-01-08
modified: 2026-03-24
tags:
  - regex
---
[Commands in sed](https://www.gnu.org/software/sed/manual/sed.html#sed-commands-list) can be constructed in sequences and nested in blocks allowing for more complex operation that the built-in commands.
## Sequence of commands

A single `sed` execution can run any number of _sed commands_ on the input text. The commands in the sequence are separated by semi-colons

```bash
sed 'command1;command2;command3'
```

For instance, consider the following sample text:

    1 Lorem ipsum dolor sit amet consectetur
    2 adipiscing elit. Quisque faucibus ex
    3 sapien vitae pellentesque sem placerat.

The following command contains a sequence of 3 _sed commands_ that will delete line 2, substitute some pattern and append a new line after another pattern:

```shell
$ sed '2d;s/Lorem/Verbum primum/;/placerat/a Haec est sententia addita.' lorem.txt

1 Verbum primum ipsum dolor sit amet consectetur
3 sapien vitae pellentesque sem placerat.
  Haec est sententia addita.
```

Sequences of commands are independent, each one applies to the complete text input.

## Operations within a match

Commands in _sed_ can be grouped in blocks that apply to same the _pattern space_. Those sequence of commands are separated by semi-colons and encapsulated in curly braces `{}`.

```bash
sed '/pattern/{command1;command2}'
```

Command blocks in _sed_ allow to perform more complex operations in the matching text than just using the simple built-in commands. We can use different patterns for selecting lines of text and for making substitutions. For instance, consider the following sample text:

    1 Lorem ipsum dolor sit amet consectetur
    2 adipiscing elit. Quisque faucibus ex
    3 sapien vitae pellentesque sem placerat.

The following custom `sed` command replaces all spaces with underscores (`y` command) on lines matching the word _Quisque_:

```shell
$ sed '/Quisque/{y/ /_/}' lorem.txt

1 Lorem ipsum dolor sit amet consectetur
2 adipiscing_elit._Quisque_faucibus_ex
3 sapien vitae pellentesque sem placerat.
```

This can be easily expanded with extra commands. The following command adds a substitution of the word _elit_ to _rosa_:

```shell
$ sed '/Quisque/{y/ /_/;s/elit/rosa/}' lorem.txt

1 Lorem ipsum dolor sit amet consectetur
2 adipiscing_rosa._Quisque_faucibus_ex
3 sapien vitae pellentesque sem placerat.
```

Using the insert `i` and append `a` commands right in the command-line is a bit more cumbersome as those require using new lines to separate the contents of insert/append from the other commands.

```shell
$ sed '/Quisque/{y/ /_/;s/elit/rosa/;i\
  Haec est sententia addita.
  }' lorem.txt
  
1 Lorem ipsum dolor sit amet consectetur
  Haec est sententia addita.
2 adipiscing_rosa._Quisque_faucibus_ex
3 sapien vitae pellentesque sem placerat.
```

## Script files

These operations in sed can become too complicated rather quickly, being impractical to run directly on the command-line. At this point, they can be put in their own file so-called a _sed script_ and be executed from there.

The command in the last example in the previous section that reads
```shell
sed '/Quisque/{y/ /_/;s/elit/rosa/;i\
Haec est sententia addita.
}' lorem.txt
```

Can be written in a _sed script_ as

```sed
/Quisque/{
  y/ /_/
  s/elit/rosa/
  i\
Haec est sententia addita
}
```

Then executed with the command

```shell
$ sed -f script.sed lorem.txt

1 Lorem ipsum dolor sit amet consectetur
  Haec est sententia addita
2 adipiscing_rosa._Quisque_faucibus_ex
3 sapien vitae pellentesque sem placerat.
```

Resulting in the same output as the original command.

> [!example] Example: controlling the installation of JAX in EasyBuild
> The installation of [JAX](https://github.com/jax-ml/jax) v0.3.25 in EasyBuild ensures the use of local sources for [TensorFlow](https://www.tensorflow.org/) by replacing the repository definition in the Bazel build files with a local one. 
> 
> This is achieved with [jaxlib_local-tensorflow-repo.sed](https://github.com/easybuilders/easybuild-easyconfigs/blob/84cba69f36cbac43e42c38aa58f95d70ce1ccc4a/easybuild/easyconfigs/j/jax/jaxlib_local-tensorflow-repo.sed), a sed script [applied to the WORSKPACE file](https://github.com/easybuilders/easybuild-easyconfigs/blob/7e514e163c1e5cf7cd08a2e2b626f66f1e86b4b4/easybuild/easyconfigs/j/jax/jax-0.3.25-foss-2022a.eb#L36) to match the repository definition of TensorFlow, comment out its contents and inject the local definition instead.
