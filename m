From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 3/3] Restore open pipes
Date: Mon, 02 Feb 2009 19:02:57 -0500
Message-ID: <498789B1.80601@cs.columbia.edu>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>	<1233091395-24582-5-git-send-email-orenl@cs.columbia.edu>
	<87k5887n16.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k5887n16.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> +/* restore a pipe */
> OL> +static int
> OL> +cr_read_fd_pipe(struct cr_ctx *ctx, struct cr_hdr_fd_data *hh, int rparent)
> OL> +{
> OL> +	struct file *file;
> OL> +	int fds[2], which, ret;
> OL> +
> OL> +	file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
> OL> +	if (IS_ERR(file))
> OL> +		return PTR_ERR(file);
> OL> +	else if (file)
> OL> +		return cr_attach_get_file(file);
> OL> +
> OL> +	/* first encounter of this pipe: create it */
> OL> +	ret = do_pipe(fds);

point (1)

> OL> +	if (ret < 0)
> OL> +		return ret;
> OL> +
> OL> +	which = (hh->f_flags & O_WRONLY ? 1 : 0);

point (2)

> OL> +
> OL> +	/*
> OL> +	 * Below we return the fd corersponding to one side of the pipe
> OL> +	 * for our caller to use. Now register the other side of the pipe
> OL> +	 * in the hash, to be picked up when that side is to be restored.
> OL> +	 */
> OL> +	file = cr_obj_add_file(ctx, fds[1-which], hh->fd_objref);
> OL> +	if (IS_ERR(file)) {
> OL> +		ret = PTR_ERR(file);
> OL> +		goto out;
> OL> +	}

point (3)

> OL> +
> OL> +	ret = cr_read_pipe(ctx, fds[which]);
> OL> + out:
> OL> +	sys_close(fds[1-which]);	/* this side isn't used anymore */

point (4)

> 
> This isn't always a valid thing to do, right?  I can think of two
> scenarios off the top of my head that will break here:
> 
> 1. The process has called pipe() but has not yet fork()'d
> 2. The process is using both sides of a pipe for a select()-based
>    event loop

In both scenarios, both ends of the pipes belong to a single process (and
only to it). Let's assume we restore the 'write' end first:

(1) we create the pipe (both ends)
(2) @which should be "1"
(3) we register the read-end file pointer (1-@which) in the objhash
(4) we close the file descriptor

At this point, the read end of the pipe should remain alive, because it
was put in the objhash and a reference was kept to it.

Some time later (probably when we process the next fd) we'll hit the
other end of the pipe, and we'll install it as is by taking the file
pointer from the objhash and attaching it to a new (empty) fd.

> 
> I worked up a quick test for #1, and it dies immediately on restart
> with a SIGPIPE.
> 

So the implementation of the logic above is ... inaccurate :(
I can reproduce it here; will take a closer look at it soon.

> I'll see if I can work up and post a patch to fix this if I can come
> up with something I think is reasonable.

Thanks,

Oren.
