#!/usr/bin/env bash

###############################################################################
# Bash Blog
# in comes dir of markdown out goes a navigatable website / blog
###############################################################################

# use pandoc to parse a md file
# file_name -> html
function parse_markdown() {
    cat "$1.md" | pandoc 
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
    <link rel="stylesheet" href="style.css">
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
# file_name, output, array of files
function cat_side_bar() {
    local file_name=$1
    local output=$2
    shift 2 # get rid of previous args
    echo "    <div class=\"sidenav\">" >> $output
    local files=("$@")
    for f in "${files[@]}"; do
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

# turn a markdown file into the fully rendered html
# file_name, array of files
function render_file() {
    local body_html="$(parse_markdown $1)"
    local file_name=$1 # no extension
    local output="$1.html"
    shift # get rid of other args
    cat_start_html $output 
    cat_side_bar $file_name $output $@
    cat_content $output "$body_html"
    cat_end_html $output
}

# render all markdown in current dir
function render() {
    # find all markdown in current directory
    files=()
    while IFS=  read -r -d $'\0'; do
        files+=("$REPLY")
    # get all markdown in this directory, remove the leading './' and trailing '.md' and turn it into a null separated sequence
    done < <(find * -name "*.md" -maxdepth 1 -execdir sh -c 'printf "%s\n" "${0%.*}"' {} ';' | tr '\n' '\0')
    #done < <(find * -name "*.md" -maxdepth 1 -print0)

    # render each file
    for f in "${files[@]}"; do
        render_file $f "${files[@]}"
    done
}

render
