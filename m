From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 2/2] cgroups: Clean up cgroup_pidlist_find() a bit
Date: Tue, 26 Jan 2010 15:08:59 -0800
Message-ID: <6599ad831001261508w2262bf56gd713c5170a91c31d@mail.gmail.com>
References: <4B5EA4EC.8020700@cn.fujitsu.com> <4B5EA500.5040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752802Ab0AZXJF@vger.kernel.org>
In-Reply-To: <4B5EA500.5040802@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ben Blum <bblum@andrew.cmu.edu>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 26, 2010 at 12:17 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> Don't Call get_pid_ns() before we locate/alloc the ns.
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

> ---
> =A0cgroup.c | =A0 =A08 +++-----
> =A01 file changed, 3 insertions(+), 5 deletions(-)
>
> --- a/kernel/cgroup.c.orig =A0 =A0 =A02010-01-26 14:24:29.000000000 +=
0800
> +++ a/kernel/cgroup.c =A0 2010-01-26 14:24:44.000000000 +0800
> @@ -2643,7 +2643,8 @@ static struct cgroup_pidlist *cgroup_pid
> =A0{
> =A0 =A0 =A0 =A0struct cgroup_pidlist *l;
> =A0 =A0 =A0 =A0/* don't need task_nsproxy() if we're looking at ourse=
lf */
> - =A0 =A0 =A0 struct pid_namespace *ns =3D get_pid_ns(current->nsprox=
y->pid_ns);
> + =A0 =A0 =A0 struct pid_namespace *ns =3D current->nsproxy->pid_ns;
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We can't drop the pidlist_mutex before taking the l=
->mutex in case
> =A0 =A0 =A0 =A0 * the last ref-holder is trying to remove l from the =
list at the same
> @@ -2653,8 +2654,6 @@ static struct cgroup_pidlist *cgroup_pid
> =A0 =A0 =A0 =A0mutex_lock(&cgrp->pidlist_mutex);
> =A0 =A0 =A0 =A0list_for_each_entry(l, &cgrp->pidlists, links) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (l->key.type =3D=3D type && l->key.=
ns =3D=3D ns) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* found a matching lis=
t - drop the extra refcount */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid_ns(ns);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* make sure l doesn't=
 vanish out from under us */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0down_write(&l->mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cgrp->pi=
dlist_mutex);
> @@ -2665,13 +2664,12 @@ static struct cgroup_pidlist *cgroup_pid
> =A0 =A0 =A0 =A0l =3D kmalloc(sizeof(struct cgroup_pidlist), GFP_KERNE=
L);
> =A0 =A0 =A0 =A0if (!l) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cgrp->pidlist_mutex);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid_ns(ns);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return l;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0init_rwsem(&l->mutex);
> =A0 =A0 =A0 =A0down_write(&l->mutex);
> =A0 =A0 =A0 =A0l->key.type =3D type;
> - =A0 =A0 =A0 l->key.ns =3D ns;
> + =A0 =A0 =A0 l->key.ns =3D get_pid_ns(ns);
> =A0 =A0 =A0 =A0l->use_count =3D 0; /* don't increment here */
> =A0 =A0 =A0 =A0l->list =3D NULL;
> =A0 =A0 =A0 =A0l->owner =3D cgrp;
>
