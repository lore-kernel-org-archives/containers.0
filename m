From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: fix omitted parameter name error
Date: Mon, 29 Mar 2010 18:27:39 -0400
Message-ID: <4BB1295B.1000401@cs.columbia.edu>
References: <1269793294-3853-1-git-send-email-stas.bezzubtsev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269793294-3853-1-git-send-email-stas.bezzubtsev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Stanislav O. Bezzubtsev" <stas.bezzubtsev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Queued for v21, thanks.

Stanislav O. Bezzubtsev wrote:
> Signed-off-by: Stanislav O. Bezzubtsev <stas.bezzubtsev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/dnotify.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/dnotify.h b/include/linux/dnotify.h
> index b9ce13c..7093052 100644
> --- a/include/linux/dnotify.h
> +++ b/include/linux/dnotify.h
> @@ -38,7 +38,7 @@ static inline void dnotify_flush(struct file *filp, fl_owner_t id)
>  {
>  }
>  
> -static inline int is_dnotify_attached(struct file *)
> +static inline int is_dnotify_attached(struct file *filp)
>  {
>  	return 0;
>  }
