# #!/bin/bash

# # Run your command
# echo 'Running tests'
# output=$(php artisan test | tee output.txt)
# # echo "The output of the command is: $output"

# # Check if the output contains "failed"
# if [[ $output == *"failed"* ]]; then
#   echo "Test failed"
#   echo $output | grep -oP 'Tests: +\K[0-9]+ failed'
#   exit 1
# else
#   echo "Test passed"
# fi

# echo 'Build & Up latest'
# docker compose up -d --build
 
#!/bin/bash

# Run your command
echo -e "\033[36mRunning tests\033[0m"
output=$(php artisan test | tee testoutput.txt)

# Extract the number of passed and skipped tests
skipped_tests=$(echo "$output" | grep -oP 'Tests: +\K[0-9]+(?= skipped)')
passed_tests=$(echo "$output" | grep -oP 'Tests: +\K[0-9]+(?= passed)')
failed_tests=$(echo "$output" | grep -oP 'Tests: +\K[0-9]+(?= fail)')

# Check if the output contains "failed"
if [[ $output == *"fail"* ]]; then
    echo -e  "\033[31mTest failed\033[0m"
    echo -e  "\033[31mFailed tests: $failed_tests\033[0m"
else
    echo -e  "\033[32mTest passed\033[0m"
    echo -e  "\033[32mPassed tests: $passed_tests\033[0m"
    echo -e  "\033[32mPassed tests: $skipped_tests\033[0m"
fi

# Build Vite for production
# this is now redundant as we are building it in the dockerfile
# echo -e  "\033[36mBuilding Vite for production\033[0m"
# npm run build
# if [ $? -ne 0 ]; then
#     echo -e  "\033[31mFailed to build for production\033[0m"
#     exit 1
# fi

echo -e  "\033[36mBuild & Up latest\033[0m"
docker compose up -d --build
