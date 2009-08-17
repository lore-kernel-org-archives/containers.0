From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] user-cr: Extract kernel headers
Date: Mon, 17 Aug 2009 16:55:37 -0400
Message-ID: <4A89C3C9.8080905@librato.com>
References: <20090817152403.GA11415@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090817152403.GA11415-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> Using kernel headers directly from userspace is strongly discouraged.
> This patch attempts to sanitize kernel headers for userspace by
> extracting non-__KERNEL__ portions of the various checkpoint headers
> and placing them in a similar organization of userspace headers.
> 
> The script is run from the top level of the user-cr source tree like:
> 
> 	./scripts/extract-headers.sh -s <path-to-kern-source> -o ./include
> 
> 
> The patch includes a copy of the auto-generated headers and adjusts
> the user-cr programs to use them.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> TODO: Builds on i386. Probably needs more testing, especially on
> 	other non-i386, non-32-bit platforms.
> 
> 	Look at mergiing checkpoint_syscalls.h with checkpoint.h
> 	Or at least find a better, shorter name for checkpoint_syscalls.h

I suppose this will go away once the syscall numbers are accepted to
mainline and make it to the official (user space) headers ?

> 
> NOTES: The script is much larger (2.5x) than for cr_tests because cr_tests
> 	only required the syscall numbers and a few flags for the syscalls.
> 
> 	The headers have a similar organization to the kernel headers
> 	because struct ckpt_hdr must be defined before the arch hdrs and 
> 	yet CKPT_ARCH_NSIG must be defined before the generic signal hdrs.
> 	Plus it's easier to avoid rewriting the paths within the include
> 	directories...
> 
> 	checkpoint_syscalls.h is a multi-arch file with all the syscall
> 	numbers normally found in the arch's unistd.h. I chose to use a
> 	different name to avoid clashes with /usr/include headers.
> ---

[...]

> +CKPT_INCLUDE = -I./include
> +CKPT_HEADERS = $(shell find ./include -name '*.h')
>  
>  # compile with debug ?
>  DEBUG = -DCHECKPOINT_DEBUG
> @@ -39,6 +20,8 @@ OTHER = ckptinfo_types.c
>  
>  LDLIBS = -lm
>  
> +.PHONY: all distclean clean headers install
> +
>  all: $(PROGS)
>  	@make -C test
>  
> @@ -56,10 +39,16 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
>  
>  %.o:	%.c
>  
> +headers:
> +	./scripts/extract-headers.sh -s ../linux-2.6.git

Would be nice if this isn't hard-coded (perhaps an env-var ?)

> +
>  install:
>  	@echo /usr/bin/install -m 755 mktree ckpt rstr ckptinfo $(INSTALL_DIR)
>  	@/usr/bin/install -m 755 mktree ckpt rstr ckptinfo $(INSTALL_DIR)
>  
> +distclean: clean
> +	@rm -f $(CKPT_HEADERS)

Would 'make headers' be automagically called on the next 'make'
after the user does 'make distclean' ?

If not, then $(CKPT_HEADERS) will be empty and this will break the
dependencies of ckptinfo_types.c.

Oren.
