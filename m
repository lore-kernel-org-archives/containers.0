From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: notify ns_cgroup deprecated
Date: Wed, 29 Sep 2010 16:30:55 -0700
Message-ID: <AANLkTikCnAJKZUYyJvQp64a8p4MLJV_aBTO=pn14aVO6@mail.gmail.com>
References: <1285795301-2684-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285795301-2684-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 29, 2010 at 2:21 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wr=
ote:
> The ns_cgroup will be removed very soon. Let's warn, for this
> version, ns_cgroup is deprecated.
>
> Make ns_cgroup and clone_children exclusive. If the clone_children
> is set and the ns_cgroup is mounted, let's fail with EINVAL when
> the ns_cgroup subsys is created (a printk will help the user to
> understand why the creation fails).
>
> Update the feature remove schedule file with the deprecated ns_cgroup.
>
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0Documentation/feature-removal-schedule.txt | =A0 17 +++++++++++++++++
> =A0kernel/ns_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A08 ++++++++
> =A02 files changed, 25 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/f=
eature-removal-schedule.txt
> index b32911b..a39e2f3 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -545,4 +545,21 @@ Why: =A0 =A0This is a legacy interface which have be=
en replaced by a more
> =A0Who: =A0 =A0NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
>
> =A0----------------------------
> +
> +What: =A0 namespace cgroup (ns_cgroup)
> +When: =A0 2.6.38
> +Why: =A0 =A0The ns_cgroup leads to some problems:
> + =A0 =A0 =A0 * cgroup creation is out-of-control
> + =A0 =A0 =A0 * cgroup name can conflict when pids are looping
> + =A0 =A0 =A0 * it is not possible to have a single process handling
> + =A0 =A0 =A0 a lot of namespaces without falling in a exponential creati=
on time
> + =A0 =A0 =A0 * we may want to create a namespace without creating a cgro=
up
> +
> + =A0 =A0 =A0 The ns_cgroup is replaced by a compatibility flag 'clone_ch=
ildren',
> + =A0 =A0 =A0 where a newly created cgroup will copy the parent cgroup va=
lues.
> + =A0 =A0 =A0 The userspace has to manually create a cgroup and add a tas=
k to
> + =A0 =A0 =A0 the 'tasks' file.
> +Who: =A0 =A0Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> +
> +----------------------------
>
> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
> index 2a5dfec..2c98ad9 100644
> --- a/kernel/ns_cgroup.c
> +++ b/kernel/ns_cgroup.c
> @@ -85,6 +85,14 @@ static struct cgroup_subsys_state *ns_create(struct cg=
roup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-EPERM);
> =A0 =A0 =A0 =A0if (!cgroup_is_descendant(cgroup, current))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-EPERM);
> + =A0 =A0 =A0 if (test_bit(CGRP_CLONE_CHILDREN, &cgroup->flags)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("ns_cgroup can't be created with par=
ent "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"'clone_children' set.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 printk_once("ns_cgroup deprecated: consider using the "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "'clone_children' flag without the =
ns_cgroup.\n");
>
> =A0 =A0 =A0 =A0ns_cgroup =3D kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!ns_cgroup)
> --
> 1.7.0.4
>
>
