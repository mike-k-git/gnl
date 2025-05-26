#!/bin/bash

LOG="eval.log"
MAIN_EMPTY="main_empty.c"
GNL_EXEC="a.out"

MANDATORY_FILES=("get_next_line.c" "get_next_line.h" "get_next_line_utils.c")
BONUS_FILES=("get_next_line_bonus.c" "get_next_line_bonus.h" "get_next_line_utils_bonus.c")
ALLOWED_FUNCTIONS=("read" "malloc" "free" "__libc_start_main")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

run_test() {
	local test_name=$1
	local test_content=$2
	local expected_output=$3

	local test_file="test_${test_name}.txt"
	local output_file="output_${test_name}.txt"

	printf "%s" "$test_content" >"$test_file"

	valgrind --leak-check=full --error-exitcode=1 ./$GNL_EXEC "$test_file" >"$output_file" 2>./valgrind.log
	if [ $? -ne 0 ]; then
		echo -e "[Valgrind] ${RED}KO${NC}"
		cat ./valgrind.log
	else
		echo -e "[Valgrind] ${GREEN}OK${NC}"
	fi
	rm ./valgrind.log
	actual_output=$(cat "$output_file")
	if [[ "$actual_output" == "$expected_output" ]]; then
		echo -e "[$test_name] ${GREEN}OK${NC}"
	else
		echo - "[$test_name] ${RED}KO${NC}!"
		echo "Expected:"
		echo -e "$expected_output" | od -c
		echo "Got:"
		echo -e "$actual_output" | od -c
	fi
	rm -f "$test_file" "$output_file"
}

run_stdin_test() {
	local test_name=$1
	local test_content=$2
	local expected_output=$3

	local test_file="test_${test_name}.txt"
	local output_file="output_${test_name}.txt"

	printf "%s" "$test_content" >"$test_file"

	echo -e $test_content | valgrind --leak-check=full --error-exitcode=1 ./$GNL_EXEC "$test_file" >"$output_file" 2>./valgrind.log
	if [ $? -ne 0 ]; then
		echo -e "[Valgrind] ${RED}KO${NC}"
		cat ./valgrind.log
	else
		echo -e "[Valgrind] ${GREEN}OK${NC}"
	fi
	rm ./valgrind.log
	actual_output=$(cat "$output_file")
	if [[ "$actual_output" == "$expected_output" ]]; then
		echo -e "[$test_name] ${GREEN}OK${NC}"
	else
		echo - "[$test_name] ${RED}KO${NC}!"
		echo "Expected:"
		echo -e "$expected_output" | od -c
		echo "Got:"
		echo -e "$actual_output" | od -c
	fi

	rm -f "$test_file" "$output_file"
}

run_neg_fd_test() {
	output=$(valgrind --leak-check=full --error-exitcode=1 ./$GNL_EXEC neg_fd 2>valgrind_neg_fd.log)
	if [ -z "$output" ]; then
		echo -e "[Negative FD] ${GREEN}OK${NC}"
	else
		echo -e "[Negative FD] ${RED}KO${NC}"
		echo "Expected empty output but got:"
		echo "$output"
	fi

	if [ -s valgrind_neg_fd.log ]; then
		if grep -q "definitely lost" valgrind_neg_fd.log; then
			echo -e "[Valgrind] ${RED}Memory leak detected!${NC}"
			cat valgrind_neg_fd.log
		else
			echo -e "[Valgrind] ${GREEN}OK${NC}"
			rm -f valgrind_neg_fd.log
		fi
	else
		echo -e "[Valgrind] ${GREEN}OK${NC}"
		rm -f valgrind_neg_fd.log 2>/dev/null
	fi
}

run_too_big_fd_test() {
	output=$(valgrind --leak-check=full --error-exitcode=1 ./$GNL_EXEC too_big_fd 2>valgrind_neg_fd.log)
	if [ -z "$output" ]; then
		echo -e "[Too big FD] ${GREEN}OK${NC}"
	else
		echo -e "[Too big FD] ${RED}KO${NC}"
		echo "Expected empty output but got:"
		echo "$output"
	fi

	if [ -s valgrind_neg_fd.log ]; then
		if grep -q "definitely lost" valgrind_neg_fd.log; then
			echo -e "[Valgrind] ${RED}Memory leak detected!${NC}"
			cat valgrind_neg_fd.log
		else
			echo -e "[Valgrind] ${GREEN}OK${NC}"
			rm -f valgrind_neg_fd.log
		fi
	else
		echo -e "[Valgrind] ${GREEN}OK${NC}"
		rm -f valgrind_neg_fd.log 2>/dev/null
	fi
}

run_closed_fd_test() {
	output=$(valgrind --leak-check=full --error-exitcode=1 ./$GNL_EXEC closed_fd 2>valgrind_neg_fd.log)
	if [ -z "$output" ]; then
		echo -e "[Closed FD] ${GREEN}OK${NC}"
	else
		echo -e "[Closed FD] ${RED}KO${NC}"
		echo "Expected empty output but got:"
		echo "$output"
	fi

	if [ -s valgrind_neg_fd.log ]; then
		if grep -q "definitely lost" valgrind_neg_fd.log; then
			echo -e "[Valgrind] ${RED}Memory leak detected!${NC}"
			cat valgrind_neg_fd.log
		else
			echo -e "[Valgrind] ${GREEN}OK${NC}"
			rm -f valgrind_neg_fd.log
		fi
	else
		echo -e "[Valgrind] ${GREEN}OK${NC}"
		rm -f valgrind_neg_fd.log 2>/dev/null
	fi
}

if [ -f "$LOG" ]; then
	rm "$LOG"
fi

clear

echo -e "${YELLOW}The evaluation is about to start.${NC}"

read -p "$(printf "${YELLOW}Do you want to evaluate the bonus part? (y/n): ${NC}")" answer

echo -n "Checking if mandatory files exist... "
for f in "${MANDATORY_FILES[@]}"; do
	if [ -f "$f" ]; then
		echo "File '$f' is found." >>"$LOG"
	else
		echo "File '$f' does not exist." >>"$LOG"
		echo -e "${RED}KO.${NC}"
		echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
		exit 1
	fi
done
echo -e "${GREEN}OK.${NC}"

echo -n "Checking with norminette... "
for f in "${MANDATORY_FILES[@]}"; do
	norminette -R CheckForbiddenSourceHeader "$f" >>"$LOG" | grep -q "Error"
	if [ $? -eq 0 ]; then
		echo -e "${RED}KO.${NC}"
		echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
		exit 1
	fi
done
echo -e "${GREEN}OK.${NC}"

echo "int main(void) { return 0; }" >"$MAIN_EMPTY"

echo -n "Compiling main part... "
cc -Wall -Wextra -Werror get_next_line.c get_next_line_utils.c "$MAIN_EMPTY" -o a.out
rm -f "$MAIN_EMPTY"
if [ ! -f "a.out" ]; then
	exit 1
fi
echo -e "${GREEN}OK.${NC}"
echo -n "Checking for forbidden functions... "
UNDEFINED_SYMBOLS=$(nm a.out | grep ' U ' | awk '{ print $2 }')
for s in $UNDEFINED_SYMBOLS; do
	FUNC_NAME=${s%@*}
	CLEAR=false
	for f in "${ALLOWED_FUNCTIONS[@]}"; do
		if [[ "$FUNC_NAME" == "$f" ]]; then
			CLEAR=true
			break
		fi
	done
	if ! $CLEAR; then
		echo -e "${RED}KO.${NC}"
		echo "Forbidden function $FUNC_NAME." >>${LOG}
		echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
		rm "a.out"
		exit 1
	fi
done
rm "a.out"
echo -e "${GREEN}OK.${NC}"

############################################################     BUFFER_SIZE = 1       ####################################################################

echo -e "${YELLOW}Testing get_next_line with BUFFER_SIZE=1...${NC}"
cc -Wall -Wextra -Werror -g -D BUFFER_SIZE=1 get_next_line.c get_next_line_utils.c mandatory.c -o a.out

run_neg_fd_test
run_too_big_fd_test
run_closed_fd_test
run_test "Empty file" "" ""
run_test "Only new line" "\n" "\n"
run_test "41 no new line" "$(printf '=%.0s' {1..41})" "$(printf '=%.0s' {1..41})"
run_test "41 new line" "$(printf '=%.0s' {1..41})"$'\n' "$(printf '=%.0s' {1..41})"
run_test "42 no new line" "$(printf '=%.0s' {1..42})" "$(printf '=%.0s' {1..42})"
run_test "42 new line" "$(printf '=%.0s' {1..42})"$'\n' "$(printf '=%.0s' {1..42})"
run_test "43 no new line" "$(printf '=%.0s' {1..43})" "$(printf '=%.0s' {1..43})"
run_test "43 new line" "$(printf '=%.0s' {1..43})"$'\n' "$(printf '=%.0s' {1..43})"
run_test "Multiple new line x5" "\n\n\n\n\n" "\n\n\n\n\n"
run_test "Multiple lines no new line" $'Line1\nLine2\nLine3' $'Line1\nLine2\nLine3'
run_test "Multiple lines with new line" $'Line1\nLine2\nLine3\n' $'Line1\nLine2\nLine3'
run_test "Alternate line new line no new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "Alternate line new line with new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5\n' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "big line no new line" "$(printf '=%.0s' {1..10000})" "$(printf '=%.0s' {1..10000})"
run_test "big line new line" "$(printf '=%.0s' {1..10000})"$'\n' "$(printf '=%.0s' {1..10000})"
run_stdin_test "stdin" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'

############################################################     BUFFER_SIZE = 42       ####################################################################

echo -e "${YELLOW}Testing get_next_line with BUFFER_SIZE=42...${NC}"
cc -Wall -Wextra -Werror -g -D BUFFER_SIZE=42 get_next_line.c get_next_line_utils.c mandatory.c -o a.out

run_neg_fd_test
run_too_big_fd_test
run_closed_fd_test
run_test "Empty file" "" ""
run_test "Only new line" "\n" "\n"
run_test "41 no new line" "$(printf '=%.0s' {1..41})" "$(printf '=%.0s' {1..41})"
run_test "41 new line" "$(printf '=%.0s' {1..41})"$'\n' "$(printf '=%.0s' {1..41})"
run_test "42 no new line" "$(printf '=%.0s' {1..42})" "$(printf '=%.0s' {1..42})"
run_test "42 new line" "$(printf '=%.0s' {1..42})"$'\n' "$(printf '=%.0s' {1..42})"
run_test "43 no new line" "$(printf '=%.0s' {1..43})" "$(printf '=%.0s' {1..43})"
run_test "43 new line" "$(printf '=%.0s' {1..43})"$'\n' "$(printf '=%.0s' {1..43})"
run_test "Multiple new line x5" "\n\n\n\n\n" "\n\n\n\n\n"
run_test "Multiple lines no new line" $'Line1\nLine2\nLine3' $'Line1\nLine2\nLine3'
run_test "Multiple lines with new line" $'Line1\nLine2\nLine3\n' $'Line1\nLine2\nLine3'
run_test "Alternate line new line no new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "Alternate line new line with new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5\n' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "big line no new line" "$(printf '=%.0s' {1..10000})" "$(printf '=%.0s' {1..10000})"
run_test "big line new line" "$(printf '=%.0s' {1..10000})"$'\n' "$(printf '=%.0s' {1..10000})"
run_stdin_test "stdin" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'

############################################################     BUFFER_SIZE = 10000000       ####################################################################

echo -e "${YELLOW}Testing get_next_line with BUFFER_SIZE=10000000...${NC}"
cc -Wall -Wextra -Werror -g -D BUFFER_SIZE=42 get_next_line.c get_next_line_utils.c mandatory.c -o a.out

run_neg_fd_test
run_too_big_fd_test
run_closed_fd_test
run_test "Empty file" "" ""
run_test "Only new line" "\n" "\n"
run_test "41 no new line" "$(printf '=%.0s' {1..41})" "$(printf '=%.0s' {1..41})"
run_test "41 new line" "$(printf '=%.0s' {1..41})"$'\n' "$(printf '=%.0s' {1..41})"
run_test "42 no new line" "$(printf '=%.0s' {1..42})" "$(printf '=%.0s' {1..42})"
run_test "42 new line" "$(printf '=%.0s' {1..42})"$'\n' "$(printf '=%.0s' {1..42})"
run_test "43 no new line" "$(printf '=%.0s' {1..43})" "$(printf '=%.0s' {1..43})"
run_test "43 new line" "$(printf '=%.0s' {1..43})"$'\n' "$(printf '=%.0s' {1..43})"
run_test "Multiple new line x5" "\n\n\n\n\n" "\n\n\n\n\n"
run_test "Multiple lines no new line" $'Line1\nLine2\nLine3' $'Line1\nLine2\nLine3'
run_test "Multiple lines with new line" $'Line1\nLine2\nLine3\n' $'Line1\nLine2\nLine3'
run_test "Alternate line new line no new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "Alternate line new line with new line" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5\n' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'
run_test "big line no new line" "$(printf '=%.0s' {1..10000})" "$(printf '=%.0s' {1..10000})"
run_test "big line new line" "$(printf '=%.0s' {1..10000})"$'\n' "$(printf '=%.0s' {1..10000})"
run_stdin_test "stdin" $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5' $'Line1\n\nLine2\n\nLine3\n\nLine4\n\nLine5'

if [[ "$answer" =~ ^[Yy]$ ]]; then
	echo -n "Checking if bonus files exist... "
	for f in "${BONUS_FILES[@]}"; do
		if [ -f "$f" ]; then
			echo "File '$f' is found." >>"$LOG"
		else
			echo "File '$f' does not exist." >>"$LOG"
			echo -e "${RED}KO.${NC}"
			echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
			exit 1
		fi
	done
	echo -e "${GREEN}OK.${NC}"
	echo -n "Checking with norminette... "
	for f in "${BONUS_FILES[@]}"; do
		norminette -R CheckForbiddenSourceHeader "$f" >>"$LOG" | grep -q "Error"
		if [ $? -eq 0 ]; then
			echo -e "${RED}KO.${NC}"
			echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
			exit 1
		fi
	done
	echo -e "${GREEN}OK.${NC}"

	echo "int main(void) { return 0; }" >"$MAIN_EMPTY"

	echo -n "Compiling bonus part... "
	cc -Wall -Wextra -Werror get_next_line_bonus.c get_next_line_utils_bonus.c "$MAIN_EMPTY" -o a.out
	rm -f "$MAIN_EMPTY"
	if [ ! -f "a.out" ]; then
		exit 1
	fi
	echo -e "${GREEN}OK.${NC}"
	echo -n "Checking for forbidden functions... "
	UNDEFINED_SYMBOLS=$(nm a.out | grep ' U ' | awk '{ print $2 }')
	for s in $UNDEFINED_SYMBOLS; do
		FUNC_NAME=${s%@*}
		CLEAR=false
		for f in "${ALLOWED_FUNCTIONS[@]}"; do
			if [[ "$FUNC_NAME" == "$f" ]]; then
				CLEAR=true
				break
			fi
		done
		if ! $CLEAR; then
			echo -e "${RED}KO.${NC}"
			echo "Forbidden function $FUNC_NAME." >>${LOG}
			echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
			rm "a.out"
			exit 1
		fi
	done
	rm "a.out"
	echo -e "${GREEN}OK.${NC}"
else
	echo -e "${YELLOW}Skipping bonus evaluation.${NC}"
fi

echo -e "${YELLOW}Evaluation complete. See $LOG for details.${NC}"
