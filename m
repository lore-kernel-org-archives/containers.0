From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3][V2] cgroup : add clone_children control file
Date: Wed, 29 Sep 2010 16:12:53 -0700
Message-ID: <AANLkTike-1CFhmzXimxPjOm57kyuL=NJaPjL2BqsjWgz@mail.gmail.com>
References: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>
	<1285582453-6127-2-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285582453-6127-2-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
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
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Sep 27, 2010 at 3:14 AM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wr=
ote:
>
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0Documentation/cgroups/cgroups.txt | =A0 14 +++++++++++-
> =A0include/linux/cgroup.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +++
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 39 +++++++++=
++++++++++++++++++++++++++++
> =A03 files changed, 55 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index b34823f..190018b 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -18,7 +18,8 @@ CONTENTS:
> =A0 1.2 Why are cgroups needed ?
> =A0 1.3 How are cgroups implemented ?
> =A0 1.4 What does notify_on_release do ?
> - =A01.5 How do I use cgroups ?
> + =A01.5 What does clone_children do ?
> + =A01.6 How do I use cgroups ?
> =A02. Usage Examples and Syntax
> =A0 2.1 Basic Usage
> =A0 2.2 Attaching processes
> @@ -293,7 +294,16 @@ notify_on_release in the root cgroup at system boot =
is disabled
> =A0value of their parents notify_on_release setting. The default value of
> =A0a cgroup hierarchy's release_agent path is empty.
>
> -1.5 How do I use cgroups ?
> +1.5 What does clone_children do ?
> +---------------------------------
> +
> +If the clone_children flag is enabled (1) in a cgroup, then all
> +cgroups created beneath will call the post_clone callbacks for each
> +subsystem of the newly created cgroup. Usually when this callback is
> +implemented for a subsystem, it copies the values of the parent
> +subsystem, this is the case for the cpuset.
> +
> +1.6 How do I use cgroups ?
> =A0--------------------------
>
> =A0To start a new job that is to be contained within a cgroup, using
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 709dfb9..ed4ba11 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -154,6 +154,10 @@ enum {
> =A0 =A0 =A0 =A0 * A thread in rmdir() is wating for this cgroup.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0CGRP_WAIT_ON_RMDIR,
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Clone cgroup values when creating a new child cgroup
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 CGRP_CLONE_CHILDREN,
> =A0};
>
> =A0/* which pidlist file are we talking about? */
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 7b69b8d..7b17c3e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -243,6 +243,11 @@ static int notify_on_release(const struct cgroup *cg=
rp)
> =A0 =A0 =A0 =A0return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
> =A0}
>
> +static int clone_children(const struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> +}
> +
> =A0/*
> =A0* for_each_subsys() allows you to iterate on each subsystem attached to
> =A0* an active hierarchy
> @@ -1039,6 +1044,8 @@ static int cgroup_show_options(struct seq_file *seq=
, struct vfsmount *vfs)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_puts(seq, ",noprefix");
> =A0 =A0 =A0 =A0if (strlen(root->release_agent_path))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_printf(seq, ",release_agent=3D%s", roo=
t->release_agent_path);
> + =A0 =A0 =A0 if (clone_children(&root->top_cgroup))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_puts(seq, ",clone_children");
> =A0 =A0 =A0 =A0if (strlen(root->name))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0seq_printf(seq, ",name=3D%s", root->name);
> =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
> @@ -1049,6 +1056,7 @@ struct cgroup_sb_opts {
> =A0 =A0 =A0 =A0unsigned long subsys_bits;
> =A0 =A0 =A0 =A0unsigned long flags;
> =A0 =A0 =A0 =A0char *release_agent;
> + =A0 =A0 =A0 bool clone_children;
> =A0 =A0 =A0 =A0char *name;
> =A0 =A0 =A0 =A0/* User explicitly requested empty subsystem */
> =A0 =A0 =A0 =A0bool none;
> @@ -1096,6 +1104,8 @@ static int parse_cgroupfs_options(char *data, struc=
t cgroup_sb_opts *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0opts->none =3D true;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (!strcmp(token, "noprefix")) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(ROOT_NOPREFIX, &op=
ts->flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (!strcmp(token, "clone_children")=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 opts->clone_children =3D tr=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (!strncmp(token, "release_agent=
=3D", 14)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Specifying two release =
agents is forbidden */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (opts->release_agent)
> @@ -1354,6 +1364,8 @@ static struct cgroupfs_root *cgroup_root_from_opts(=
struct cgroup_sb_opts *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strcpy(root->release_agent_path, opts->rel=
ease_agent);
> =A0 =A0 =A0 =A0if (opts->name)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strcpy(root->name, opts->name);
> + =A0 =A0 =A0 if (opts->clone_children)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CGRP_CLONE_CHILDREN, &root->top_cgr=
oup.flags);
> =A0 =A0 =A0 =A0return root;
> =A0}
>
> @@ -3172,6 +3184,23 @@ fail:
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +static u64 cgroup_clone_children_read(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct cftype *cft)
> +{
> + =A0 =A0 =A0 return clone_children(cgrp);
> +}
> +
> +static int cgroup_clone_children_write(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct cftype *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
u64 val)
> +{
> + =A0 =A0 =A0 if (val)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(CGRP_CLONE_CHILDREN, &cgrp->flags=
);
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0/*
> =A0* for the common functions, 'private' gives the type of file
> =A0*/
> @@ -3202,6 +3231,11 @@ static struct cftype files[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.write_string =3D cgroup_write_event_contr=
ol,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =3D S_IWUGO,
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "cgroup.clone_children",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D cgroup_clone_children_read,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D cgroup_clone_children_write,
> + =A0 =A0 =A0 },
> =A0};
>
> =A0static struct cftype cft_release_agent =3D {
> @@ -3331,6 +3365,9 @@ static long cgroup_create(struct cgroup *parent, st=
ruct dentry *dentry,
> =A0 =A0 =A0 =A0if (notify_on_release(parent))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->fla=
gs);
>
> + =A0 =A0 =A0 if (clone_children(parent))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> +
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys_state *css =3D ss->cr=
eate(ss, cgrp);
>
> @@ -3345,6 +3382,8 @@ static long cgroup_create(struct cgroup *parent, st=
ruct dentry *dentry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_d=
estroy;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* At error, ->destroy() callback has to f=
ree assigned ID. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clone_children(parent) && ss->post_clon=
e)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->post_clone(ss, cgrp);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0cgroup_lock_hierarchy(root);
> --
> 1.7.0.4
>
>
