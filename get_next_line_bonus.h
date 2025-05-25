/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_bonus.h                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mkugan <mkugan@student.42berlin.de>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/20 17:52:49 by mkugan            #+#    #+#             */
/*   Updated: 2025/05/23 19:14:01 by mkugan           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef GET_NEXT_LINE_BONUS_H
# define GET_NEXT_LINE_BONUS_H

# include <unistd.h>
# include <stdlib.h>
# include <fcntl.h>

char	*get_next_line(int fd);
char	*append_to_store(char *s, char *b, ssize_t r);
char	*reallocate_store(char *s, char *nl);
void	split_and_return(char **s, char **o, char **b);
int		read_into_buffer(int fd, char **b, char **s, char **o);
size_t	ft_strlen(const char *s);
char	*ft_strchr(const char *s, int c);
int		init(char **o, char **s, char **b, int fd);
void	copy_n(char *dest, char *src, size_t n);

# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 42
# endif

# define FD_MAX 1024

#endif
