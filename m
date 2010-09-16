From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Remove unused CKPT_PTMX_PATH
Date: Thu, 16 Sep 2010 00:48:34 -0400
Message-ID: <4C91A1A2.7080304@cs.columbia.edu>
References: <0c27798f3cf4875c806d181638c7d1d8102d96a0.1282777176.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0c27798f3cf4875c806d181638c7d1d8102d96a0.1282777176.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Queued for ckpt-v22-dev, thanks.

Oren.

On 08/25/2010 06:59 PM, Matt Helsley wrote:
> This #define appears to be unused. It was introduced in:
> 
> 	commit 24004a943fbd66b0ec9dbcfae9d057acc96fda29
> 	c/r: [pty 2/2] support for pseudo terminals
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/char/tty_io.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index 115c8e4..0da945d 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -3042,8 +3042,6 @@ static int restore_tty_ldisc(struct ckpt_ctx *ctx,
>  	return 0;
>  }
>  
> -#define CKPT_PTMX_PATH  "/dev/ptmx"
> -
>  static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_hdr_tty *h;
