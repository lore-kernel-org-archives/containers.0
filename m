From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 13:19:46 -0500
Message-ID: <20100430181946.GA26761@us.ibm.com>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org, David Miller <davem@davemloft.net>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> +static int temp_netns_enter(struct net *net)
> +{
> +	int ret;
> +	struct net *tmp_netns;
> +
> +	ret = copy_namespaces(CLONE_NEWNET, current);
> +	if (ret)
> +		return ret;

Actually there is one problem here - copy_namespaces() is
specifically used only by clone() and it expects tsk to
not yet be live.  So it just does

	tsk->nsproxy = new_ns

Since you're doing this on current which is live, it would
have to use rcu_assign_pointer() to be safe.

So I'm afraid you're going to have to do a slightly uglier
thing where you unshare_nsproxy_namespaces() and then
switch_task_namespaces() to the new nsproxy.

> +
> +	tmp_netns = current->nsproxy->net_ns;
> +	get_net(net);
> +	current->nsproxy->net_ns = net;
> +	put_net(tmp_netns);
> +
> +	return 0;
> +}

Otherwise it looks good to me.  My only other comment would be to soothe
readers' anxieties by putting a comment right here explaining that
switch_task_namespaces() will drop your ref to current->nsproxy->net_ns,
and that you had never dropped the ref to prev so it will be safe.

> +static void temp_netns_exit(struct nsproxy *prev)
> +{
> +	switch_task_namespaces(current, prev);
> +}

thanks,
-serge
