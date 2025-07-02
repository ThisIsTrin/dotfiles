#!/bin/bash

mode=$(makoctl mode)
if [ "$mode" = "dnd" ]; then
    makoctl mode -s default
else
    makoctl mode -s dnd
fi

