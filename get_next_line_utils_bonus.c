/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_utils_bonus.c                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mkugan <mkugan@student.42berlin.de>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/20 17:52:37 by mkugan            #+#    #+#             */
/*   Updated: 2025/05/23 19:50:05 by mkugan           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "get_next_line_bonus.h"

char	*ft_strchr(const char *s, int c)
{
	while (*s)
	{
		if ((unsigned char)*s == (char)c)
			return ((char *)s);
		s++;
	}
	if ((unsigned char)*s == (char)c)
		return ((char *)s);
	return (NULL);
}

void	copy_n(char *dest, char *src, size_t n)
{
	size_t	i;

	i = 0;
	while (i < n)
	{
		dest[i] = src[i];
		i++;
	}
}

size_t	ft_strlen(const char *s)
{
	size_t	i;

	i = 0;
	while (*s++)
		i++;
	return (i);
}

int	init(char **output, char **store_fd, char **buf, int fd)
{
	if (BUFFER_SIZE <= 0 || fd < 0 || fd >= FD_MAX)
		return (0);
	*output = NULL;
	if (!*store_fd)
	{
		*store_fd = malloc(1);
		if (*store_fd)
			(*store_fd)[0] = '\0';
		else
			return (0);
	}
	*buf = malloc(sizeof(char) * (BUFFER_SIZE + 1));
	if (!*buf)
	{
		free(*store_fd);
		*store_fd = NULL;
		return (0);
	}
	return (1);
}
