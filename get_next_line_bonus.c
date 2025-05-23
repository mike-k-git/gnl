/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_bonus.c                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mkugan <mkugan@student.42berlin.de>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/20 17:52:15 by mkugan            #+#    #+#             */
/*   Updated: 2025/05/23 19:49:41 by mkugan           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "get_next_line_bonus.h"

char	*append_to_store(char *store_fd, char *buf, ssize_t bytes_read)
{
	char	*new_store_fd;
	size_t	store_fd_len;

	store_fd_len = ft_strlen(store_fd);
	new_store_fd = malloc(sizeof(char) * (store_fd_len + bytes_read + 1));
	if (!new_store_fd)
	{
		free(store_fd);
		store_fd = NULL;
		return (NULL);
	}
	if (store_fd)
		ft_strlcpy(new_store_fd, store_fd, store_fd_len + 1);
	else
		new_store_fd[0] = '\0';
	ft_strlcat(new_store_fd, buf, store_fd_len + bytes_read + 1);
	free(store_fd);
	store_fd = NULL;
	return (new_store_fd);
}

char	*reallocate_store(char *store_fd, char *new_line)
{
	char	*new_store_fd;
	size_t	len_till_new_line;

	len_till_new_line = ft_strlen(new_line + 1);
	new_store_fd = malloc(sizeof(char) * (len_till_new_line + 1));
	if (!new_store_fd)
	{
		free(store_fd);
		store_fd = NULL;
		return (NULL);
	}
	ft_strlcpy(new_store_fd, new_line + 1, len_till_new_line + 1);
	free(store_fd);
	store_fd = NULL;
	return (new_store_fd);
}

void	split_and_return(char **store_fd, char **output, char **buf)
{
	char	*new_line;

	new_line = ft_strchr(*store_fd, '\n');
	if (new_line)
	{
		*output = malloc(sizeof(char) * (new_line - *store_fd + 2));
		if (!*output)
		{
			free(*store_fd);
			*store_fd = NULL;
			free(*buf);
			*buf = NULL;
			return ;
		}
		ft_strlcpy(*output, *store_fd, new_line - *store_fd + 2);
		*store_fd = reallocate_store(*store_fd, new_line);
		if (!*store_fd)
		{
			free(*output);
			*output = NULL;
		}
		free(*buf);
		*buf = NULL;
	}
}

int	read_into_buffer(int fd, char **buf, char **store_fd, char **output)
{
	ssize_t	bytes_read;

	bytes_read = read(fd, *buf, BUFFER_SIZE);
	if (bytes_read <= 0)
	{
		free(*buf);
		*buf = NULL;
		if (bytes_read == 0 && *store_fd && **store_fd)
		{
			*output = *store_fd;
			*store_fd = NULL;
			return (0);
		}
		free(*store_fd);
		*store_fd = NULL;
		return (-1);
	}
	(*buf)[bytes_read] = '\0';
	*store_fd = append_to_store(*store_fd, *buf, bytes_read);
	if (!*store_fd)
	{
		free(*buf);
		return (-1);
	}
	return (1);
}

char	*get_next_line(int fd)
{
	static char		*store[FD_MAX];
	char			*output;
	char			*buf;
	int				status;

	if (!init(&output, &store[fd], &buf, fd))
		return (NULL);
	while (1)
	{
		split_and_return(&store[fd], &output, &buf);
		if (output && *output)
			return (output);
		bytes_read = 0;
		status = read_into_buffer(fd, &buf, &store[fd], &output);
		if (status == 0)
			return (output);
		if (status == -1)
			return (NULL);
	}
}
