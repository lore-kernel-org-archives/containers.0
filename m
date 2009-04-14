From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 26/30] cr: mount namespace
Date: Tue, 14 Apr 2009 11:48:10 -0700
Message-ID: <1239734890.32604.102.camel__42216.7737772272$1239735148$gmane$org@nimitz>
References: <20090410024004.GA27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090410024004.GA27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-04-10 at 06:40 +0400, Alexey Dobriyan wrote:
> 
> +struct mnt_namespace *alloc_mnt_ns(void)
> +{
> +       struct mnt_namespace *mnt_ns;
> +
> +       mnt_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
> +       if (mnt_ns) {
> +               atomic_set(&mnt_ns->count, 1);
> +               mnt_ns->root = NULL;
> +               INIT_LIST_HEAD(&mnt_ns->list);
> +               init_waitqueue_head(&mnt_ns->poll);
> +               mnt_ns->event = 0;
> +       }
> +       return mnt_ns;
> +}
> +
>  /*
>   * Allocate a new namespace structure and populate it with contents
>   * copied from the namespace of the passed in task structure.
> @@ -1981,15 +1996,10 @@ static struct mnt_namespace *dup_mnt_ns(struct
> mnt_namespace *mnt_ns,
>         struct vfsmount *rootmnt = NULL, *pwdmnt = NULL;
>         struct vfsmount *p, *q;
> 
> -       new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
> +       new_ns = alloc_mnt_ns();
>         if (!new_ns)
>                 return ERR_PTR(-ENOMEM);
> 
> -       atomic_set(&new_ns->count, 1);
> -       INIT_LIST_HEAD(&new_ns->list);
> -       init_waitqueue_head(&new_ns->poll);
> -       new_ns->event = 0;
> -
>         down_write(&namespace_sem);
>         /* First pass: copy the tree topology */
>         new_ns->root = copy_tree(mnt_ns->root, mnt_ns->root->mnt_root,
> --- a/include/linux/cr.h

This bit should be broken out, and stuck at the beginning of the series.

-- Dave
