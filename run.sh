#!/bin/bash
#
# Mathieu CAROFF
# ./run.sh
# Created 2018-11-20
#
#
# A script to analyse and run vhdl files.

# Script settings
source="sources"
gsource="gsource"
osource="osource"

bench="bench"
gbench="gbench"
obench="obench"

buildcmd=(ghdl -a)
runcmd=(ghdl -r)

#/! (end of 1st help section)

me="${BASH_SOURCE:-0}"
[[ "$me" == */* ]] || me="./$me"

help() {
    awk '
    /^#\/!/{a=0}
    /^#!\//{a=1}
    a' \
    "$me"

    awk '
    /<\/help>/{b=0}
    b
    /<h[e]lp>/{b=1}' \
    "$me" \
    | cut -c 9-
}

hint() {
    echo "Run '$0 --help' for help.""
You may want to use --do pre-loaded commands:
* '$0 --do vcom'  # Modelsim
* '$0 --do build' # GHDL
* '$0 --do clean' #GHDL"
}

stem() {
    name="${1%.vhd}"
    filename "${name%_tb}"
}

guess() {
    # Guess the path to the file, from the existence of the `_tb` suffix

    local dir filename

    for arg
    do
        filename="$(filename "$arg")"
        name="${filename%.vhd}"
        if [[ "$name" =~ _tb$ ]]
        then dir="${bench}"
        else dir="${source}"
        fi
        echo "${dir}/${name}.vhd"
    done
}

filename() {
    # Remove the "directory path" part from a filepath
    path="$1"
    echo "${path##*/}"
}

named() {
    # Print the given name before the output of the command
    # Handle multi-line output by prepending a newline
    # Handle empty outputs by not printing anything

    name="$1"
    cmd="$2"
    out="$(eval $cmd 2>&1)"
    if [[ "$out" =~ $'\n' ]]
    then out=$'\n'"$out"
    else out=" $out"
    fi
    if [[ -n "$out" ]]
    then echo "($name)$out"
    fi
}

test() {
    # Analyse then run the given (entity) names

    for arg
    do
        name="$(stem "$arg")"
        named "A:$name" "${buildcmd[*]} '${source}/${name}.vhd' '${bench}/${name}_tb.vhd'"
    done

    run "$@"
}

# Discarded as buggy because entities require a specific order for analyse
# use `--build run-all` (build; run_all;) instead.
#
# test_all() {
#     # Test all entities that can be tested
#     # Look for names in $source and in $bench

#     test $(ls {$source,$bench}/*.vhd | sed -E 's/(_tb)?\.vhd$//;s_.*/__' | sort -u) 2>&1 \
#     | grep -Ev 'ghdl: cannot (open.*\.vhd$|find entity or configuration)' \
#     | grep -Ev ': design file is empty \(no design unit found\)'
# }

gen_bench() {
    # Generate files in $gbench

    today="$(date +%Y-%m-%d)"
    mkdir -p "$gbench"
    for f in bench_config/*
    do
        f="${f##bench_config/}"
        local name="${f%.txt}"
        echo gen: $name
        python3 genBench.py \
            --source "${osource}" \
            --gbench "${gbench}" \
            --author "Mathieu CAROFF" \
            --date "${today}" \
            "${name}"
    done
}

gen_source() {
    # Generate files in $gsource

    mkdir -p "${gsource}"
    make generate_tables
    # ./generate_tables 2 3 9 11 13 14 > "${source}"/gfmultbox.vhd
    for k in 2 3 9 11 13 14
    do ./generate_tables "${k}" > "${gsource}/gftimes${k}box.vhd"
    done
}

# COMMAND
analyse() {
    # Run the GHDL analyse step on each of the given (entity) names

    for name
    do
        named "A:$name" "${buildcmd[*]} '$(guess "$name")'"
    done
}

analyse_source() {
    analyse util_type

    analyse util_{str,control} gftimes{2,3,9,11,13,14}box

    analyse tool_test_bench_{bit8,byte16}{,_3}

    analyse sbox{,_inv}

    analyse {subbytes,shiftrows,mixcolumns}{,_inv} addroundkeys

    analyse aes_round_inv keyschedule_fake

    analyse aes128_fsm_moore_inv
}

analyse_bench() {

    analyse $(ls "$bench"/*_tb.vhd) 2>&1 \
    | grep -Ev 'ghdl: cannot (open.*\.vhd$|find entity or configuration)' \
    | grep -Ev ': design file is empty \(no design unit found\)'
    true # We don't care about the return code of grep

}

################

build() {
    # Run the GHDL analyse step on known sources and all test benches
    analyse_source
    analyse_bench
}

# COMMAND
run() {
    # Run the test bench for the given (entity) names

    for arg
    do
        name="$(stem $arg)"
        named "R:$name" "${runcmd[*]} '${name}_tb'"
    done \
    | sed '/numeric_std-body.v93:2098:7:@0ms:(assertion warning): NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0/c!' \
    | sed ':a;N;s/!\n!/!!/;/!/ba;' \
    | sed -E '
        s%\(report note\):%::%
        s%:\(assertion error\):%:!:%
        s%: end of test$%: end%
        s%end of tes(.*)$%\1 end%
        s%'"$source"'/tool_test_bench_b.*[0-9].vhd:[0-9]+:[0-9]+:%tools:%
        # s%'"$bench"'/(.*)_tb.vhd:[0-9]+:[0-9]+:@(.*)%@\2 \1 end%
    '
}

# COMMAND
run_all() {
    run $(ls "$bench"/*_tb.vhd) 2>&1
}

no_cmd_selected_error() {
    echo "Error, no command selected, but got $1"
    exit 2
}

cd "${me%/*}" || exit 120

if [ " " == "$* " ]
then set -- call hint
fi

cmd=no_cmd_selected_error

while [[ $# -ge 1 ]]
do
    arg="$1"
    shift
    case "$arg" in
    # <help>
        #######
        # Help
        #######
        --help|-h)
            # Show this help
            help
            # Note: in this script all commands exists as `--option`s, 
            # except for those which take an arbitrary number of
            # parameters
        ;;

        #######
        # Miscelaneous
        #######
        --analyse-source)
            # Analyse all source files, in the right order
            analyse_source
        ;;
        --analyse-bench)
            # Analyse all the test bench files found in bench/
            analyse_bench
        ;;
        --run-all)
            # Run all test benches
            run_all
        ;;
        -s|--sourcing)
            target="$1"
            shift
            source "$target"
        ;;

        #######
        # Setting override
        #######
        --buildcmd)
            buildcmd=($1)
            shift
        ;;
        --runcmd)
            runcmd=($1)
            shift
        ;;
        --source|gsource|osource|bench|gbench|obench)
            # These commands allow to set the given key to the given value
            # (`--key value`)
            key="${arg#--}" # Remove `--` from arg.
            typeset "${key}=$1"
            # typeset will perform the given variable setting
            shift
        ;;

        #######
        # Cleanable options
        #######
        # use --clean the files they created #
        -g|--gen|--generate)
            # Generate test bench files in gen/ from files in bench_config
            # and files in template/
            gen_bench
            # Also generates G.F. tables in gsource/
            gen_source
        ;;
        -c|--copy)
            # Copies files to the $bench/ and $source/ directories,
            # which is necessary before building.
            mkdir -p "$bench" "$source"
            cp --update "${osource:-!}"*/* "${gsource:-!}"/* "${source:-!}"
            cp --update "${obench:-!}"/*   "${gbench:-!}"/*  "${bench:-!}"
        ;;
        -b|--build)
            # Run the GHDL analyse step on known sources and all test benches
            # `--build` is equivalent to `--analyse-source --analyse-bench`
            build
        ;;
        --clean)
            target="$1"
            shift
            case "$target" in
                build)
                    rm work-obj93.cf
                ;;
                generate)
                    rm generate_tables
                    rm -r "$gbench" "$gsource"
                ;;
                copy)
                    rm -r "$source" "$bench"
                ;;
                *)
                    kind="--clean target"
                    echo "$me: doesn't recognise $kind '$arg'"
                    exit 2;
                ;;
            esac
        ;;

        #######
        # Commands with arguments
        #######
        analyse)
            # Run the GHDL analyse step on each of the given (entity) names
            analyse "$@"
            exit $?
        ;;
        run)
            # Run the test bench for the given (entity) names
            run "$@"
            exit $?
        ;;
        test)
            # Analyse then run the given (entity) names
            test "$@"
            exit $?
        ;;
        call)
            # Run a function of the script that isn't supposed to be run
            # from outside the script
            func="$1"
            shift
            "$func" "$@"
            exit $?
        ;;

        #######
        # --do helper command
        # *Pre-fabricated commands*
        #######
        --do)
            target="$1"
            shift
            cmd=(bash "${me#./}")
            case "$target" in
                vcom)
                    sourceme="sourceme.vhdl.sh"
                    if [ -f "$sourceme" ]; then
                        source "$sourceme"
                    fi
                    if hash vcom &>/dev/null; then
                        cmd+=(
                            --buildcmd "vcom"
                            --build
                            call echo $'Now use:\nvsim' bench/*_tb.vhd
                        )
                    else 
                        echo "Cannot find vcom. Aborting."
                        exit 3
                    fi
                ;;
                test)
                    cmd+=(
                        --do clean
                        --generate --copy --build
                        --clean generate
                        --run-all
                    )
                ;;
                clean)
                    cmd+=(
                        --clean build
                        --clean generate
                        --clean copy
                    )
                ;;
                *)
                    kind="--do target"
                    echo "$me: doesn't recognise $kind '$arg'"
                    exit 2;
                ;;
            esac
            echo "Running ${cmd[@]}"
            "${cmd[@]}"
        ;;
    # </help>
        *)
            case "$arg" in
                --*|-*) kind='option';;
                *) kind='command';;
            esac
            echo "$me: doesn't recognise $kind '$arg'"
            hint
            exit 2
        ;;
    esac
done

# Discarded

# build|anaylse|run|test)
#     # Set the command that will be executed when non-command appears
#     cmd="$arg"
#     ;;


# The below approach was probably excessive, which is why it
# was discarded. It was at the end of `*)`
#
# arg="${arg#'\'}" # Allow escaping - and --
# echo "[" "$cmd" "$arg" "$@" "]"
# set -- "$arg" "$@" # push back "$arg"
# "$cmd" "$@"
# # The return code of $cmd is the number of argumets it used up
# ret=$?
# # If the return code is 255, it means it used everything.
# [ $ret == 255 ] && ret=$#
# shift $ret
