From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: make cftype.unregister_event() void-returning
Date: Fri, 7 May 2010 14:07:13 -0700
Message-ID: <p2l6599ad831005071407yaa994357s1261317cc7f552b__23847.6308215924$1273266472$gmane$org@mail.gmail.com>
References: <l2pcc557aab1005070446y1f9c8169v58a3f7847676eaa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <l2pcc557aab1005070446y1f9c8169v58a3f7847676eaa-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

I like the principle. I think this patch leaks arrays, though.

I think the sequence:

register;register;unregister;unregister

will leak the array of size 2. Using the notation Ax, Bx, Cx, etc to
represent distinct buffers of size x, we have:

initially: size =3D 0, thresholds =3D NULL, spare =3D NULL
register: size =3D 1, thresholds =3D A1, spare =3D NULL
register: size =3D 2, thresholds =3D B2, spare =3D A1
unregister: size =3D 1, thresholds =3D A1, spare =3D B2
unregister: size =3D 0, thresholds =3D NULL, spare =3D A1 (B2 is leaked)

In the case when you're unregistering and the size goes down to 0, you
need to free the spare before doing the swap. Maybe get rid of the
thresholds_new local variable, and instead in the if(!size) {} branch
just free and the spare buffer and set its pointer to NULL? Then at
swap_buffers:, unconditionally swap the two.

Also, I think the code would be cleaner if you created a structure to
hold a primary threshold and its spare; then you could have one for
each threshold set, and just pass that to the register/unregister
functions, rather than them having to be aware of how the type maps to
the primary and backup array pointers.

Paul

On Fri, May 7, 2010 at 4:46 AM, Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> w=
rote:
> Since we unable to handle error returned by cftype.unregister_event()
> properly, let's make the callback void-returning.
>
> mem_cgroup_unregister_event() has been rewritten to be "never fail"
> function. On mem_cgroup_usage_register_event() we save old buffer
> for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
> to avoid allocation.
>
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> ---
> =A0include/linux/cgroup.h | =A0 =A02 +-
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 64 ++++++++++++++++++++++++++++++=
------------------
> =A03 files changed, 41 insertions(+), 26 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8f78073..0c62160 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -397,7 +397,7 @@ struct cftype {
> =A0 =A0 =A0 =A0 * This callback must be implemented, if you want provide
> =A0 =A0 =A0 =A0 * notification functionality.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 int (*unregister_event)(struct cgroup *cgrp, struct cftype =
*cft,
> + =A0 =A0 =A0 void (*unregister_event)(struct cgroup *cgrp, struct cftype=
 *cft,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct eventfd_ctx *eventf=
d);
> =A0};
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 06dbf97..6675e8c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2988,7 +2988,6 @@ static void cgroup_event_remove(struct work_struct =
*work)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remove);
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D event->cgrp;
>
> - =A0 =A0 =A0 /* TODO: check return code */
> =A0 =A0 =A0 =A0event->cft->unregister_event(cgrp, event->cft, event->even=
tfd);
>
> =A0 =A0 =A0 =A0eventfd_ctx_put(event->eventfd);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8cb2722..0a37b5d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -226,9 +226,19 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0/* thresholds for memory usage. RCU-protected */
> =A0 =A0 =A0 =A0struct mem_cgroup_threshold_ary *thresholds;
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Preallocated buffer to be used in mem_cgroup_unregiste=
r_event()
> + =A0 =A0 =A0 =A0* to make it "never fail".
> + =A0 =A0 =A0 =A0* It must be able to store at least thresholds->size - 1=
 entries.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__thresholds;
> +
> =A0 =A0 =A0 =A0/* thresholds for mem+swap usage. RCU-protected */
> =A0 =A0 =A0 =A0struct mem_cgroup_threshold_ary *memsw_thresholds;
>
> + =A0 =A0 =A0 /* the same as __thresholds, but for memsw_thresholds */
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__memsw_thresholds;
> +
> =A0 =A0 =A0 =A0/* For oom notifier event fd */
> =A0 =A0 =A0 =A0struct list_head oom_notify;
>
> @@ -3575,17 +3585,27 @@ static int
> mem_cgroup_usage_register_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(memcg->memsw_thresholds=
, thresholds_new);
>
> - =A0 =A0 =A0 /* To be sure that nobody uses thresholds before freeing it=
 */
> + =A0 =A0 =A0 /* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
>
> - =A0 =A0 =A0 kfree(thresholds);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Free old preallocated buffer and use thresholds as new
> + =A0 =A0 =A0 =A0* preallocated buffer.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (type =3D=3D _MEM) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__thresholds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__memsw_thresholds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> + =A0 =A0 =A0 }
> =A0unlock:
> =A0 =A0 =A0 =A0mutex_unlock(&memcg->thresholds_lock);
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> +static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> @@ -3593,7 +3613,7 @@ static int
> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0int type =3D MEMFILE_TYPE(cft->private);
> =A0 =A0 =A0 =A0u64 usage;
> =A0 =A0 =A0 =A0int size =3D 0;
> - =A0 =A0 =A0 int i, j, ret =3D 0;
> + =A0 =A0 =A0 int i, j;
>
> =A0 =A0 =A0 =A0mutex_lock(&memcg->thresholds_lock);
> =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> @@ -3623,17 +3643,15 @@ static int
> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0/* Set thresholds array to NULL if we don't have threshold=
s */
> =A0 =A0 =A0 =A0if (!size) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0thresholds_new =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto assign;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto swap_buffers;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Allocate memory for new array of thresholds */
> - =A0 =A0 =A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new) +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size * sizeof(struct mem_cg=
roup_threshold),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
> - =A0 =A0 =A0 if (!thresholds_new) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* Use preallocated buffer for new array of thresholds */
> + =A0 =A0 =A0 if (type =3D=3D _MEM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__thresholds;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__memsw_threshold=
s;
> +
> =A0 =A0 =A0 =A0thresholds_new->size =3D size;
>
> =A0 =A0 =A0 =A0/* Copy thresholds and find current threshold */
> @@ -3654,20 +3672,20 @@ static int
> mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0j++;
> =A0 =A0 =A0 =A0}
>
> -assign:
> - =A0 =A0 =A0 if (type =3D=3D _MEM)
> +swap_buffers:
> + =A0 =A0 =A0 /* Swap thresholds array and preallocated buffer */
> + =A0 =A0 =A0 if (type =3D=3D _MEM) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(memcg->thresholds, thre=
sholds_new);
> - =A0 =A0 =A0 else
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(memcg->memsw_thresholds=
, thresholds_new);
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 /* To be sure that nobody uses thresholds before freeing it=
 */
> + =A0 =A0 =A0 /* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
>
> - =A0 =A0 =A0 kfree(thresholds);
> -unlock:
> =A0 =A0 =A0 =A0mutex_unlock(&memcg->thresholds_lock);
> -
> - =A0 =A0 =A0 return ret;
> =A0}
>
> =A0static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
> @@ -3695,7 +3713,7 @@ static int mem_cgroup_oom_register_event(struct
> cgroup *cgrp,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
> +static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> @@ -3714,8 +3732,6 @@ static int
> mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0mutex_unlock(&memcg_oom_mutex);
> -
> - =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> --
> 1.7.0.4
>
