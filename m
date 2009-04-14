From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 26/30] cr: mount namespace
Date: Tue, 14 Apr 2009 11:53:31 -0700
Message-ID: <1239735211.32604.107.camel__12809.8156340004$1239735462$gmane$org@nimitz>
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
> +int cr_collect_all_mnt_ns(struct cr_context *ctx)
> +{
> +       struct cr_object *obj;
> +       int rv;
> +
> +       for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
> +               struct nsproxy *nsproxy = obj->o_obj;
> +
> +               rv = cr_collect_mnt_ns(ctx, nsproxy->mnt_ns);
> +               if (rv < 0)
> +                       return rv;
> +       }
> +       for_each_cr_object(ctx, obj, CR_CTX_MNT_NS) {
> +               struct mnt_namespace *mnt_ns = obj->o_obj;
> +               unsigned int cnt = atomic_read(&mnt_ns->count);
> +
> +               if (obj->o_count != cnt) {
> +                       printk("%s: mnt_ns %p has external references %lu:%u\n", __func__, mnt_ns, obj->o_count, cnt);
> +                       return -EINVAL;
> +               }
> +       }
> +       return 0;
> +}

I worry about depending on refcounts like this, especially when
userspace has an interface that can elevate them.  If someone is holding
open /proc/$pid/mounts, this will get elevated and trip the check.  This
check is also naturally racy.  You check once if there are references,
but there is no locking to keep new references from coming in.  

That said, I do like how this for_each_cr_object() stuff looks.  It's
pretty clean.

-- Dave
