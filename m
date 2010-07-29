From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup : remove the ns_cgroup
Date: Thu, 29 Jul 2010 14:46:57 -0700
Message-ID: <AANLkTi=WbUiW=UroQ0JYM+kji4YPvkMgTXmdvFg-1yLg__11543.1297956549$1280440171$gmane$org@mail.gmail.com>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100729195812.GB19015-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 29, 2010 at 12:58 PM, Serge E. Hallyn
<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier.
>
> For example, a single process can not handle a big amount of namespaces
> without interacting with this cgroup and falling in an exponential creati=
on
> time due to the nested cgroup directory depth (eg. /cgroup/<pid>/.../<pid=
>/...).
>
> That was spotted when creating a single process using multiple network na=
mespaces,
> the objective was 4096 network namespaces, but at 820 netns, the creation=
 time
> was dramatically slow and the creation time for a namespace increased fro=
m 10msec
> to 10sec. After five hours, the expected numbers of netns was not reached.
> Without the ns_cgroup interaction, 4K netns are created after 2 minutes.
>
> In order to solve that, we have to mount the cgroup with all the subsyste=
ms
> except the ns_cgroup, it's a little weird and hard to manage from an admi=
nistration
> pov because we have to know what are the cgroup available on the system a=
nd we
> can't do a simple 'mount -t cgroup cgroup /cgroup'.
>
> With the previous patch which adds a 'clone_children' parameter to a cgro=
up,
> we should be able to remove the ns_cgroup and manage manually the creatio=
n +
> adding a task to the cgroup consistenly with the rest of the subsystems.
>
> This patch removes the ns_cgroup as suggested in the following thread:
>
> https://lists.linux-foundation.org/pipermail/containers/2009-June/018616.=
html
>
> The 'cgroup_clone' function is removed because it is no longer used.
>
> Changelog: Jul 29 (seh): remove references to ns_cgroup_clone(), fix up
> =A0 =A0 =A0 =A0 =A0 some documentation, and remove CONFIG_CGROUP_NS refer=
ences.
>
> Signed-off-by: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks

> ---
> =A0Documentation/cgroups/cgroups.txt =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0arch/ia64/configs/generic_defconfig =A0 =A0 =A0| =A0 =A01 -
> =A0arch/mips/configs/bcm47xx_defconfig =A0 =A0 =A0| =A0 =A01 -
> =A0arch/mips/configs/ip27_defconfig =A0 =A0 =A0 =A0 | =A0 =A01 -
> =A0arch/mips/configs/sb1250-swarm_defconfig | =A0 =A01 -
> =A0arch/powerpc/configs/cell_defconfig =A0 =A0 =A0| =A0 =A01 -
> =A0arch/powerpc/configs/ppc64_defconfig =A0 =A0 | =A0 =A01 -
> =A0arch/powerpc/configs/ppc64e_defconfig =A0 =A0| =A0 =A01 -
> =A0arch/powerpc/configs/ppc6xx_defconfig =A0 =A0| =A0 =A01 -
> =A0arch/powerpc/configs/pseries_defconfig =A0 | =A0 =A01 -
> =A0arch/s390/defconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
=A01 -
> =A0arch/sh/configs/sdk7786_defconfig =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0arch/sh/configs/se7206_defconfig =A0 =A0 =A0 =A0 | =A0 =A01 -
> =A0arch/sh/configs/sh7724_generic_defconfig | =A0 =A01 -
> =A0arch/sh/configs/sh7770_generic_defconfig | =A0 =A01 -
> =A0arch/sh/configs/shx3_defconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A01 -
> =A0arch/sh/configs/urquell_defconfig =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0arch/x86/configs/i386_defconfig =A0 =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0arch/x86/configs/x86_64_defconfig =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0include/linux/cgroup.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 -
> =A0include/linux/cgroup_subsys.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 --
> =A0include/linux/nsproxy.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 =
---
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A09 ---
> =A0kernel/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 -
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0116 ------------------------------
> =A0kernel/cpuset.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A07 +-
> =A0kernel/fork.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A06 --
> =A0kernel/ns_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A011=
0 ----------------------------
> =A0kernel/nsproxy.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A04 -
> =A029 files changed, 4 insertions(+), 287 deletions(-)
> =A0delete mode 100644 kernel/ns_cgroup.c
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index 190018b..6a5ba63 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -618,7 +618,7 @@ always handled well.
> =A0void post_clone(struct cgroup_subsys *ss, struct cgroup *cgrp)
> =A0(cgroup_mutex held by caller)
>
> -Called at the end of cgroup_clone() to do any parameter
> +Called during cgroup_create() to do any parameter
> =A0initialization which might be required before a task could attach. =A0=
For
> =A0example in cpusets, no task may attach before 'cpus' and 'mems' are set
> =A0up.
> diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/gene=
ric_defconfig
> index 6a4cc50..d257546 100644
> --- a/arch/ia64/configs/generic_defconfig
> +++ b/arch/ia64/configs/generic_defconfig
> @@ -25,7 +25,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D20
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm4=
7xx_defconfig
> index bbd826b..cb75ade 100644
> --- a/arch/mips/configs/bcm47xx_defconfig
> +++ b/arch/mips/configs/bcm47xx_defconfig
> @@ -199,7 +199,6 @@ CONFIG_TINY_RCU=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/mips/configs/ip27_defconfig b/arch/mips/configs/ip27_de=
fconfig
> index 84b6503..036ad3e 100644
> --- a/arch/mips/configs/ip27_defconfig
> +++ b/arch/mips/configs/ip27_defconfig
> @@ -209,7 +209,6 @@ CONFIG_LOG_BUF_SHIFT=3D15
> =A0# CONFIG_GROUP_SCHED is not set
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/mips/configs/sb1250-swarm_defconfig b/arch/mips/configs=
/sb1250-swarm_defconfig
> index 7f07bf0..0f059f2 100644
> --- a/arch/mips/configs/sb1250-swarm_defconfig
> +++ b/arch/mips/configs/sb1250-swarm_defconfig
> @@ -197,7 +197,6 @@ CONFIG_SYSVIPC_SYSCTL=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D15
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0CONFIG_CPUSETS=3Dy
> =A0CONFIG_GROUP_SCHED=3Dy
> =A0CONFIG_FAIR_GROUP_SCHED=3Dy
> diff --git a/arch/powerpc/configs/cell_defconfig b/arch/powerpc/configs/c=
ell_defconfig
> index 9433719..cfa9177 100644
> --- a/arch/powerpc/configs/cell_defconfig
> +++ b/arch/powerpc/configs/cell_defconfig
> @@ -76,7 +76,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D15
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0CONFIG_CPUSETS=3Dy
> =A0# CONFIG_GROUP_SCHED is not set
> =A0# CONFIG_USER_SCHED is not set
> diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/=
ppc64_defconfig
> index 369f4e0..2bc8f44 100644
> --- a/arch/powerpc/configs/ppc64_defconfig
> +++ b/arch/powerpc/configs/ppc64_defconfig
> @@ -86,7 +86,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/powerpc/configs/ppc64e_defconfig b/arch/powerpc/configs=
/ppc64e_defconfig
> index 403e82e..ac0f13d 100644
> --- a/arch/powerpc/configs/ppc64e_defconfig
> +++ b/arch/powerpc/configs/ppc64e_defconfig
> @@ -100,7 +100,6 @@ CONFIG_LOG_BUF_SHIFT=3D17
> =A0# CONFIG_GROUP_SCHED is not set
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs=
/ppc6xx_defconfig
> index 12dc7c4..8175eba 100644
> --- a/arch/powerpc/configs/ppc6xx_defconfig
> +++ b/arch/powerpc/configs/ppc6xx_defconfig
> @@ -88,7 +88,6 @@ CONFIG_AUDIT_TREE=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0CONFIG_GROUP_SCHED=3Dy
> diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/config=
s/pseries_defconfig
> index 16ae717..6d96b61 100644
> --- a/arch/powerpc/configs/pseries_defconfig
> +++ b/arch/powerpc/configs/pseries_defconfig
> @@ -85,7 +85,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/s390/defconfig b/arch/s390/defconfig
> index 253f158..08e9f82 100644
> --- a/arch/s390/defconfig
> +++ b/arch/s390/defconfig
> @@ -72,7 +72,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/sh/configs/sdk7786_defconfig b/arch/sh/configs/sdk7786_=
defconfig
> index 2698245..0f6894e 100644
> --- a/arch/sh/configs/sdk7786_defconfig
> +++ b/arch/sh/configs/sdk7786_defconfig
> @@ -84,7 +84,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0CONFIG_CGROUP_DEBUG=3Dy
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/sh/configs/se7206_defconfig b/arch/sh/configs/se7206_de=
fconfig
> index 910eaec..d2c0fc8 100644
> --- a/arch/sh/configs/se7206_defconfig
> +++ b/arch/sh/configs/se7206_defconfig
> @@ -77,7 +77,6 @@ CONFIG_TREE_RCU_TRACE=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D14
> =A0CONFIG_CGROUPS=3Dy
> =A0CONFIG_CGROUP_DEBUG=3Dy
> -CONFIG_CGROUP_NS=3Dy
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/sh/configs/sh7724_generic_defconfig b/arch/sh/configs/s=
h7724_generic_defconfig
> index a6a9e68..c3a2f67 100644
> --- a/arch/sh/configs/sh7724_generic_defconfig
> +++ b/arch/sh/configs/sh7724_generic_defconfig
> @@ -70,7 +70,6 @@ CONFIG_RCU_FANOUT=3D32
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/sh/configs/sh7770_generic_defconfig b/arch/sh/configs/s=
h7770_generic_defconfig
> index 4327f89..ce2357f 100644
> --- a/arch/sh/configs/sh7770_generic_defconfig
> +++ b/arch/sh/configs/sh7770_generic_defconfig
> @@ -69,7 +69,6 @@ CONFIG_RCU_FANOUT=3D32
> =A0CONFIG_LOG_BUF_SHIFT=3D17
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -# CONFIG_CGROUP_NS is not set
> =A0# CONFIG_CGROUP_FREEZER is not set
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/sh/configs/shx3_defconfig b/arch/sh/configs/shx3_defcon=
fig
> index 42f6bd3..05ced6a 100644
> --- a/arch/sh/configs/shx3_defconfig
> +++ b/arch/sh/configs/shx3_defconfig
> @@ -84,7 +84,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D14
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0# CONFIG_CPUSETS is not set
> diff --git a/arch/sh/configs/urquell_defconfig b/arch/sh/configs/urquell_=
defconfig
> index 28bb19d..e698dff 100644
> --- a/arch/sh/configs/urquell_defconfig
> +++ b/arch/sh/configs/urquell_defconfig
> @@ -82,7 +82,6 @@ CONFIG_IKCONFIG_PROC=3Dy
> =A0CONFIG_LOG_BUF_SHIFT=3D14
> =A0CONFIG_CGROUPS=3Dy
> =A0CONFIG_CGROUP_DEBUG=3Dy
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0CONFIG_CGROUP_DEVICE=3Dy
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defc=
onfig
> index d28fad1..4428d5c 100644
> --- a/arch/x86/configs/i386_defconfig
> +++ b/arch/x86/configs/i386_defconfig
> @@ -105,7 +105,6 @@ CONFIG_FAIR_GROUP_SCHED=3Dy
> =A0CONFIG_CGROUP_SCHED=3Dy
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_=
defconfig
> index 6c86acd..2ff947f 100644
> --- a/arch/x86/configs/x86_64_defconfig
> +++ b/arch/x86/configs/x86_64_defconfig
> @@ -105,7 +105,6 @@ CONFIG_FAIR_GROUP_SCHED=3Dy
> =A0CONFIG_CGROUP_SCHED=3Dy
> =A0CONFIG_CGROUPS=3Dy
> =A0# CONFIG_CGROUP_DEBUG is not set
> -CONFIG_CGROUP_NS=3Dy
> =A0CONFIG_CGROUP_FREEZER=3Dy
> =A0# CONFIG_CGROUP_DEVICE is not set
> =A0CONFIG_CPUSETS=3Dy
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index f3cbd73..ddbdb77 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -552,9 +552,6 @@ static inline struct cgroup* task_cgroup(struct task_=
struct *task,
> =A0 =A0 =A0 =A0return task_subsys_state(task, subsys_id)->cgroup;
> =A0}
>
> -int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *nodename);
> -
> =A0/* A cgroup_iter should be treated as an opaque object */
> =A0struct cgroup_iter {
> =A0 =A0 =A0 =A0struct list_head *cg_link;
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index ccefff0..4ba5259 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -19,12 +19,6 @@ SUBSYS(debug)
>
> =A0/* */
>
> -#ifdef CONFIG_CGROUP_NS
> -SUBSYS(ns)
> -#endif
> -
> -/* */
> -
> =A0#ifdef CONFIG_CGROUP_SCHED
> =A0SUBSYS(cpu_cgroup)
> =A0#endif
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 7b370c7..50d20ab 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -81,13 +81,4 @@ static inline void get_nsproxy(struct nsproxy *ns)
> =A0 =A0 =A0 =A0atomic_inc(&ns->count);
> =A0}
>
> -#ifdef CONFIG_CGROUP_NS
> -int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid);
> -#else
> -static inline int ns_cgroup_clone(struct task_struct *tsk, struct pid *p=
id)
> -{
> - =A0 =A0 =A0 return 0;
> -}
> -#endif
> -
> =A0#endif
> diff --git a/init/Kconfig b/init/Kconfig
> index 5cff9a9..1124656 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -496,15 +496,6 @@ config CGROUP_DEBUG
>
> =A0 =A0 =A0 =A0 =A0Say N if unsure.
>
> -config CGROUP_NS
> - =A0 =A0 =A0 bool "Namespace cgroup subsystem"
> - =A0 =A0 =A0 depends on CGROUPS
> - =A0 =A0 =A0 help
> - =A0 =A0 =A0 =A0 Provides a simple namespace cgroup subsystem to
> - =A0 =A0 =A0 =A0 provide hierarchical naming of sets of namespaces,
> - =A0 =A0 =A0 =A0 for instance virtual servers and checkpoint/restart
> - =A0 =A0 =A0 =A0 jobs.
> -
> =A0config CGROUP_FREEZER
> =A0 =A0 =A0 =A0bool "Freezer cgroup subsystem"
> =A0 =A0 =A0 =A0depends on CGROUPS
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 057472f..a7ee5f4 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -62,7 +62,6 @@ obj-$(CONFIG_COMPAT) +=3D compat.o
> =A0obj-$(CONFIG_CGROUPS) +=3D cgroup.o
> =A0obj-$(CONFIG_CGROUP_FREEZER) +=3D cgroup_freezer.o
> =A0obj-$(CONFIG_CPUSETS) +=3D cpuset.o
> -obj-$(CONFIG_CGROUP_NS) +=3D ns_cgroup.o
> =A0obj-$(CONFIG_UTS_NS) +=3D utsname.o
> =A0obj-$(CONFIG_USER_NS) +=3D user_namespace.o
> =A0obj-$(CONFIG_PID_NS) +=3D pid_namespace.o
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 09fb6f9..7ec5bad 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4212,122 +4212,6 @@ void cgroup_exit(struct task_struct *tsk, int run=
_callbacks)
> =A0}
>
> =A0/**
> - * cgroup_clone - clone the cgroup the given subsystem is attached to
> - * @tsk: the task to be moved
> - * @subsys: the given subsystem
> - * @nodename: the name for the new cgroup
> - *
> - * Duplicate the current cgroup in the hierarchy that the given
> - * subsystem is attached to, and move this task into the new
> - * child.
> - */
> -int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *nodename)
> -{
> - =A0 =A0 =A0 struct dentry *dentry;
> - =A0 =A0 =A0 int ret =3D 0;
> - =A0 =A0 =A0 struct cgroup *parent, *child;
> - =A0 =A0 =A0 struct inode *inode;
> - =A0 =A0 =A0 struct css_set *cg;
> - =A0 =A0 =A0 struct cgroupfs_root *root;
> - =A0 =A0 =A0 struct cgroup_subsys *ss;
> -
> - =A0 =A0 =A0 /* We shouldn't be called by an unregistered subsystem */
> - =A0 =A0 =A0 BUG_ON(!subsys->active);
> -
> - =A0 =A0 =A0 /* First figure out what hierarchy and cgroup we're dealing
> - =A0 =A0 =A0 =A0* with, and pin them so we can drop cgroup_mutex */
> - =A0 =A0 =A0 mutex_lock(&cgroup_mutex);
> - again:
> - =A0 =A0 =A0 root =3D subsys->root;
> - =A0 =A0 =A0 if (root =3D=3D &rootnode) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cgroup_mutex);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* Pin the hierarchy */
> - =A0 =A0 =A0 if (!atomic_inc_not_zero(&root->sb->s_active)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We race with the final deactivate_super(=
) */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cgroup_mutex);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* Keep the cgroup alive */
> - =A0 =A0 =A0 task_lock(tsk);
> - =A0 =A0 =A0 parent =3D task_cgroup(tsk, subsys->subsys_id);
> - =A0 =A0 =A0 cg =3D tsk->cgroups;
> - =A0 =A0 =A0 get_css_set(cg);
> - =A0 =A0 =A0 task_unlock(tsk);
> -
> - =A0 =A0 =A0 mutex_unlock(&cgroup_mutex);
> -
> - =A0 =A0 =A0 /* Now do the VFS work to create a cgroup */
> - =A0 =A0 =A0 inode =3D parent->dentry->d_inode;
> -
> - =A0 =A0 =A0 /* Hold the parent directory mutex across this operation to
> - =A0 =A0 =A0 =A0* stop anyone else deleting the new cgroup */
> - =A0 =A0 =A0 mutex_lock(&inode->i_mutex);
> - =A0 =A0 =A0 dentry =3D lookup_one_len(nodename, parent->dentry, strlen(=
nodename));
> - =A0 =A0 =A0 if (IS_ERR(dentry)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"cgroup: Couldn't allocate d=
entry for %s: %ld\n", nodename,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PTR_ERR(dentry));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D PTR_ERR(dentry);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_release;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* Create the cgroup directory, which also creates the cgro=
up */
> - =A0 =A0 =A0 ret =3D vfs_mkdir(inode, dentry, 0755);
> - =A0 =A0 =A0 child =3D __d_cgrp(dentry);
> - =A0 =A0 =A0 dput(dentry);
> - =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Failed to create cgroup %s:=
 %d\n", nodename,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_release;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* The cgroup now exists. Retake cgroup_mutex and check
> - =A0 =A0 =A0 =A0* that we're still in the same state that we thought we
> - =A0 =A0 =A0 =A0* were. */
> - =A0 =A0 =A0 mutex_lock(&cgroup_mutex);
> - =A0 =A0 =A0 if ((root !=3D subsys->root) ||
> - =A0 =A0 =A0 =A0 =A0 (parent !=3D task_cgroup(tsk, subsys->subsys_id))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Aargh, we raced ... */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&inode->i_mutex);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(cg);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 deactivate_super(root->sb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The cgroup is still accessible in the VF=
S, but
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we're not going to try to rmdir() it a=
t this
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* point. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Race in cgroup_clone() - le=
aking cgroup %s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nodename);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto again;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* do any required auto-setup */
> - =A0 =A0 =A0 for_each_subsys(root, ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->post_clone)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->post_clone(ss, child);
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* All seems fine. Finish by moving the task into the new c=
group */
> - =A0 =A0 =A0 ret =3D cgroup_attach_task(child, tsk);
> - =A0 =A0 =A0 mutex_unlock(&cgroup_mutex);
> -
> - out_release:
> - =A0 =A0 =A0 mutex_unlock(&inode->i_mutex);
> -
> - =A0 =A0 =A0 mutex_lock(&cgroup_mutex);
> - =A0 =A0 =A0 put_css_set(cg);
> - =A0 =A0 =A0 mutex_unlock(&cgroup_mutex);
> - =A0 =A0 =A0 deactivate_super(root->sb);
> - =A0 =A0 =A0 return ret;
> -}
> -
> -/**
> =A0* cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
> =A0* @cgrp: the cgroup in question
> =A0* @task: the task in question
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 02b9611..4613840 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1829,10 +1829,9 @@ static int cpuset_populate(struct cgroup_subsys *s=
s, struct cgroup *cont)
> =A0}
>
> =A0/*
> - * post_clone() is called at the end of cgroup_clone().
> - * 'cgroup' was just created automatically as a result of
> - * a cgroup_clone(), and the current task is about to
> - * be moved into 'cgroup'.
> + * post_clone() is called during cgroup_create() when the
> + * clone_children mount argument was specified. =A0The cgroup
> + * can not yet have any tasks.
> =A0*
> =A0* Currently we refuse to set up the cgroup - thereby
> =A0* refusing the task to be entered, and as a result refusing
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b6cce14..c391b1d 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1167,12 +1167,6 @@ static struct task_struct *copy_process(unsigned l=
ong clone_flags,
> =A0 =A0 =A0 =A0if (clone_flags & CLONE_THREAD)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->tgid =3D current->tgid;
>
> - =A0 =A0 =A0 if (current->nsproxy !=3D p->nsproxy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ns_cgroup_clone(p, pid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_fork_free_pid;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0p->set_child_tid =3D (clone_flags & CLONE_CHILD_SETTID) ? =
child_tidptr : NULL;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Clear TID on mm_release()?
> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
> deleted file mode 100644
> index 2a5dfec..0000000
> --- a/kernel/ns_cgroup.c
> +++ /dev/null
> @@ -1,110 +0,0 @@
> -/*
> - * ns_cgroup.c - namespace cgroup subsystem
> - *
> - * Copyright 2006, 2007 IBM Corp
> - */
> -
> -#include <linux/module.h>
> -#include <linux/cgroup.h>
> -#include <linux/fs.h>
> -#include <linux/proc_fs.h>
> -#include <linux/slab.h>
> -#include <linux/nsproxy.h>
> -
> -struct ns_cgroup {
> - =A0 =A0 =A0 struct cgroup_subsys_state css;
> -};
> -
> -struct cgroup_subsys ns_subsys;
> -
> -static inline struct ns_cgroup *cgroup_to_ns(
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgroup)
> -{
> - =A0 =A0 =A0 return container_of(cgroup_subsys_state(cgroup, ns_subsys_i=
d),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ns_cgroup, c=
ss);
> -}
> -
> -int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
> -{
> - =A0 =A0 =A0 char name[PROC_NUMBUF];
> -
> - =A0 =A0 =A0 snprintf(name, PROC_NUMBUF, "%d", pid_vnr(pid));
> - =A0 =A0 =A0 return cgroup_clone(task, &ns_subsys, name);
> -}
> -
> -/*
> - * Rules:
> - * =A0 1. you can only enter a cgroup which is a descendant of your curr=
ent
> - * =A0 =A0 cgroup
> - * =A0 2. you can only place another process into a cgroup if
> - * =A0 =A0 a. you have CAP_SYS_ADMIN
> - * =A0 =A0 b. your cgroup is an ancestor of task's destination cgroup
> - * =A0 =A0 =A0 (hence either you are in the same cgroup as task, or in an
> - * =A0 =A0 =A0 =A0ancestor cgroup thereof)
> - */
> -static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cg=
roup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct *task=
, bool threadgroup)
> -{
> - =A0 =A0 =A0 if (current !=3D task) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_ADMIN))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cgroup_is_descendant(new_cgroup, curre=
nt))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 if (!cgroup_is_descendant(new_cgroup, task))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> -
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &task->thread_gr=
oup, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cgroup_is_descendant(n=
ew_cgroup, c)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_un=
lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPE=
RM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return 0;
> -}
> -
> -/*
> - * Rules: you can only create a cgroup if
> - * =A0 =A0 1. you are capable(CAP_SYS_ADMIN)
> - * =A0 =A0 2. the target cgroup is a descendant of your own cgroup
> - */
> -static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgroup)
> -{
> - =A0 =A0 =A0 struct ns_cgroup *ns_cgroup;
> -
> - =A0 =A0 =A0 if (!capable(CAP_SYS_ADMIN))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EPERM);
> - =A0 =A0 =A0 if (!cgroup_is_descendant(cgroup, current))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EPERM);
> -
> - =A0 =A0 =A0 ns_cgroup =3D kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
> - =A0 =A0 =A0 if (!ns_cgroup)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> - =A0 =A0 =A0 return &ns_cgroup->css;
> -}
> -
> -static void ns_destroy(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgroup)
> -{
> - =A0 =A0 =A0 struct ns_cgroup *ns_cgroup;
> -
> - =A0 =A0 =A0 ns_cgroup =3D cgroup_to_ns(cgroup);
> - =A0 =A0 =A0 kfree(ns_cgroup);
> -}
> -
> -struct cgroup_subsys ns_subsys =3D {
> - =A0 =A0 =A0 .name =3D "ns",
> - =A0 =A0 =A0 .can_attach =3D ns_can_attach,
> - =A0 =A0 =A0 .create =3D ns_create,
> - =A0 =A0 =A0 .destroy =A0=3D ns_destroy,
> - =A0 =A0 =A0 .subsys_id =3D ns_subsys_id,
> -};
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index f74e6c0..014a90d 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -198,10 +198,6 @@ int unshare_nsproxy_namespaces(unsigned long unshare=
_flags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 err =3D ns_cgroup_clone(current, task_pid(current));
> - =A0 =A0 =A0 if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_nsproxy(*new_nsp);
> -
> =A0out:
> =A0 =A0 =A0 =A0return err;
> =A0}
> --
> 1.7.0.4
>
>
