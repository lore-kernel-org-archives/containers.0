From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7] cgroups: Warn if a bindable subsystem calls css_get()
Date: Thu, 28 Oct 2010 17:05:05 -0700
Message-ID: <AANLkTi=wS8aOuVQ-WBPGyP24oAigAqeZxKgAtpw8PnZY__8429.37368802286$1288310851$gmane$org@mail.gmail.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC14756.5010504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC14756.5010504-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Maybe re-title this patch to BUG() if a bindable subsystem calls css_get() ?

Paul

On Fri, Oct 22, 2010 at 1:12 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> For now bindable subsystems should not use css_get/put(), so warn
> on this misuse.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> =A0include/linux/cgroup.h | =A0 =A07 +++++--
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 =A03 +++
> =A02 files changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 1e4e1df..10e4e02 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -80,13 +80,15 @@ struct cgroup_subsys_state {
>
> =A0/* bits in struct cgroup_subsys_state flags field */
> =A0enum {
> - =A0 =A0 =A0 CSS_ROOT, /* This CSS is the root of the subsystem */
> - =A0 =A0 =A0 CSS_REMOVED, /* This CSS is dead */
> + =A0 =A0 =A0 CSS_ROOT, =A0 =A0 =A0 /* This CSS is the root of the subsys=
tem */
> + =A0 =A0 =A0 CSS_REMOVED, =A0 =A0/* This CSS is dead */
> + =A0 =A0 =A0 CSS_NO_GET, =A0 =A0 /* Forbid calling css_get/put() */
> =A0};
>
> =A0/* Caller must verify that the css is not for root cgroup */
> =A0static inline void __css_get(struct cgroup_subsys_state *css, int coun=
t)
> =A0{
> + =A0 =A0 =A0 BUG_ON(test_bit(CSS_NO_GET, &css->flags));
> =A0 =A0 =A0 =A0atomic_add(count, &css->refcnt);
> =A0}
>
> @@ -119,6 +121,7 @@ static inline bool css_tryget(struct cgroup_subsys_st=
ate *css)
> =A0{
> =A0 =A0 =A0 =A0if (test_bit(CSS_ROOT, &css->flags))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
> + =A0 =A0 =A0 BUG_ON(test_bit(CSS_NO_GET, &css->flags));
> =A0 =A0 =A0 =A0while (!atomic_inc_not_zero(&css->refcnt)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_bit(CSS_REMOVED, &css->flags))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 12c1f7c..88e265d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -936,6 +936,9 @@ static void init_cgroup_css(struct cgroup_subsys_stat=
e *css,
> =A0 =A0 =A0 =A0css->cgroup =3D cgrp;
> =A0 =A0 =A0 =A0atomic_set(&css->refcnt, 1);
> =A0 =A0 =A0 =A0css->flags =3D 0;
> + =A0 =A0 =A0 /* For now, a bindable subsystem should not call css_get/pu=
t(). */
> + =A0 =A0 =A0 if (ss->can_bind)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CSS_NO_GET, &css->flags);
> =A0 =A0 =A0 =A0css->id =3D NULL;
> =A0 =A0 =A0 =A0if (cgrp =3D=3D dummytop)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(CSS_ROOT, &css->flags);
> --
> 1.7.0.1
>
>
