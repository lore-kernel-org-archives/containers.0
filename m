From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] epoll: Check for fdtable races
Date: Fri, 23 Oct 2009 21:03:15 -0400
Message-ID: <4AE25253.4040100@librato.com>
References: <1256321658-15646-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256321658-15646-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> In case it's possible to race with other tasks sharing the fdtable,
> check for NULL file * and exit with an error.
> 
> Please consider merging this with the first patch in the series
> of epoll patches posted recently.
> 
> Reported-by: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Already did that when I pulled your patch.

BTW, I chose -EBUSY instead to tell the user to try again
later... when he/she isn't malicious anymore :)

Oren.

> ---
>  fs/eventpoll.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index c261263..638f9d7 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -1677,7 +1677,8 @@ struct file* ep_file_restore(struct ckpt_ctx *ctx,
>  		return ERR_PTR(epfd);
>  	epfile = fget(epfd);
>  	sys_close(epfd); /* harmless even if an error occured */
> -	BUG_ON(!epfile);
> +	if (!epfile)
> +		return ERR_PTR(-EBADF);
>  
>  	/*
>  	 * Needed before we can properly restore the watches and enforce the
