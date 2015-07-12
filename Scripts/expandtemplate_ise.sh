#!/bin/bash

cat $1 | while read a; do
	b=${a,,}
	if [ "${b: -4}" = ".vhd" ]; then
		echo "xfile add \"../../${a}\""
	fi
	if [ "${b: -4}" = ".ucf" ]; then
		echo "xfile add \"../../${a}\""
	fi
	if [ "${b: -2}" = ".v" ]; then
		echo "xfile add \"../../${a}\""
	fi
done

