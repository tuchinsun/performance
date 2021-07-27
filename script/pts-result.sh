#!/bin/bash

##
## https://jelastic.cloud/evaluation-criteria
##

cpu_raiting=(155 122 93)
ram_raiting=(10084 14051 18017)
hdd_raiting=(63 123 183)
PTS="/pts/phoronix-test-suite"

### CPU

function get_cpu_result {
    CPU=$($PTS result-file-to-json jelastic-cray | jq -r ".results[0].results.jelastic.value")
    echo $CPU | xargs printf '%.2f'
}

function get_cpu_rate {
    cpu_result=$(echo `get_cpu_result` / 1 | bc)

    if [[ $cpu_result -gt ${cpu_raiting[0]} ]]; then
        echo 2
    elif [[ $cpu_result -gt ${cpu_raiting[1]} ]]; then
        echo 3
    elif [[ $cpu_result -gt ${cpu_raiting[2]} ]]; then
        echo 4
    else
        echo 5
    fi
}

### RAM

function get_ram_result {
    RAM_INT=$($PTS result-file-to-json jelastic-ramspeed-integer | jq -r ".results[0].results.jelastic.value")
    RAM_FL=$($PTS result-file-to-json jelastic-ramspeed-float | jq -r ".results[0].results.jelastic.value")
    echo "( $RAM_INT + $RAM_FL ) / 2" | bc -l | xargs printf '%.2f'
}

function get_ram_rate {
    ram_result=$(echo `get_ram_result` / 1 | bc)

    if [[ $ram_result -lt ${ram_raiting[0]} ]]; then
        echo 2
    elif [[ $ram_result -lt ${ram_raiting[1]} ]]; then
        echo 3
    elif [[ $ram_result -lt ${ram_raiting[2]} ]]; then
        echo 4
    else
        echo 5
    fi
}

### HDD

function get_hdd_result {
    HDDR=$($PTS result-file-to-json jelastic-fio-randread | jq -r ".results[0].results.jelastic.value")
    HDDW=$($PTS result-file-to-json jelastic-fio-randwrite | jq -r ".results[0].results.jelastic.value")
    echo "( $HDDR + $HDDW )  / 2" | bc -l | xargs printf '%.2f'
}

function get_hdd_rate {
    hdd_result=$(echo `get_hdd_result` / 1 | bc)

    if [[ $hdd_result -lt ${hdd_raiting[0]} ]]; then
        echo 2
    elif [[ $hdd_result -lt ${hdd_raiting[1]} ]]; then
        echo 3
    elif [[ $hdd_result -lt ${hdd_raiting[2]} ]]; then
        echo 4
    else
        echo 5
    fi
}

function get_total_rate {

    cpu=$(get_cpu_rate)
    ram=$(get_ram_rate)
    hdd=$(get_hdd_rate)

    echo "$cpu*0.7 + $ram*0.15 + $hdd*0.15" | bc -l | xargs printf '%.1f'
}

function print_help {
    echo ""
    echo "Get Phoronix Test Results"
    echo "Use: $0 [--cpu-result] [--ram-result] [--hdd-result] [--cpu-rate] [--ram-rate] [--hdd-rate] [--total-rate]"
    echo ""
    exit 0
}

### MAIN

while [[ $# -ge 1 ]]; do
    key="$1"

    case $key in
        --cpu-result)
        get_cpu_result
        shift
        ;;

        --ram-result)
        get_ram_result
        shift
        ;;

        --hdd-result)
        get_hdd_result
        shift
        ;;

        --cpu-rate)
        get_cpu_rate
        shift
        ;;

        --ram-rate)
        get_ram_rate
        shift
        ;;

        --hdd-rate)
        get_hdd_rate
        shift
        ;;

        --total-rate)
        get_total_rate
        shift
        ;;

        *)
        print_help
        exit 0
        ;;
    esac
    shift
done

exit 0
