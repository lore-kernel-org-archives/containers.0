From: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Mon, 11 Aug 2008 12:03:15 -0600
Message-ID: <20080811120315.4b3ba2c8__29188.3268663243$1218478121$gmane$org@bike.lwn.net>
References: <20080807224033.FFB3A2C1@kernel> <20080807224034.735B1F84@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224034.735B1F84@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

I'm trying to figure out this patch set...here's a few things which
have caught my eye in passing.

> +/**
> + * cr_get_fname - return pathname of a given file
> + * @file: file pointer
> + * @buf: buffer for pathname
> + * @n: buffer length (in) and pathname length (out)
> + *
> + * if the buffer provivded by the caller is too small, allocate a new
> + * buffer; caller should call cr_put_pathname() for cleanup
> + */
> +char *cr_get_fname(struct path *path, struct path *root, char *buf,
> int *n) +{
> +	char *fname;
> +
> +	fname = __d_path(path, root, buf, *n);
> +
> +	if (IS_ERR(fname) && PTR_ERR(fname) == -ENAMETOOLONG) {
> +		 if (!(buf = (char *) __get_free_pages(GFP_KERNEL, 0)))

This seems like a clunky and error-prone interface - why not just have it
allocate the memory always?  But, in this case, cr_get_fname() always seems
to be called with ctx->tbuf, which, in turn, is an order-1 allocation.
Here you're saying that if it's too small, you'll try replacing it with an
order-0 allocation instead.  I rather suspect that's not going to help.

> +/* write the checkpoint header */
> +static int cr_write_hdr(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_head *hh = ctx->tbuf;
> +	struct timeval ktv;
> +
> +	h.type = CR_HDR_HEAD;
> +	h.len = sizeof(*hh);
> +	h.id = 0;
> +
> +	do_gettimeofday(&ktv);
> +
> +	hh->magic = 0x00a2d200;

This magic number is hard-coded in a number of places.  Could it maybe
benefit from a macro, which, in turn, could maybe end up in linux/magic.h?

> +/* dump the task_struct of a given task */
> +static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)

This function is going to break every time somebody changes struct
task_struct.  I'm not quite sure how to prevent that.  I wonder if the
modversions stuff could somehow be employed to detect changes and make the
build fail?

> +/**
> + * sys_checkpoint - checkpoint a container
> + * @pid: pid of the container init(1) process
> + * @fd: file to which dump the checkpoint image
> + * @flags: checkpoint operation flags
> + */
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long
> flags) +{
> +	struct cr_ctx *ctx;
> +	struct file *file;
> +	int fput_needed;
> +	int ret;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;

Like others, I wondered why CAP_SYS_ADMIN was required here.  I *still*
wonder, though, how you'll ever be able to do restart without a privilege
check.  There must be a thousand ways to compromise a system by messing
with the checkpoint file.

> +	file = fget_light(fd, &fput_needed);
> +	if (!file)
> +		return -EBADF;

Should you maybe check for write access?  An attempt to overwrite a
read-only file won't succeed, but you could save a lot of work by just
failing it with a clear code here.  

What about the file position?  Perhaps there could be a good reason to
checkpoint a process into the middle of a file, don't know.

In general, I don't see a whole lot of locking going on.  Is it really
possible to save and restore memory without ever holding mmap_sem?

jon
