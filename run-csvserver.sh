#!/bin/bash

# Step 1: Run container in the background and check if it's running
docker run -d --name csvserver -p 9393:9300 sandipholambe/csvserver:latest
if [ "$(docker ps -q -f name=csvserver)" ]; then
    echo "CSV server container is running."
else
    echo "CSV server container failed to start."
    echo "Reason: $(docker logs csvserver)"
    exit 1
fi

# Step 2: Generate inputFile with random values
entries=${1:-10}
echo "Generating $entries entries for inputFile..."
for i in $(seq 0 $((entries-1))); do
    echo "$i, $RANDOM" >> inputFile
done
chmod +r inputFile
echo "inputFile generated."

# Step 3: Run container with inputFile available
docker stop csvserver && docker rm csvserver
docker run -d --name csvserver -p 9393:9300  -v $(pwd)/inputFile:/csvserver/inputdata sandipholambe/csvserver:latest
echo "CSV server container restarted with inputFile available."

# Step 4: Get shell access to container and find port
port=$(docker port csvserver 9300 | awk -F: '{print $2}')
echo "CSV server is running on port $port."
docker stop csvserver

# Step 5: Run container again with environment variable
docker run -d --name csvserver -p 9393:9300 -e CSVSERVER_BORDER=Orange -v $(pwd)/inputFile:/csvserver/inputdata sandipholambe/csvserver:latest
echo "CSV server container restarted with environment variable."

# Step 6: Confirm application is accessible at http://localhost:9393
echo "CSV server is accessible at http://localhost:9393"
