#!/bin/bash

set -e

TEST_FILE="test_input.txt"
EXECUTABLE="gnl_wrap_test"
WRAP_LOG="malloc_log.txt"

# Create a temporary test file with sample content
echo -e "First line\nSecond line\nThird line" >"$TEST_FILE"

# Compile the project with malloc/free wrappers
echo "🛠️ Compiling with malloc/free wrappers..."
cc -Wall -Wextra -Werror -D BUFFER_SIZE=32 \
	get_next_line.c get_next_line_utils.c main.c malloc_wrap.c \
	-Wl,--wrap,malloc -Wl,--wrap,free \
	-o "$EXECUTABLE"

# Run the executable with deterministic malloc failures
echo "🔁 Running $EXECUTABLE with malloc failure injection (MALLOC_SEED=42)..."
MALLOC_SEED=42 ./$EXECUTABLE "$TEST_FILE" 2>"$WRAP_LOG"

# Print results
echo "📄 Execution completed. Check '$WRAP_LOG' for malloc/free trace."

# Clean up
echo "🧹 Cleaning up..."
rm -f "$TEST_FILE" "$EXECUTABLE"
echo "✅ Done."
