#!/bin/bash

# replace-helm-tokens
# A script to replace tokens in a template file with values in a variable file.
# Will output a replaced value file. 
# Variable file must be formatted with TOKEN: VALUE
#
# Example:
# vars.yaml
# -------
# FOO: bar
# HELLO: world
#
# Template file tokens must be formatted as %%TOKEN%%
#
# Example:
# template.yaml
# -------
# FOO: %%BAR%%
# HELLO: %%WORLD%%

usage()
{
  cat << EOF
usage: replace-helm-tokens [-h --help]
                           -f --variable-file
                           --template-file
                           [--output-file]
EOF
}

##### Parameters

VARIABLE_FILE=
TEMPLATE_FILE=
OUTPUT_FILE=values.yaml

##### Functions

join()( local IFS="$1"; shift; echo "$*"; )
error()(echo "$1" | sed $'s,.*,\e[31m&\e[m,')

##### Main

while [ "$1" != "" ]; do
    case $1 in
        -f | --variable-file) shift
                                VARIABLE_FILE=$1
                                ;;
        --template-file)      shift
                                TEMPLATE_FILE=$1
                                ;;
        --output-file)        shift
                                OUTPUT_FILE=$1
                                ;;
        -h | --help )           usage
                                exit
    esac
    shift
done

missing_args=()

if [ -z "$VARIABLE_FILE" ]; then
  missing_args+=("--variable-file/-f")
fi
if [ -z "$TEMPLATE_FILE" ]; then
  missing_args+=("--template-file")
fi

if [ ${#missing_args[@]} -ne 0 ]; then
  error "The following arguments are required: "$(join , "${missing_args[@]}") >&2
  usage
  exit 1
fi

cp $TEMPLATE_FILE $OUTPUT_FILE

declare -A variables
while IFS=": " read token val
do 
  search=%%$token%%
  replace=$val
  sed -i "s|${search}|${replace}|g" $OUTPUT_FILE
done < $VARIABLE_FILE 
