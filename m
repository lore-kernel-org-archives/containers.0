From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
	infrastructure
Date: Tue, 2 Mar 2010 12:00:58 +0100
Message-ID: <20100302110058.GA1921__36544.1084992655$1267527791$gmane$org@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-3-git-send-email-arighi@develer.com>
	<cc557aab1003020204k16038838ta537357aeeb67b11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cc557aab1003020204k16038838ta537357aeeb67b11-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 02, 2010 at 12:04:53PM +0200, Kirill A. Shutemov wrote:
[snip]
> > +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item =
item)
> > +{
> > + =A0 =A0 =A0 return -ENOMEM;
> =

> Why ENOMEM? Probably, EINVAL or ENOSYS?

OK, ENOSYS is more appropriate IMHO.

> > +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_=
cgroup_page_stat_item item)
> > +{
> > + =A0 =A0 =A0 s64 ret;
> > +
> > + =A0 =A0 =A0 switch (item) {
> > + =A0 =A0 =A0 case MEMCG_NR_DIRTYABLE_PAGES:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_read_u64(&memcg->res,=
 RES_LIMIT) -
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&mem=
cg->res, RES_USAGE);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Translate free memory in pages */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret >>=3D PAGE_SHIFT;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D mem_cgroup_read_stat(memcg, LRU_=
ACTIVE_FILE) +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_read_stat(memc=
g, LRU_INACTIVE_FILE);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_can_swap(memcg))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D mem_cgroup_read_=
stat(memcg, LRU_ACTIVE_ANON) +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgrou=
p_read_stat(memcg, LRU_INACTIVE_ANON);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case MEMCG_NR_RECLAIM_PAGES:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(memcg, MEM_C=
GROUP_STAT_FILE_DIRTY) +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_read_stat(memc=
g,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 MEM_CGROUP_STAT_UNSTABLE_NFS);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case MEMCG_NR_WRITEBACK:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(memcg, MEM_C=
GROUP_STAT_WRITEBACK);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(memcg, MEM_C=
GROUP_STAT_WRITEBACK) +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_read_stat(memc=
g,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROU=
P_STAT_UNSTABLE_NFS);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(1);
> =

> I think it's a bug, not warning.

OK.

> > + =A0 =A0 =A0 }
> > + =A0 =A0 =A0 return ret;
> > +}
> > +
> > +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup_page_stat *stat =3D (struct mem_cgroup_=
page_stat *)data;
> > +
> > + =A0 =A0 =A0 stat->value +=3D mem_cgroup_get_local_page_stat(mem, stat=
->item);
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup_page_stat stat =3D {};
> > + =A0 =A0 =A0 struct mem_cgroup *memcg;
> > +
> > + =A0 =A0 =A0 if (mem_cgroup_disabled())
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> =

> EINVAL/ENOSYS?

OK.

> =

> > + =A0 =A0 =A0 rcu_read_lock();
> > + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> > + =A0 =A0 =A0 if (memcg) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Recursively evaulate page statistics=
 against all cgroup
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* under hierarchy tree
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat.item =3D item;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_walk_tree(memcg, &stat, mem_cg=
roup_page_stat_cb);
> > + =A0 =A0 =A0 } else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat.value =3D -ENOMEM;
> =

> ditto.

OK.

> =

> > + =A0 =A0 =A0 rcu_read_unlock();
> > +
> > + =A0 =A0 =A0 return stat.value;
> > +}
> > +
> > =A0static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void=
 *data)
> > =A0{
> > =A0 =A0 =A0 =A0int *val =3D data;
> > @@ -1263,14 +1418,16 @@ static void record_last_oom(struct mem_cgroup *=
mem)
> > =A0}
> >
> > =A0/*
> > - * Currently used to update mapped file statistics, but the routine ca=
n be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update memory cgroup statistics.
> > =A0*/
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_stat_inde=
x idx, int val)
> =

> EXPORT_SYMBOL_GPL(mem_cgroup_update_stat) is needed, since
> it uses by filesystems.

Agreed.

> > +static int
> > +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 va=
l)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > + =A0 =A0 =A0 int type =3D cft->private;
> > +
> > + =A0 =A0 =A0 if (cgrp->parent =3D=3D NULL)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > + =A0 =A0 =A0 if (((type =3D=3D MEM_CGROUP_DIRTY_RATIO) ||
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (type =3D=3D MEM_CGROUP_DIRTY_BACKGROUND_=
RATIO)) && (val > 100))
> =

> Too many unnecessary brackets
> =

>        if ((type =3D=3D MEM_CGROUP_DIRTY_RATIO ||
>                type =3D=3D MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 10=
0)
> =


OK.

Thanks,
-Andrea
