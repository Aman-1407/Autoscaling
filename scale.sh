#!/bin/bash

while true
do
  # get the current number of replicas for the app2 service
  current_replicas=$(docker-compose ps -q app2 | wc -l)
  # get the average CPU usage for the app2 service containers
  avg_cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" $(docker-compose ps -q app2) | awk '{total = total + $1} END {print total/NR}')
  
  # check if we need to scale up or down based on the CPU usage
  if [ $(echo "$avg_cpu_usage > 75" | bc -l) -eq 1 ] && [ $current_replicas -lt 8 ]
  then
    # scale up by adding another replica
    docker-compose up --scale app2=+1
    current_replicas=$((current_replicas + 1))
    sleep 40
  elif [ $(echo "$avg_cpu_usage < 30" | bc -l) -eq 1 ] && [ $current_replicas -gt 2 ]
  then
    # scale down by removing a replica
    docker-compose up --scale app2=-1
    current_replicas=$((current_replicas - 1))
    sleep 40
  fi
  
  sleep 10
done

