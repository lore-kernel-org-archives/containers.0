From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 2/5] ima: Add ns_status for storing namespaced iint
	data
Date: Tue, 25 Jul 2017 14:43:15 -0500
Message-ID: <20170725194315.GA2397@mail.hallyn.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-3-mkayaalp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170720225033.21298-3-mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

...
> +static void free_ns_status_cache(struct ima_namespace *ns)
> +{
> +	struct ns_status *status, *next;
> +
> +	write_lock(&ns->ns_status_lock);
> +	rbtree_postorder_for_each_entry_safe(status, next,
> +					     &ns->ns_status_tree, rb_node)
> +		kmem_cache_free(ns->ns_status_cache, status);
> +	ns->ns_status_tree = RB_ROOT;
> +	write_unlock(&ns->ns_status_lock);
> +	kmem_cache_destroy(ns->ns_status_cache);
> +}
> +
>  static void destroy_ima_ns(struct ima_namespace *ns)
>  {
>  	put_user_ns(ns->user_ns);
>  	ns_free_inum(&ns->ns);
> +	free_ns_status_cache(ns);
>  	kfree(ns);
>  }
>  
> @@ -181,3 +198,106 @@ struct ima_namespace init_ima_ns = {
>  	.parent = NULL,
>  };
>  EXPORT_SYMBOL(init_ima_ns);
> +
> +/*
> + * __ima_ns_status_find - return the ns_status associated with an inode
> + */
> +static struct ns_status *__ima_ns_status_find(struct ima_namespace *ns,
> +					      struct inode *inode)
> +{
> +	struct ns_status *status;
> +	struct rb_node *n = ns->ns_status_tree.rb_node;
> +
> +	while (n) {
> +		status = rb_entry(n, struct ns_status, rb_node);
> +
> +		if (inode < status->inode)
> +			n = n->rb_left;
> +		else if (inode->i_ino > status->i_ino)
> +			n = n->rb_right;
> +		else
> +			break;
> +	}
> +	if (!n)
> +		return NULL;
> +
> +	return status;
> +}
> +
> +/*
> + * ima_ns_status_find - return the ns_status associated with an inode
> + */
> +static struct ns_status *ima_ns_status_find(struct ima_namespace *ns,
> +					    struct inode *inode)
> +{
> +	struct ns_status *status;
> +
> +	read_lock(&ns->ns_status_lock);
> +	status = __ima_ns_status_find(ns, inode);
> +	read_unlock(&ns->ns_status_lock);
> +
> +	return status;
> +}
...
> +
> +struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
> +				    struct inode *inode)
> +{
> +	struct ns_status *status;
> +	int skip_insert = 0;
> +
> +	status = ima_ns_status_find(ns, inode);
> +	if (status) {
> +		/*
> +		 * Unlike integrity_iint_cache we are not free'ing the
> +		 * ns_status data when the inode is free'd. So, in addition to
> +		 * checking the inode pointer, we need to make sure the
> +		 * (i_generation, i_ino) pair matches as well. In the future
> +		 * we might want to add support for lazily walking the rbtree
> +		 * to clean it up.
> +		 */
> +		if (inode->i_ino == status->i_ino &&
> +		    inode->i_generation == status->i_generation)
> +			return status;
> +
> +		/* Same inode number is reused, overwrite the ns_status */
> +		skip_insert = 1;
> +	} else {
> +		status = kmem_cache_alloc(ns->ns_status_cache, GFP_NOFS);
> +		if (!status)
> +			return ERR_PTR(-ENOMEM);
> +	}

What prevents the status from being freed between the read_lock
in ima_ns_status_find() and the write_lock in the following line?

IIUC it's that ns is always current's ima_ns, which will pin the ns
and cause no statuses to be freed.  But then the ns should probably
not be passed in here?  Or a comment should say that ns must be
pinned?

Just trying to make sure I understand the locking.

> +	write_lock(&ns->ns_status_lock);
> +
> +	if (!skip_insert)
> +		insert_ns_status(ns, inode, status);
> +
> +	status->inode = inode;
> +	status->i_ino = inode->i_ino;
> +	status->i_generation = inode->i_generation;
> +	status->flags = 0UL;
> +	write_unlock(&ns->ns_status_lock);
> +
> +	return status;
> +}
> -- 
> 2.9.4
