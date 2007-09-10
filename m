From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Mon, 10 Sep 2007 11:16:44 +0530
Message-ID: <OF55551EA4.A3E6920C-ON65257352.001D6A3E-65257352.001FBEA7@in.ibm.com>
References: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.osdl.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote on 09/09/2007 02:45:34 AM:

Hi Eric,

> +static int register_pernet_operations(struct list_head *list,
> +                  struct pernet_operations *ops)
> +{
> <snip>
> +out:
> +   return error;
> +
> +out_undo:
> +   /* If I have an error cleanup all namespaces I initialized */
> +   list_del(&ops->list);
> +   for_each_net(undo_net) {
> +      if (undo_net == net)
> +         goto undone;
> +      if (ops->exit)
> +         ops->exit(undo_net);
> +   }
> +undone:
> +   goto out;
> +}

You could remove "undone" label (and associated) goto with a "break".

> +static void unregister_pernet_operations(struct pernet_operations *ops)
> +{
> +   struct net *net;
> +
> +   list_del(&ops->list);
> +   for_each_net(net)
> +      if (ops->exit)
> +         ops->exit(net);
> +}
> +
> +/**
> + *      register_pernet_subsys - register a network namespace subsystem
> + *   @ops:  pernet operations structure for the subsystem
> + *
> + *   Register a subsystem which has init and exit functions
> + *   that are called when network namespaces are created and
> + *   destroyed respectively.
> + *
> + *   When registered all network namespace init functions are
> + *   called for every existing network namespace.  Allowing kernel
> + *   modules to have a race free view of the set of network namespaces.
> + *
> + *   When a new network namespace is created all of the init
> + *   methods are called in the order in which they were registered.
> + *
> + *   When a network namespace is destroyed all of the exit methods
> + *   are called in the reverse of the order with which they were
> + *   registered.
> + */
<snip>
> +/**
> + *      unregister_pernet_subsys - unregister a network namespace
subsystem
> + *   @ops: pernet operations structure to manipulate
> + *
> + *   Remove the pernet operations structure from the list to be
> + *   used when network namespaces are created or destoryed.  In
> + *   addition run the exit method for all existing network
> + *   namespaces.
> + */
> +void unregister_pernet_subsys(struct pernet_operations *module)
> +{
> +   mutex_lock(&net_mutex);
> +   unregister_pernet_operations(module);
> +   mutex_unlock(&net_mutex);
> +}

Don't you require something like for_each_net_backwards to 'exit' in
reverse order? Same comment for unregister_subnet_subsys(). Should this
be done for failure in register_pernet_operations too?

thanks,

- KK

