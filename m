From: Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] limit nr_dentries per superblock
Date: Mon, 15 Aug 2011 10:12:06 +0300
Message-ID: <CAOJsxLFYD9DkEU5R+9fZr-uaznteP8-BUC_Ti+FnNFqtbOCHSw__43207.3524724275$1313392375$gmane$org@mail.gmail.com>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1313334832-1150-4-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Aug 14, 2011 at 6:13 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrot=
e:
> This patch lays the foundation for us to limit the dcache size.
> Each super block can have only a maximum amount of dentries under its
> sub-tree. Allocation fails if we we're over limit and the cache
> can't be pruned to free up space for the newcomers.
>
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> =A0fs/dcache.c =A0 =A0 =A0 =A0| =A0 28 ++++++++++++++++++++++++++++
> =A0fs/super.c =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0include/linux/fs.h | =A0 =A01 +
> =A03 files changed, 30 insertions(+), 0 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 815d9fd..ddd02a2 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1180,6 +1180,31 @@ void shrink_dcache_parent(struct dentry * parent)
> =A0}
> =A0EXPORT_SYMBOL(shrink_dcache_parent);
>
> +static inline int dcache_mem_check(struct super_block *sb)
> +{
> + =A0 =A0 =A0 struct shrink_control sc =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
> + =A0 =A0 =A0 };
> +
> + =A0 =A0 =A0 if (sb->s_nr_dentry_max =3D=3D INT_MAX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nr_dentry;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_dentry =3D percpu_counter_read_positive(=
&sb->s_nr_dentry);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_dentry > sb->s_nr_dentry_max)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_dentry =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_coun=
ter_sum_positive(&sb->s_nr_dentry);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_dentry < sb->s_nr_dentry_max)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 /* nr_pages =3D 1, lru_pages =3D 0 should get delta ~ 2 */
> + =A0 =A0 =A0 } while (shrink_one_shrinker(&sb->s_shrink, &sc, 1, 0));
> +
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> =A0/**
> =A0* __d_alloc =A0 - =A0 =A0 =A0 allocate a dcache entry
> =A0* @sb: filesystem it will belong to
> @@ -1195,6 +1220,9 @@ struct dentry *__d_alloc(struct super_block *sb, co=
nst struct qstr *name)
> =A0 =A0 =A0 =A0struct dentry *dentry;
> =A0 =A0 =A0 =A0char *dname;
>
> + =A0 =A0 =A0 if (dcache_mem_check(sb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> =A0 =A0 =A0 =A0dentry =3D kmem_cache_alloc(dentry_cache, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!dentry)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> diff --git a/fs/super.c b/fs/super.c
> index e95ac4f..3db40fb 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -121,6 +121,7 @@ static struct super_block *alloc_super(struct file_sy=
stem_type *type)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0percpu_counter_init(&s->s_nr_dentry, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->s_nr_dentry_max =3D INT_MAX;
>
> =A0#ifdef CONFIG_SMP
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->s_files =3D alloc_percpu(struct list_he=
ad);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8150f52..bc773c3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1400,6 +1400,7 @@ struct super_block {
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s_nr_dentry_un=
used; =A0 =A0 /* # of dentry on lru */
>
> =A0 =A0 =A0 =A0struct percpu_counter =A0 s_nr_dentry; =A0 =A0 =A0 =A0 =A0=
 =A0/* # of dentry on this sb */
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s_nr_dentry_max=
; =A0 =A0 =A0 =A0/* max # of dentry on this sb*/
>
> =A0 =A0 =A0 =A0/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_u=
nused */
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0s_inode_lru_lock ___=
_cacheline_aligned_in_smp;

We track the total number of objects in mm/slub.c when
CONFIG_SLUB_DEBUG is enabled (look for n->total_objects in the code).
Have you considered extending that for this purpose?

                                Pekka
