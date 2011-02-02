From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH, v3 1/2] cgroups: export cgroup_iter_{start,next,end}
Date: Wed, 2 Feb 2011 13:21:03 -0800
Message-ID: <AANLkTimepM-TUXSvZh_15xNWf2P0TDEOatPTN7yT2uQe__20836.3651451238$1296681816$gmane$org@mail.gmail.com>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-2-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296679656-31163-2-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 2, 2011 at 12:47 PM, Kirill A. Shutsemov
<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
>
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0kernel/cgroup.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index b24d702..8234daa 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2443,6 +2443,7 @@ void cgroup_iter_start(struct cgroup *cgrp, struct =
cgroup_iter *it)
> =A0 =A0 =A0 =A0it->cg_link =3D &cgrp->css_sets;
> =A0 =A0 =A0 =A0cgroup_advance_iter(cgrp, it);
> =A0}
> +EXPORT_SYMBOL_GPL(cgroup_iter_start);
>
> =A0struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct cgroup_iter *it)
> @@ -2467,11 +2468,13 @@ struct task_struct *cgroup_iter_next(struct cgrou=
p *cgrp,
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return res;
> =A0}
> +EXPORT_SYMBOL_GPL(cgroup_iter_next);
>
> =A0void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it)
> =A0{
> =A0 =A0 =A0 =A0read_unlock(&css_set_lock);
> =A0}
> +EXPORT_SYMBOL_GPL(cgroup_iter_end);
>
> =A0static inline int started_after_time(struct task_struct *t1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s=
truct timespec *time,
> --
> 1.7.3.5
>
>
