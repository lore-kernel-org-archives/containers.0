From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 2/5] ima: Add ns_status for storing namespaced iint
	data
Date: Fri, 11 Aug 2017 11:00:52 -0400
Message-ID: <9a2ae1ef-95c3-6eb3-bf4d-78b84d5a77e4__17403.1487819322$1502463677$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-3-mkayaalp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/20/2017 06:50 PM, Mehmet Kayaalp wrote:
> This patch adds an rbtree to the IMA namespace structure that stores a
> namespaced version of iint->flags in ns_status struct. Similar to the
> integrity_iint_cache, both the iint ns_struct are looked up using the
> inode pointer value. The lookup, allocate, and insertion code is also
> similar, except ns_struct is not free'd when the inode is free'd.
> Instead, the lookup verifies the i_ino and i_generation fields are also a
> match. A lazy clean up of the rbtree that removes free'd inodes could be
> implemented to reclaim the invalid entries.
>
> Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>   include/linux/ima.h             |   3 +
>   security/integrity/ima/ima.h    |  16 ++++++
>   security/integrity/ima/ima_ns.c | 120 ++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 139 insertions(+)
>
>
> @@ -181,3 +198,106 @@ struct ima_namespace init_ima_ns = {
>   	.parent = NULL,
>   };
>   EXPORT_SYMBOL(init_ima_ns);
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

Above you are comparing with the inode ptr, here with i_ino. Why can you 
not compare with inode both times. Also the insertion only seems to 
consider the inode ptr.

    Stefan
