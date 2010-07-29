From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: user-cr thread safety
Date: Thu, 29 Jul 2010 10:56:13 -0400
Message-ID: <4C51968D.3000301@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280169472.7875.4290.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Nathan,

Thanks for pointing this out. A couple of comments:

1) The separate fd-table between the coordinator and the feeder
is just a convenience and can be relatively easily relaxed so
that pthreads may be used. However, ...

2) More importantly, malloc() and printf() also occur in the
processes and threads generated during the creation of the new
(restored) task tree. So the same problems may occur there as
well. Unfortunately, here we can't use glibc, in part because
it is not even supported by glibc.

Maybe a more robust way to address this is to: (1) use mmap()
and munmap() instead of malloc() and free(), and also (2) use
sprintf() + write() instead of printf().
That should make everything thread-safe. Did you notice other
libc calls which may be problematic ?

Oren.


Nathan Lynch wrote:
> user-cr's restart program creates a thread to pipe the checkpoint image
> into the sys_restart file descriptor.  This is a thread created with
> clone(2) and it shares its address space with the coordinator.
> 
> While glibc has internal mechanisms to ensure thread safety, these work
> only with threads that were created using glibc/pthread interfaces.
> clone(2) bypasses the housekeeping that glibc does to track threads.  It
> is not safe to call e.g. malloc or printf from the feeder thread.
> 
> The behavior I've been seeing is that restart will occasionally abort,
> crash, or sleep indefinitely (with both the coordinator and feeder
> threads waiting forever on the same futex) - before restart(2) or
> eclone(2) are ever called.
> 
> I have tried patching user-cr to create the feeder thread with
> pthread_create, but it's not trivial -- I think the program's correct
> functioning depends heavily on the threads having separate file
> descriptor tables.
> 
> The best I can come up with right now is to allocate ckpt_msg's buffer
> on the stack - I think this avoids most if not all of the concurrent
> malloc activity associated with the crashes/hangs I've been seing.
> 
>  common.h |   16 ++++++----------
>  1 files changed, 6 insertions(+), 10 deletions(-)
> 
> diff --git a/common.h b/common.h
> index 99b224d..927b146 100644
> --- a/common.h
> +++ b/common.h
> @@ -1,25 +1,21 @@
>  #include <stdio.h>
>  #include <signal.h>
>  
> -#define BUFSIZE  (4 * 4096)
> +#define BUFSIZE  (4096)
>  
>  static inline void ckpt_msg(int fd, char *format, ...)
>  {
> +	char buf[BUFSIZE] = { '\0' };
>  	va_list ap;
> -	char *bufp;
> +
>  	if (fd < 0)
>  		return;
>  
>  	va_start(ap, format);
> -
> -	bufp = malloc(BUFSIZE);
> -	if(bufp) {
> -		vsnprintf(bufp, BUFSIZE, format, ap);
> -		write(fd, bufp, strlen(bufp));
> -	}
> -	free(bufp);
> -
> +	vsnprintf(buf, BUFSIZE, format, ap);
>  	va_end(ap);
> +
> +	write(fd, buf, strlen(buf));
>  }
>  
>  #define ckpt_perror(s) 							\
> 
> 
> 
