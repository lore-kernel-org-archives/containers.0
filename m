From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 09:46:36 -0400
Message-ID: <1243604796.3966.21.camel__25681.7367779606$1243605057$gmane$org@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529141830.8ba30a24.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi there,

Sorry - cant help you on earlier question in the thread on
syntax of cls_group config (but we can revisit after resolving
this). You should always copy the maintainer if you want quick
answers (for cls_group case Thomas Graf).

On your patch:
I think you have found a real issue (I have a strong feeling
it has everything to do with your config process)

Comments below:

On Fri, 2009-05-29 at 14:18 +0900, Minoru Usui wrote:
> Hi, 


> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 0759f32..756148b 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -266,11 +266,6 @@ replay:
>  			goto errout;
>  		}
>  
> -		spin_lock_bh(root_lock);
> -		tp->next = *back;
> -		*back = tp;
> -		spin_unlock_bh(root_lock);
> -
>  	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
>  		goto errout;
>  
> @@ -314,8 +309,17 @@ replay:
>  	}
>  
>  	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> -	if (err == 0)
> -		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
> +	if (err) {
> +		tcf_destroy(tp);
> +		goto errout;
> +	}
> +
> +	spin_lock_bh(root_lock);
> +	tp->next = *back;
> +	*back = tp;
> +	spin_unlock_bh(root_lock);
> +
> +	tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);

This is incorrect. tp may already exist and you dont want to destroy
for failure to change its parameters. You also dont want to reattach
an existing tp because it succeeded in parameter change. 
So the soln is to check if this is a new tp and then do what you did
above...
Did that make sense?

cheers,
jamal
