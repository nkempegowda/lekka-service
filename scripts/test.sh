#!/bin/bash
set -e

# Test script executed by CodeBuild
# Runs unit tests for the application

echo "=========================================="
echo "Running Tests"
echo "=========================================="

echo "Running Maven tests..."
mvn test

echo "=========================================="
echo "Tests completed successfully!"
echo "=========================================="

