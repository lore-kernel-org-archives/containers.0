From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 2/3] Checkpoint open pipes
Date: Thu, 05 Feb 2009 10:45:55 +0100
Message-ID: <498AB553.3090902@fr.ibm.com>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
	<1233091395-24582-4-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233091395-24582-4-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

>  
> +/* cr_write_pipebuf - dump contents of a pipe/fifo (assume i_mutex taken) */
> +static int cr_write_pipebuf(struct cr_ctx *ctx, struct pipe_inode_info *pipe)
> +{
> +	struct cr_hdr h;
> +	void *kbuf, *addr;
> +	int i, ret = 0;
> +
> +	kbuf = (void *) __get_free_page(GFP_KERNEL);

this can sleep and inode->i_mutex is locked.

> +	if (!kbuf)
> +		return -ENOMEM;
> +
> +	/* this is a simplified fs/pipe.c:read_pipe() */
> +
> +	for (i = 0; i < pipe->nrbufs; i++) {
> +		int nn = (pipe->curbuf + i) & (PIPE_BUFFERS-1);
> +		struct pipe_buffer *pbuf = pipe->bufs + nn;
> +		const struct pipe_buf_operations *ops = pbuf->ops;
> +
> +		ret = ops->confirm(pipe, pbuf);
> +		if (ret < 0)
> +			break;
> +
> +		addr = ops->map(pipe, pbuf, 1);
> +		memcpy(kbuf, addr + pbuf->offset, pbuf->len);
> +		ops->unmap(pipe, pbuf, addr);
> +
> +		h.type = CR_HDR_BUFFER;
> +		h.len = pbuf->len;
> +		h.parent = 0;
> +
> +		ret = cr_write_obj(ctx, &h, kbuf);

same here.
 
> +		if (ret < 0)
> +			break;
> +	}
> +
> +	free_page((unsigned long) kbuf);
> +	return ret;
> +}

I think that cr_write_pipebuf() should be a service from fs/pipe.c. It
exposes a lot of pipe internals.

a 'dump' and 'restore' inode operations might be could solution to the
general problem of dumping and restoring inode contents. other file types
will have similar needs. 

C.
