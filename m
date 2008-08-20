From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v2][PATCH 8/9] Remove some BUG_ON()s that need some
	proper error handling instead.
Date: Wed, 20 Aug 2008 13:29:46 -0700
Message-ID: <1219264186.8960.53.camel__35502.7854479433$1219264317$gmane$org@nimitz>
References: <20080820192557.98788FAB@nimitz> <20080820192607.91E0AFF2@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192607.91E0AFF2@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2008-08-20 at 12:26 -0700, Dave Hansen wrote:

> diff -puN checkpoint/checkpoint.c~0002-Remove-some-BUG_ON-s-that-need-some-proper-error-ha checkpoint/checkpoint.c
> --- oren-cr.git/checkpoint/checkpoint.c~0002-Remove-some-BUG_ON-s-that-need-some-proper-error-ha        2008-08-20 12:12:51.000000000 -0700
> +++ oren-cr.git-dave/checkpoint/checkpoint.c    2008-08-20 12:12:51.000000000 -0700
> @@ -125,7 +125,8 @@ static int cr_write_tail(struct cr_ctx *
>         h.id = 0;
> 
>         hh->magic = CR_HEADER_MAGIC;
> -       hh->cksum[0] = hh->cksum[1] = 1;        /* TBD ... */
> +       hh->cksum[0] = 1;
> +               hh->cksum[1] = 1;       /* TBD ... */
> 
>         ret = cr_write_obj(ctx, &h, hh);
>         kfree(hh);

Whoops, that's a bad hunk that belongs in the next patch.  Sorry.

-- Dave
