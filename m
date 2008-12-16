From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
Date: Tue, 16 Dec 2008 13:54:28 -0800
Message-ID: <49482394.10006__25906.4395715997$1229464728$gmane$org@google.com>
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
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 375129c..bd14ef9 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c

> +/*
> + * During checkpoint and restart the code writes outs/reads in data
> + * to/from the checkpoint image from/to a temporary buffer (ctx->hbuf).
> + * Because operations can be nested, use cr_hbuf_get() to reserve space
> + * in the buffer, then cr_hbuf_put() when you no longer need that space.
> + */

This seems a bit over-kill for buffer management no?  The only large 
header seems to be cr_hdr_head and the blowup comes from utsinfo string 
data (which could easily be moved out to be in it's own CR_HDR_STRING 
blocks).

Wouldn't it be easier to use stack-local storage than balancing the 
cr_hbuf_get/put routines?

> +
> +/*
> + * ctx->hbuf is used to hold headers and data of known (or bound),
> + * static sizes. In some cases, multiple headers may be allocated in
> + * a nested manner. The size should accommodate all headers, nested
> + * or not, on all archs.
> + */
> +#define CR_HBUF_TOTAL  (8 * 4096)
> +
> +/**
> + * cr_hbuf_get - reserve space on the hbuf
> + * @ctx: checkpoint context
> + * @n: number of bytes to reserve
> + *
> + * Returns pointer to reserved space
> + */
> +void *cr_hbuf_get(struct cr_ctx *ctx, int n)
> +{
> +	void *ptr;
> +
> +	/*
> +	 * Since requests depend on logic and static header sizes (not on
> +	 * user data), space should always suffice, unless someone either
> +	 * made a structure bigger or call path deeper than expected.
> +	 */
> +	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
> +	ptr = ctx->hbuf + ctx->hpos;
> +	ctx->hpos += n;
> +	return ptr;
> +}
> +
> +/**
> + * cr_hbuf_put - unreserve space on the hbuf
> + * @ctx: checkpoint context
> + * @n: number of bytes to reserve
> + */
> +void cr_hbuf_put(struct cr_ctx *ctx, int n)
> +{
> +	BUG_ON(ctx->hpos < n);
> +	ctx->hpos -= n;
> +}
> +
