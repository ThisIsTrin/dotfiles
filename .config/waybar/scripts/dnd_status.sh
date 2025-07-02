#!/bin/bash

mode=$(makoctl mode)
if [ "$mode" = "dnd" ]; then
    echo ""  # DND icon
else
    echo ""  # Bell icon
fi

