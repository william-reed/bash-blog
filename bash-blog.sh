#!/usr/bin/env bash

###############################################################################
# Bash Blog
# in comes dir of markdown out goes a navigatable website / blog
###############################################################################

# use pandoc to parse a md file
# file_name -> html
function parse_markdown() {
    cat "$DIR/$1.md" | pandoc
}

# cat the opening html
# file_name
function cat_start_html() {
    cat << END > $1
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="UTF-8">
    <link rel="stylesheet" href="$STYLE">
  </head>
  <body>
END
}

# cat the closing html
# file_name
function cat_end_html() {
    cat << END >> $1
    </body>
</html>
END
}

# cat the side bar html
# file_name, output
function cat_side_bar() {
    local file_name=$1
    local output=$2

    echo "    <div class=\"sidenav\">" >> $output

    # if not the root directory, add a link to parent dir
    if [ "$ROOT" == false ]; then
        echo "      <a href=\"../index.html\">../</a>" >> $output
    fi

    # list directories
    for dir in "${NESTED[@]}"; do
        echo   "        <a href=\"$DIR/$dir/index.html\">/$dir</a>" >> $output
    done

    # list files
    for f in "${FILES[@]}"; do
        if [[ $f == $file_name ]]; then
            echo "        <a class=\"selected\" href=\"$f.html\">$f</a>" >> $output
        else
            echo "        <a href=\"$f.html\">$f</a>" >> $output
        fi
    done

    echo "    </div>" >> $output
}

# cat the content html (the parsed markdown)
# file_name, html
function cat_content() {
    echo "  <div class=\"main\">" >> $1
    echo "      $2" >> $1
    echo "  </div>" >> $1
}

# cat summary content
# output
function cat_summary_content() {
    local output=$1

    cat << END >> $output
        <div class="main">
            <h1>Directory Summary</h1>
            <hr/>
            <h5>Number of markdown files in directory: ${#FILES[@]}</h5>
            <p>
END
    ls -1sh $DIR | sed 's/$/<\/br>/' >> $output
    cat << END >> $output
            </p>
        </div>
END
}

# turn a markdown file into the fully rendered html
# file_name
function render_file() {
    local body_html="$(parse_markdown $1)"
    local file_name=$1 # no extension
    local output=$DIR/"$1.html"
    shift # get rid of other args
    cat_start_html $output 
    cat_side_bar $file_name $output
    cat_content $output "$body_html"
    cat_end_html $output
}

# render a summary file for each dir
# this will be put as the index.html in each directory and contain summary info about the dir
# mainly needed to have a landing page for parent nav
function render_summary() {
    local file_name="index"
    local output=$DIR/"$file_name.html"

    cat_start_html $output
    cat_side_bar $file_name $output
    cat_summary_content $output
    cat_end_html $output
}

# render all markdown in current dir
function render() {
    # find all markdown in current directory
    FILES=()
    while IFS=  read -r -d $'\0'; do
        FILES+=("$REPLY")
    # get all markdown in this directory, remove the leading './' and trailing '.md' and turn it into a null separated sequence
    done < <(find $DIR -name "*.md" -maxdepth 1 -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' | tr '\n' '\0')

    # get all directories too
    NESTED=()
    # run recursively on any dirs
    while IFS=  read -r -d $'\0'; do
        NESTED+=("$REPLY")
    # same as above loop but for nested directories
    done < <(find $DIR -type d -maxdepth 1 -mindepth 1 -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' | tr '\n' '\0')

    # render summary for each dir
    render_summary

    # render each file
    for f in "${FILES[@]}"; do
        render_file $f
    done

    # TODO run in parallel
    for f in "${NESTED[@]}"; do
        ./$0 -r -d "$DIR/$f" -s "../$STYLE"
    done
}

# print out help
function usage() {
    cat << END
    Bash Blog
    Generate navigatable HTML from markdown filled directory.

    usage: bash-blog [-d directory] [-s css-file]
    
    arguments:
        -d, --dir           the directory to look for markdown (and gen output)
        -h, --help          brings up this message and exits
        -r, --not-root      add flag to prevent the markdown at this level from displaying a link to parent dir. Likely only useful from the script itself
        -s, --style         path to a css file to use a different stylesheet than default
        -v, --verbose       print verbose / debugging info
END
}

# print a message if debug enabled
# string
function debug() {
    if [ "$BASH_BLOG_DEBUG" == true ]; then
        echo -e $1
    fi
}


###############################################################################
# Top level (main)
###############################################################################

# parse arguments

ROOT=true
DIR=$PWD
STYLE="style.css"

while [ "$1" != "" ]; do
    case $1 in
        -r | --not-root)    ROOT=false
                            ;;
        -d | --dir)         shift
                            DIR=$1
                            ;;
        -s | --style)       shift
                            STYLE=$1
                            ;;
        -h | --help)        usage
                            exit
                            ;;
        -v | --verbose)     export BASH_BLOG_DEBUG=true # want children to debug too
                            ;;
        * )                 usage
                            exit
                            ;;
    esac
    shift
done

debug "root dir?\t:$ROOT"
debug "curr dir\t$DIR"
debug "style:\t\t$STYLE"
debug "---------"

render
