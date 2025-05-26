/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   malloc_wrap.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mkugan <mkugan@student.42berlin.de>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 16:09:04 by mkugan            #+#    #+#             */
/*   Updated: 2025/05/26 16:11:44 by mkugan           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

/*
 * Original malloc and free, will be mapped at link time using --wrap
 */
void	*__real_malloc(size_t size);
void	__real_free(void *ptr);

/*
 * Optional: Set a predictable random seed using an env var or current time.
 * This runs before `main()` automatically due to constructor attribute.
 */
__attribute__((constructor))
static void	init_seed(void)
{
	if(atoi(getenv("MALLOC_SEED")))
		srand(atoi(getenv("MALLOC_SEED")));
	else
		srand(time(NULL));
}

/*
 * Malloc wrapper with random failure
 */
void	*__wrap_malloc(size_t size)
{
	void	*ptr;

	if (rand() % 42)
		ptr = __real_malloc(size);
	else
		ptr = NULL;
	dprintf(2, "malloc(%zu) = %p\n", size, ptr);
	return (ptr);
}

/*
 * Free wrapper for logging
 */
void	__wrap_free(void *ptr)
{
	__real_free(ptr);
	dprintf(2, "free(%p)\n", ptr);
}
