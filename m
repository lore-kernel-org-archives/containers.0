From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Disable softirqs when taking the socket queue lock
Date: Tue, 30 Mar 2010 00:50:48 -0400
Message-ID: <4BB18328.3040204@cs.columbia.edu>
References: <1269459664-21354-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269459664-21354-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Applied for ckpt-v21, thanks.

Dan Smith wrote:
> This prevents the lockdep report (and potential deadlock) if we get
> unlucky while traversing the queues.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  net/checkpoint.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index 0eb8860..9197671 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -44,10 +44,10 @@ static int sock_copy_buffers(struct sk_buff_head *from,
>  
>  	*total_bytes = 0;
>  
> -	spin_lock(&from->lock);
> +	spin_lock_bh(&from->lock);
>  	skb_queue_walk(from, skb)
>  		count1++;
> -	spin_unlock(&from->lock);
> +	spin_unlock_bh(&from->lock);
>  
>  	skbs = kzalloc(sizeof(*skbs) * count1, GFP_KERNEL);
>  	if (!skbs)
> @@ -60,7 +60,7 @@ static int sock_copy_buffers(struct sk_buff_head *from,
>  	}
>  
>  	i = 0;
> -	spin_lock(&from->lock);
> +	spin_lock_bh(&from->lock);
>  	skb_queue_walk(from, skb) {
>  		if (++count2 > count1)
>  			break; /* The queue changed as we read it */
> @@ -72,7 +72,7 @@ static int sock_copy_buffers(struct sk_buff_head *from,
>  		*total_bytes += skb->len;
>  		i++;
>  	}
> -	spin_unlock(&from->lock);
> +	spin_unlock_bh(&from->lock);
>  
>  	if (count1 != count2)
>  		goto err;
