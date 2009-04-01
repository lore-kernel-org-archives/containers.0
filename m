From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 18/29] Restore open pipes
Date: Wed, 1 Apr 2009 15:34:16 -0500
Message-ID: <20090401203416.GA26043@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-19-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-19-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> When seeing a CR_FD_PIPE file type, we create a new pipe and thus
> have two file pointers (read- and write- ends). We only use one of
> them, depending on which side was checkpointed first. We register the
> file pointer of the other end in the hash table, with the 'objref'
> given for this pipe from the checkpoint, deposited for later use. At
> this point we also restore the contents of the pipe buffers.
> 
> When the other end arrives, it will have file type CR_FD_OBJREF. We
> will then use the corresponding 'objref' to retrieve the file pointer
> from the hash table, and attach it to the process.
> 
> Note the difference from the checkpoint logic: during checkpoint we
> placed the _inode_ of the pipe in the hash table, while during restart
> we place the resulting _file_ in the hash table.
> 
> We restore the pipe contents we manually allocation and attaching
> buffers to the pipe; (alternatively we could read the data from the
> image file and then write it into the pipe, or use splice() syscall).
> 
> Changelog[v14]:
>   - Discard the 'h.parent' field
>   - Check whether calls to cr_hbuf_get() fail
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

...

> +/* restore a pipe */
> +static int cr_read_fd_pipe(struct cr_ctx *ctx, struct cr_hdr_file *hh)
> +{
> +	struct file *file;
> +	int fds[2], which, ret;
> +
> +	file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
> +	if (IS_ERR(file))
> +		return PTR_ERR(file);
> +	else if (file)
> +		return cr_attach_get_file(file);

I think the casual reader would be helped by a comment like:

	/*
	 * if cr_obj_get_by_ref returned a file, then one end
	 * of the pipe has been restored, so we have
	 * cr_attach_get_file() attach the other end to a new
	 * fd, and we return that fd.
	 */

> +
> +	/* first encounter of this pipe: create it */
> +	ret = do_pipe(fds);
> +	if (ret < 0)
> +		return ret;

thanks,
-serge
