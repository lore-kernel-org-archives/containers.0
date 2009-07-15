From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH] checkpoint/restart: Add support for epoll
Date: Wed, 15 Jul 2009 11:22:36 +0200
Message-ID: <4A5D9FDC.7000309@free.fr>
References: <20090714235405.GH5213@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090714235405.GH5213-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

On 07/15/2009 01:54 AM, Matt Helsley wrote:
>   Add checkpoint/restart support for epoll files. This is the minimum
>   support necessary to recreate the epoll item sets without any pending
>   events.
>
>   This is an RFC to show where I'm going with the patch and give an idea
>   of how much code I expect it will take. Compiles and boots on x86 but
>   I haven't tested it.
>
>   Caveats: Does not correctly support restoring epoll fds to epoll sets
> 	  as this requires some recursion detection/avoidance. See the
> 	  "TODO" that mentions deferqueues.

it all depends on the algorithm of C/R for files.

the 'contents', the watched fds in your case, of the 'struct file' should be
restored after all the struct files have been restored. you'll have the same
issue with other fd types.

Also,I think it it possible to add 2 epoll services providing get and set without
mixing the epoll code with C/R code. ugly, IHMO. something like :

	diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
	index f6856a5..b19b7a1 100644
	--- a/include/linux/eventpoll.h
	+++ b/include/linux/eventpoll.h
	@@ -49,6 +49,12 @@ struct epoll_event {
	        __u64 data;
	 } EPOLL_PACKED;
  
	+struct epoll_fd_event {
	+       int fd;
	+       struct file* file;
	+       struct epoll_event event;
	+} EPOLL_PACKED;
	+
	 #ifdef __KERNEL__
	
	 /* Forward declarations to avoid compiler errors */
	@@ -95,6 +101,9 @@ static inline void eventpoll_release(struct file *file)
	        eventpoll_release_file(file);
	 }
  
	+extern int eventpoll_get_events(int, struct epoll_fd_event *, int);
	+extern int eventpoll_insert(int, int, struct file*, struct epoll_event *);
	+
	 #else
	
	 static inline void eventpoll_init_file(struct file *file) {}

finally,


> +	/*
> +	 * FIXME for now we do it one at a time. Later we might do it like
> +	 * checkpoint_pids() for better performance since there can be many
> +	 * more epoll items than pids.
> +	 */
> +	cepi = ckpt_hdr_get(ctx, sizeof(*cepi));
> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> +		struct epitem *epi = rb_entry(rbp, struct epitem, rbn);
> +		cepi->fd = epi->ffd.fd;

epi->ffd.fd and epi->ffd.file are not necessarily related. fd could have been
recycled after the EPOLL_CTL_ADD. nop ? and it will break the restart.

C.
