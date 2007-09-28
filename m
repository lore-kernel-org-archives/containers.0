From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] Update get_net_ns_by_pid
Date: Fri, 28 Sep 2007 18:13:54 -0500
Message-ID: <20070928231354.GB7407@sergelap.austin.rr.com>
References: <m1k5qbfo1n.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1k5qbfo1n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> 
> In the -mm tree the rules for access an nsproxy have changed,
> and in get_net_ns_by_pid we access the nsproxy, so update
> it to follow the new rules.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Yup, looks right.

I assume Pavel's Acked-by would actually matter, but still

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

> ---
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 739fbad..1caba10 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -746,10 +746,10 @@ static struct net *get_net_ns_by_pid(pid_t pid)
>  	rcu_read_lock();
>  	tsk = find_task_by_pid(pid);
>  	if (tsk) {
> -		task_lock(tsk);
> -		if (tsk->nsproxy)
> -			net = get_net(tsk->nsproxy->net_ns);
> -		task_unlock(tsk);
> +		struct nsproxy *nsproxy;
> +		nsproxy = task_nsproxy(tsk);
> +		if (nsproxy)
> +			net = get_net(nsproxy->net_ns);
>  	}
>  	rcu_read_unlock();
>  	return net;
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
