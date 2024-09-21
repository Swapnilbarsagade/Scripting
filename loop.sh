#!/bin/bash

for i in {1..5}
do
    if ((i % 2 == 0))
    then
    	echo "$i swapnil"
    else 
        echo "$i aniket"
    fi
done
