From: Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v18 20/80] c/r: basic infrastructure for checkpoint/restart
Date: Thu, 24 Sep 2009 09:03:41 -0700
Message-ID: <1253808221.20648.196.camel__17846.732264343$1253808447$gmane$org@desktop>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<1253749920-18673-21-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-21-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-09-23 at 19:51 -0400, Oren Laadan wrote:
> /
> +static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *prefmt, char *fmt)
> +{
> +	static int warn_notask = 0;
> +	static int warn_prefmt = 0;

Shouldn't need the initializer since it's static..


> +/* read the checkpoint header */
> +static int restore_read_header(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_header *h;
> +	struct new_utsname *uts = NULL;
> +	int ret;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	ret = -EINVAL;
> +	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
> +	    h->rev != CHECKPOINT_VERSION ||
> +	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
> +	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
> +	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
> +		goto out;

Do you still need this LINUX_VERSION_CODE stuff ? I would think once
it's in mainline you wouldn't need to track that..

These both got flagged by checkpatch .. Your series is marked in a
couple other places with checkpatch errors .. If you haven't already
reviewed those errors, it would be a good idea to review them.

Daniel
