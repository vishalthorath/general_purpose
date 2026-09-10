#!/bin/bash

test -f index.html
grep -q "Task 19" index.html

echo "Test passed"
