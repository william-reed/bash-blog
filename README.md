# Bash Blog
in comes a dir of markdown, out goes a navigatable website / blog

### Requirements
- [Pandoc](https://github.com/jgm/pandoc/blob/master/INSTALL.md) needed for parsing markdown into HTML

### Usage
1. Run the script in a directory with some markdown
2. Copy in `styles.css` into that dir or pass in your own as shown below
3. Enjoy HTML

```
    Bash Blog
    Generate navigatable HTML from markdown filled directory.

    usage: bash-blog [-d directory] [-s css-file]

    arguments:
        -d, --dir           the directory to look for markdown (and gen output)
        -h, --help          brings up this message and exits
        -r, --not-root      add flag to prevent the markdown at this level from displaying a link to parent dir. Likely only useful from the script itself
        -s, --style         path to a css file to use a different stylesheet than default
        -v, --verbose       print verbose / debugging info
```
