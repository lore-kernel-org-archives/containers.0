From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 04/54] General infrastructure for checkpoint
	restart
Date: Tue, 28 Apr 2009 19:58:26 -0500
Message-ID: <20090429005826.GA23583@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-5-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240961064-13991-5-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
...
> +static int checkpoint_write_header(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_header *h;
> +	struct new_utsname *uts;
> +	struct timeval ktv;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER);

...
> +	struct ckpt_hdr_tail *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TAIL);

...
> +	struct ckpt_hdr_task *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);

...
> +/**
> + * ckpt_hdr_get_type - get a hdr of certain size
> + * @ctx: checkpoint context
> + * @len: number of bytes to reserve
> + *
> + * Returns pointer to reserved space on hbuf
> + */
> +void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
> +{

Observation (based on all callers in later patches as well): the second
argument appears to be superfluous?  You should be able to determine
based on type.

(The callers would look much friendlier without the 2nd arg imo)

-serge
