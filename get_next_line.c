/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mkugan <mkugan@student.42berlin.de>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/20 17:52:15 by mkugan            #+#    #+#             */
/*   Updated: 2025/05/20 17:53:43 by mkugan           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "get_next_line.h"
#include "stdio.h"

int	find

char	*get_next_line(int fd)
{
	char	*buf;
	ssize_t i;
	size_t bytes_read;

	if (fd < 0)
		return (NULL);
	bytes_read = 0;
	buf = malloc(sizeof(char) * BUFFER_SIZE + 1);
	if (!buf)
		return (NULL);
	while (1)
	{
		i = read(fd, buf, BUFFER_SIZE);
			if (i < 0)
				return (NULL);
		bytes_read += i;

		return (output);
	}
}

int	main(void)
{
	char	*line2 = get_next_line(1000);
	printf("1000 ID: %s\n", line2);
	
	int	fd = open("empty.txt", O_RDONLY);
	char	*line1 = get_next_line(fd);
	printf("Empty file: %s\n", line1);
	close(fd);
}
