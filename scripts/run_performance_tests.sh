#!/bin/bash

# Performance Test Runner Script
# Runs all integration performance tests and generates reports

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPORT_DIR="test/performance/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/performance_report_$TIMESTAMP.txt"

# Test files
TESTS=(
  "integration_test/app_launch_test.dart"
  "integration_test/timer_accuracy_test.dart"
  "integration_test/memory_usage_test.dart"
  "integration_test/animation_performance_test.dart"
  "integration_test/battery_consumption_test.dart"
)

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Performance Test Suite Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Print Flutter version
echo -e "${GREEN}Flutter version:${NC}"
flutter --version
echo ""

# Create report directory
mkdir -p "$REPORT_DIR"

# Initialize report file
echo "Performance Test Report" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Function to run a test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .dart)

    echo -e "${YELLOW}Running: $test_name${NC}"
    echo "----------------------------------------"

    # Add to report
    echo "Test: $test_name" >> "$REPORT_FILE"
    echo "File: $test_file" >> "$REPORT_FILE"
    echo "Start time: $(date)" >> "$REPORT_FILE"

    # Run the test
    if flutter test "$test_file" --verbose 2>&1 | tee -a "$REPORT_FILE"; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
        echo "Status: PASSED" >> "$REPORT_FILE"
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        echo "Status: FAILED" >> "$REPORT_FILE"
    fi

    echo "End time: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "----------------------------------------"
    echo ""
}

# Parse command line arguments
DEVICE=""
DEVICE_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --android)
            DEVICE_TYPE="android"
            shift
            ;;
        --ios)
            DEVICE_TYPE="ios"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --device DEVICE_ID    Specify device ID to run tests on"
            echo "  --android             Run on Android emulator"
            echo "  --ios                 Run on iOS simulator"
            echo "  --help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Run on connected device"
            echo "  $0 --android                          # Run on Android emulator"
            echo "  $0 --ios                              # Run on iOS simulator"
            echo "  $0 --device emulator-5554             # Run on specific device"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get Flutter dependencies
echo -e "${BLUE}Getting Flutter dependencies...${NC}"
flutter pub get
echo ""

# Run code generation if needed
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${BLUE}Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
    echo ""
fi

# Check for connected devices
echo -e "${BLUE}Checking for connected devices...${NC}"
flutter devices

# Device selection
if [ -n "$DEVICE" ]; then
    echo -e "${GREEN}Using device: $DEVICE${NC}"
    DEVICE_ARG="--device-id=$DEVICE"
elif [ "$DEVICE_TYPE" == "android" ]; then
    echo -e "${GREEN}Using Android emulator${NC}"
    DEVICE_ARG=""  # Let Flutter choose an Android device
elif [ "$DEVICE_TYPE" == "ios" ]; then
    echo -e "${GREEN}Using iOS simulator${NC}"
    DEVICE_ARG=""  # Let Flutter choose an iOS device
else
    echo -e "${YELLOW}No device specified, using default${NC}"
    DEVICE_ARG=""
fi

echo ""

# Run all tests
FAILED_TESTS=()
PASSED_TESTS=()

for test in "${TESTS[@]}"; do
    if [ -f "$test" ]; then
        run_test "$test"

        # Check exit status
        if [ $? -eq 0 ]; then
            PASSED_TESTS+=("$test")
        else
            FAILED_TESTS+=("$test")
        fi
    else
        echo -e "${YELLOW}Warning: Test file not found: $test${NC}"
        echo ""
    fi
done

# Print summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo "Summary" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"

if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
    echo -e "${GREEN}Passed Tests (${#PASSED_TESTS[@]}):${NC}"
    echo "Passed Tests (${#PASSED_TESTS[@]}):" >> "$REPORT_FILE"
    for test in "${PASSED_TESTS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $(basename "$test")"
        echo "  ✓ $(basename "$test")" >> "$REPORT_FILE"
    done
    echo ""
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}Failed Tests (${#FAILED_TESTS[@]}):${NC}"
    echo "Failed Tests (${#FAILED_TESTS[@]}):" >> "$REPORT_FILE"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $(basename "$test")"
        echo "  ✗ $(basename "$test")" >> "$REPORT_FILE"
    done
    echo ""
fi

echo -e "${BLUE}Report saved to: $REPORT_FILE${NC}"
echo ""

# Exit with appropriate code
if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
