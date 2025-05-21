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

char	*get_next_line(int fd)
{
	char			*output;
	size_t			bytes_read;
	char			buf[BUFFER_SIZE];
	ssize_t			i;

	if (fd < 0)
		return (NULL);
	output = (char *)malloc(sizeof(char) * BUFFER_SIZE);
	if (!output)
		return (NULL);
	bytes_read = 0;
	while (1)
	{
		while (bytes_read < BUFFER_SIZE)
		{
			i = read(fd, &buf[bytes_read], 1);
			{
				if (i < 0)
				{
					if (output)
						free(output);
					return (NULL);
				}
				return (output);
			}
			bytes_read++;
		}
		return (output);
	}
}
/*
int	main(void)
{
	char	*line2 = get_next_line(1000);
	printf("1000 ID: %s\n", line2);
	
	int	fd = open("empty.txt", O_RDONLY);
	char	*line1 = get_next_line(fd);
	printf("Empty file: %s\n", line1);
	close(fd);
}*/
