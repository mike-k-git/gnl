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


char	*clean(char *b, char *o, char *s, int eof)
{
	free(b);
	if (!eof)
		free(s);
	return (o);
}

char	*append_to_store(char *s, char *b, ssize_t r)
{
	char	*new;
	size_t	s_len;

	s_len = ft_strlen(s);
	new = malloc(sizeof(char) * (s_len + r + 1));
	if (!new)
	{
		free(s);
		return (NULL);
	}
	if (s)
		ft_strlcpy(new, s, s_len + 1);
	else
		new[0] = '\0';
	ft_strlcat(new, b, s_len + r + 1);
	free(s);
	return (new);
}

char	*reallocate_store(char *s, char *nl)
{
	char	*new;
	size_t	len;

	len = ft_strlen(nl + 1);
	new = malloc(sizeof(char) * (len + 1));
	if (!new)
	{
		free(s);
		return (NULL);
	}
	ft_strlcpy(new, nl + 1, len + 1);
	free(s);
	return (new);
}



char	*get_next_line(int fd)
{
	static char		*store;
	char			*output;
	ssize_t			bytes_read;
	char			*buf;
	char			*nl;

	output = NULL;
	if (fd < 0 || fd > 1024 || BUFFER_SIZE <= 0)
		return (NULL);
	buf = malloc(sizeof(char) * (BUFFER_SIZE + 1));
	if (!buf)
		return (NULL);
	if (!store)
	{
		store = malloc(1);
		if (!store)
			return (clean(buf, NULL, NULL, 0));
		store[0] = '\0';
	}
	while (1)
	{
		nl = ft_strchr(store, '\n');
		if (nl)
		{
			output = malloc(sizeof(char) * (nl - store + 2));
			if (!output)
				return (clean(buf, NULL, store, 0));
			ft_strlcpy(output, store, nl - store + 2);
			store = reallocate_store(store, nl);
			if (!store)
				return (clean(buf, output, NULL, 0));
			return (clean(buf, output, store, 1));
		}
		bytes_read = read(fd, buf, BUFFER_SIZE);
		if (bytes_read <= 0)
		{
			if (bytes_read == 0 && store && *store)
			{
				output = store;
				store = NULL;
				return (clean(buf, output, NULL, 1));
			}
			free(store);
			store = NULL;
			return (clean(buf, NULL, NULL, 0));
		}
		buf[bytes_read] = '\0';
		store = append_to_store(store, buf, bytes_read);
		if (!store)
			return (clean(buf, NULL, NULL, 0));
	}
	if (buf)
		free(buf);
	return (NULL);
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
	
	fd = open("41_no_nl.txt", O_RDONLY);
	line1 = get_next_line(fd);
	printf("41 no nl: %s\n", line1);
	close(fd);
	
	fd = open("41_with_nl.txt", O_RDONLY);
	line1 = get_next_line(fd);
	printf("41 with nl: %s", line1);
	line1 = get_next_line(fd);
	printf("41 with nl: %s", line1);
	line1 = get_next_line(fd);
	printf("41 with nl: %s", line1);
	close(fd);
}*/
