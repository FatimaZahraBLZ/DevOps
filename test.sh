#!/bin/bash

# This test simulates checking if the app returns the expected content
echo "Running app test..."
response=$(curl -s http://localhost:8084)

echo "$response" | grep -q "Version" && echo " App responds with version message" || echo " App did not return expected content"