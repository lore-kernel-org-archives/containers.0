From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
Date: Tue, 16 Dec 2008 11:04:40 -0800
Message-ID: <4947FBC8.2000601__10037.935866467$1229454907$gmane$org@google.com>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	<1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1228498282-11804-4-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linux Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:

> +/*
> + * Helpers to write(read) from(to) kernel space to(from) the checkpoint
> + * image file descriptor (similar to how a core-dump is performed).
> + *
> + *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
> + *   cr_kread() - read from the checkpoint image to a kernel-space buffer
> + */
> +
> +int cr_kwrite(struct cr_ctx *ctx, void *addr, int count)
> +{
> +	struct file *file = ctx->file;
> +	mm_segment_t fs;
> +	ssize_t nwrite;
> +	int nleft;
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	for (nleft = count; nleft; nleft -= nwrite) {
> +		nwrite = file->f_op->write(file, addr, nleft, &file->f_pos);
> +		if (nwrite < 0) {
> +			if (nwrite == -EAGAIN)
> +				nwrite = 0;
> +			else

set_fs(fs) here

> +				return nwrite;
> +		}
> +		addr += nwrite;
> +	}
> +	set_fs(fs);
> +	ctx->total += count;
> +	return 0;
> +}
> +
> +int cr_kread(struct cr_ctx *ctx, void *addr, int count)
> +{
> +	struct file *file = ctx->file;
> +	mm_segment_t fs;
> +	ssize_t nread;
> +	int nleft;
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	for (nleft = count; nleft; nleft -= nread) {
> +		nread = file->f_op->read(file, addr, nleft, &file->f_pos);
> +		if (nread <= 0) {
> +			if (nread == -EAGAIN) {
> +				nread = 0;
> +				continue;
> +			} else if (nread == 0)
> +				nread = -EPIPE;		/* unexecpted EOF */

set_fs(fs) here as well

> +			return nread;
> +		}
> +		addr += nread;
> +	}
> +	set_fs(fs);
> +	ctx->total += count;
> +	return 0;
> +}
> +
