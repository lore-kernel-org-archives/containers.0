From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] cgroup: if you list_empty() a head then don't
	list_del() it
Date: Tue, 15 Mar 2011 09:20:00 -0700
Message-ID: <AANLkTi=P0xPXs+_6KGa7SBfy_aNcq791tbbvOaKfen8J__15683.225359726$1300206166$gmane$org@mail.gmail.com>
References: <1300194523-19325-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1300194523-19325-2-git-send-email-ext-phil.2.carmody@nokia.com>
	<1300194523-19325-3-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1300194523-19325-3-git-send-email-ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 15, 2011 at 6:08 AM, Phil Carmody
<ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:
> list_del() leaves poison in the prev and next pointers. The next
> list_empty() will compare those poisons, and say the list isn't empty.
> Any list operations that assume the node is on a list because of such a
> check will be fooled into dereferencing poison. One needs to INIT the
> node after the del, and fortunately there's already a wrapper for that -
> list_del_init().
>
> Some of the dels are followed by deallocations, so can be ignored,
> and one can be merged with an add to make a move. Apart from that, I
> erred on the side of caution in making nodes list_empty()-queriable.
>
> Signed-off-by: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks,
Paul

> ---
> =A0kernel/cgroup.c | =A0 14 ++++++--------
> =A01 files changed, 6 insertions(+), 8 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index b24d702..bcc7336 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1813,10 +1813,8 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
>
> =A0 =A0 =A0 =A0/* Update the css_set linked lists if we're using them */
> =A0 =A0 =A0 =A0write_lock(&css_set_lock);
> - =A0 =A0 =A0 if (!list_empty(&tsk->cg_list)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&tsk->cg_list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&tsk->cg_list, &newcg->tasks);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!list_empty(&tsk->cg_list))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&tsk->cg_list, &newcg->tasks);
> =A0 =A0 =A0 =A0write_unlock(&css_set_lock);
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> @@ -3655,12 +3653,12 @@ again:
> =A0 =A0 =A0 =A0spin_lock(&release_list_lock);
> =A0 =A0 =A0 =A0set_bit(CGRP_REMOVED, &cgrp->flags);
> =A0 =A0 =A0 =A0if (!list_empty(&cgrp->release_list))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cgrp->release_list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&cgrp->release_list);
> =A0 =A0 =A0 =A0spin_unlock(&release_list_lock);
>
> =A0 =A0 =A0 =A0cgroup_lock_hierarchy(cgrp->root);
> =A0 =A0 =A0 =A0/* delete this cgroup from parent->children */
> - =A0 =A0 =A0 list_del(&cgrp->sibling);
> + =A0 =A0 =A0 list_del_init(&cgrp->sibling);
> =A0 =A0 =A0 =A0cgroup_unlock_hierarchy(cgrp->root);
>
> =A0 =A0 =A0 =A0d =3D dget(cgrp->dentry);
> @@ -3879,7 +3877,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
> =A0 =A0 =A0 =A0subsys[ss->subsys_id] =3D NULL;
>
> =A0 =A0 =A0 =A0/* remove subsystem from rootnode's list of subsystems */
> - =A0 =A0 =A0 list_del(&ss->sibling);
> + =A0 =A0 =A0 list_del_init(&ss->sibling);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * disentangle the css from all css_sets attached to the d=
ummytop. as
> @@ -4253,7 +4251,7 @@ void cgroup_exit(struct task_struct *tsk, int run_c=
allbacks)
> =A0 =A0 =A0 =A0if (!list_empty(&tsk->cg_list)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write_lock(&css_set_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!list_empty(&tsk->cg_list))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&tsk->cg_list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&tsk->cg_list=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write_unlock(&css_set_lock);
> =A0 =A0 =A0 =A0}
>
> --
> 1.7.2.rc1.37.gf8c40
>
>
