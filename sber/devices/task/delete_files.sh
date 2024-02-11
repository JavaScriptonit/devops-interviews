#!/bin/bash

path="/Users/andreyshabunov/PhpstormProjects/devops-interviews/sber/devices/task"

for ((i=1; i<=10; i++))
do
  filename="${path}/${i}a"
  rm -f "$filename"
done