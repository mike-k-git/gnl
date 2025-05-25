#include "get_next_line.h"

int main(void)
{
	int fd = open("test_input.txt", O_RDONLY);
	get_next_line(fd);
	get_next_line(fd);
	get_next_line(fd);
	return (0);
}
