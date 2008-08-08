From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Fri, 8 Aug 2008 11:46:54 +0200
Message-ID: <200808081146.54834.arnd__26456.6155187369$1218189138$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <20080807224034.735B1F84@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224034.735B1F84@kernel>
Content-Disposition: inline
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

On Friday 08 August 2008, Dave Hansen wrote:
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
> +	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
> +	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
> +	hh->patch = (LINUX_VERSION_CODE) & 0xff;
> +
> +	hh->version = 1;
> +
> +	hh->flags = ctx->flags;
> +	hh->time = ktv.tv_sec;
> +
> +	return cr_write_obj(ctx, &h, hh);
> +}

Do you rely on the kernel version in order to determine the format
of the binary data, or is it just informational?

If you think the format can change in incompatible ways, you
probably need something more specific than the version number
these days, because there are just so many different trees with
the same numbers.


> +
> +/* debugging */
> +#if 0
> +#define CR_PRINTK(str, args...)  \
> +	printk(KERN_ERR "cr@%s#%d: " str, __func__, __LINE__, ##args)
> +#else
> +#define CR_PRINTK(...)		do {} while (0)
> +#endif
> +

Please use the existing pr_debug and dev_debug here, instead of creating
yet another version.

> +struct cr_hdr_tail {
> +	__u32 magic;
> +	__u32 cksum[2];
> +};

This structure has an odd multiple of 32-bit members, which means
that if you put it into a larger structure that also contains
64-bit members, the larger structure may get different alignment
on x86-32 and x86-64, which you might want to avoid.
I can't tell if this is an actual problem here.

> +
> +struct cr_hdr_task {
> +	__u64 state;
> +	__u32 exit_state;
> +	__u32 exit_code, exit_signal;
> +
> +	__u16 pid;
> +	__u16 tgid;
> +
> +	__u64 utime, stime, utimescaled, stimescaled;
> +	__u64 gtime;
> +	__u64 prev_utime, prev_stime;
> +	__u64 nvcsw, nivcsw;
> +	__u64 start_time_sec, start_time_nsec;
> +	__u64 real_start_time_sec, real_start_time_nsec;
> +	__u64 min_flt, maj_flt;
> +
> +	__s16 task_comm_len;
> +	char comm[TASK_COMM_LEN];
> +};

In this case, I'm pretty sure that sizeof(cr_hdr_task) on x86-32 is
different from x86-64, since it will be 32-bit aligned on x86-32.

> +
> +/*
> + * During restart the code reads in data from the chekcpoint image into a
> + * temporary buffer (ctx->hbuf). Because operations can be nested, one
> + * should call cr_hbuf_get() to reserve space in the buffer, and then
> + * cr_hbuf_put() when it no longer needs that space
> + */
> +
> +#include <linux/version.h>
> +#include <linux/sched.h>
> +#include <linux/file.h>
> +
> +#include "ckpt.h"
> +#include "ckpt_hdr.h"
> +
> +/**
> + * cr_hbuf_get - reserve space on the hbuf
> + * @ctx: checkpoint context
> + * @n: number of bytes to reserve
> + */
> +void *cr_hbuf_get(struct cr_ctx *ctx, int n)
> +{
> +	void *ptr;
> +
> +	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
> +	ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
> +	ctx->hpos += n;
> +	return ptr;
> +}

Can (ctx->hpos + n > CR_HBUF_TOTAL) be controlled by the input
data? If so, this is a denial-of-service attack.

> +
> +int cr_kwrite(struct cr_ctx *ctx, void *buf, int count)
> +{
> +	mm_segment_t oldfs;
> +	int ret;
> +
> +	oldfs = get_fs();
> +	set_fs(KERNEL_DS);
> +	ret = cr_uwrite(ctx, buf, count);
> +	set_fs(oldfs);
> +
> +	return ret;
> +}

get_fs()/set_fs() always feels a bit ouch, and this way you have
to use __force to avoid the warnings about __user pointer casts
in sparse.
I wonder if you can use splice_read/splice_write to get around
this problem.

> +	struct cr_ctx *ctx;
> +	struct file *file;
> +	int fput_needed;
> +	int ret;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +

Why do you need CAP_SYS_ADMIN for this? Can't regular users
be allowed to checkpoint/restart their own tasks?

> --- linux-2.6.git/Makefile~handle_a_single_task_with_private_memory_maps	2008-08-05 09:04:27.000000000 -0700
> +++ linux-2.6.git-dave/Makefile	2008-08-05 09:07:53.000000000 -0700
> @@ -611,7 +611,7 @@ export mod_strip_cmd
>  
>  
>  ifeq ($(KBUILD_EXTMOD),)
> -core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
> +core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ ckpt/
>  

The name 'ckpt' is a bit unobvious, how about naming it 'checkpoint' instead?

	Arnd <><
