From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH trivial] pty: set tty on error
Date: Fri, 18 Sep 2009 13:21:14 -0400
Message-ID: <4AB3C18A.5090504@librato.com>
References: <20090918155507.GA1329@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090918155507.GA1329-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> we always return tty expecting it to hold the error code.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/char/tty_io.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index 1729b2f..ee95938 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -3033,8 +3033,12 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
>  	 */
>  	if (master) {
>  		file = pty_open_by_index("/dev/ptmx", h->index);
> -		if (IS_ERR(file))
> +		if (IS_ERR(file)) {
> +			ckpt_write_err(ctx, "TE", "Error %d opening /dev/ptmx",
> +				PTR_ERR(file));

The 'E' in the first format string already geenrates "err %d" and
the integer PTR_ERR(file). The explicit "Error %d" is redundant (and
requires another integer).

See (now added) documentation to __ckpt_generate_err() in the code.

Oren.

> +			tty = ERR_PTR(PTR_ERR(file));
>  			goto out;
> +		}
>  
>  		/*
>  		 * Add file to objhash to ensure proper cleanup later
