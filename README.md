[![Slack][slack-badge]][slack-link]

# Koi

Project scaffolder, with a focus on simplicity.

## Install

With [fisherman]

```
fisher koi
```

## Usage

```
koi your/repo folder
```

## Templates
There are only a few koi-specific files, all of which are found in the root directory:
```
.
├── ".intro"
├── ".postinstall"
├── ".preinstall"
└── ".vars"
```

A list of available templates can be found [here](./templates.txt).

### .intro

At times you want to present or explain some info to the template user. This can be done by writing text in `.intro`. Only the first 10 lines will be printed during the scaffolding process, to encourage conciseness.

### .preinstall/.postinstall
`.preinstall` and `postinstall` are executables. 

Because the entire environment is available to you, the things you could do are endless. You could, for example:

1. Install CLI tools (sass compiler, for example).
2. Clone a framework into a directory.

Please inspect the templates you use for malicious commands before you install the templates.

### .vars
Your template folder should have a `.vars` file in the root directory. Write each variable name in a separate line as follows:

```
foo
bar
baz
```

`koi` will substitute all appearances of `{{{variable-name}}}` in files, filenames and folder-names with user-input during the scaffolding process. For example of a template, look at [koi-template].

## Credit

Much of the code was based off [fisherman/new], written by @bucaran.

[slack-link]: https://fisherman-wharf.herokuapp.com
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg
[fisherman]: https://github.com/fisherman/fisherman

[fisherman/new]:https://github.com/fisherman/new
[koi-template]: https://github.com/jethrokuan/koi-template
