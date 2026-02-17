#!/bin/bash

PERSON1=Ramesh
PERSON2=Suresh

# you can use either $PERSON or ${PERSON}
echo "$PERSON1 : Hi ${PERSON2}, How are you?"
echo "$PERSON2 : Hello $PERSON1. I am fine, how are you?"
echo "${PERSON1} : I am doing good $PERSON2. what's going on?"
echo "$PERSON2: I started learning shell scripting $PERSON1"