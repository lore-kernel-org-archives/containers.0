From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: consolidate cgroup documents
Date: Fri, 9 Jan 2009 13:19:30 -0800
Message-ID: <6599ad830901091319v405fd0do1424c737e8cb097__25427.0702986561$1231536087$gmane$org@mail.gmail.com>
References: <4966B383.3030106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4966B383.3030106-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 8, 2009 at 6:16 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Move Documentation/cpusets.txt and Documentation/controllers/* to
> Documentation/cgroups/
>
> This inlined patch is generated with git-show -M (rename detected)
> and is for review, and the attached one is for apply.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks.

> ---
>  Documentation/cgroups/cgroups.txt            |    5 +++--
>  Documentation/cgroups/memcg_test.txt         |    2 +-
>  Documentation/scheduler/sched-design-CFS.txt |    2 +-
>  include/linux/res_counter.h                  |    2 +-
>  init/Kconfig                                 |    9 ++++-----
>  kernel/cpuset.c                              |    2 +-
>  11 files changed, 11 insertions(+), 11 deletions(-)
>
>  rename Documentation/{controllers => cgroups}/cpuacct.txt (100%)
>  rename Documentation/{ => cgroups}/cpusets.txt (100%)
>  rename Documentation/{controllers => cgroups}/devices.txt (100%)
>  rename Documentation/{controllers => cgroups}/memcg_test.txt (99%)
>  rename Documentation/{controllers => cgroups}/memory.txt (100%)
>  rename Documentation/{controllers => cgroups}/resource_counter.txt (100%)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index e33ee74..d9e5d6f 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -1,7 +1,8 @@
>                                CGROUPS
>                                -------
>
> -Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on Documentation/cpusets.txt
> +Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on
> +Documentation/cgroups/cpusets.txt
>
>  Original copyright statements from cpusets.txt:
>  Portions Copyright (C) 2004 BULL SA.
> @@ -68,7 +69,7 @@ On their own, the only use for cgroups is for simple job
>  tracking. The intention is that other subsystems hook into the generic
>  cgroup support to provide new attributes for cgroups, such as
>  accounting/limiting the resources which processes in a cgroup can
> -access. For example, cpusets (see Documentation/cpusets.txt) allows
> +access. For example, cpusets (see Documentation/cgroups/cpusets.txt) allows
>  you to associate a set of CPUs and a set of memory nodes with the
>  tasks in each cgroup.
>
> diff --git a/Documentation/controllers/cpuacct.txt b/Documentation/cgroups/cpuacct.txt
> similarity index 100%
> rename from Documentation/controllers/cpuacct.txt
> rename to Documentation/cgroups/cpuacct.txt
> diff --git a/Documentation/cpusets.txt b/Documentation/cgroups/cpusets.txt
> similarity index 100%
> rename from Documentation/cpusets.txt
> rename to Documentation/cgroups/cpusets.txt
> diff --git a/Documentation/controllers/devices.txt b/Documentation/cgroups/devices.txt
> similarity index 100%
> rename from Documentation/controllers/devices.txt
> rename to Documentation/cgroups/devices.txt
> diff --git a/Documentation/controllers/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> similarity index 99%
> rename from Documentation/controllers/memcg_test.txt
> rename to Documentation/cgroups/memcg_test.txt
> index 08d4d3e..19533f9 100644
> --- a/Documentation/controllers/memcg_test.txt
> +++ b/Documentation/cgroups/memcg_test.txt
> @@ -6,7 +6,7 @@ Because VM is getting complex (one of reasons is memcg...), memcg's behavior
>  is complex. This is a document for memcg's internal behavior.
>  Please note that implementation details can be changed.
>
> -(*) Topics on API should be in Documentation/controllers/memory.txt)
> +(*) Topics on API should be in Documentation/cgroups/memory.txt)
>
>  0. How to record usage ?
>    2 objects are used.
> diff --git a/Documentation/controllers/memory.txt b/Documentation/cgroups/memory.txt
> similarity index 100%
> rename from Documentation/controllers/memory.txt
> rename to Documentation/cgroups/memory.txt
> diff --git a/Documentation/controllers/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
> similarity index 100%
> rename from Documentation/controllers/resource_counter.txt
> rename to Documentation/cgroups/resource_counter.txt
> diff --git a/Documentation/scheduler/sched-design-CFS.txt b/Documentation/scheduler/sched-design-CFS.txt
> index 8398ca4..6f33593 100644
> --- a/Documentation/scheduler/sched-design-CFS.txt
> +++ b/Documentation/scheduler/sched-design-CFS.txt
> @@ -231,7 +231,7 @@ CPU bandwidth control purposes:
>
>    This options needs CONFIG_CGROUPS to be defined, and lets the administrator
>    create arbitrary groups of tasks, using the "cgroup" pseudo filesystem.  See
> -   Documentation/cgroups.txt for more information about this filesystem.
> +   Documentation/cgroups/cgroups.txt for more information about this filesystem.
>
>  Only one of these options to group tasks can be chosen and not both.
>
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index dede0a2..4c5bcf6 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -9,7 +9,7 @@
>  *
>  * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>  *
> - * See Documentation/controllers/resource_counter.txt for more
> + * See Documentation/cgroups/resource_counter.txt for more
>  * info about what this counter is.
>  */
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 56fd93c..2af8382 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -323,8 +323,8 @@ config CGROUP_SCHED
>          This option allows you to create arbitrary task groups
>          using the "cgroup" pseudo filesystem and control
>          the cpu bandwidth allocated to each such task group.
> -         Refer to Documentation/cgroups.txt for more information
> -         on "cgroup" pseudo filesystem.
> +         Refer to Documentation/cgroups/cgroups.txt for more
> +         information on "cgroup" pseudo filesystem.
>
>  endchoice
>
> @@ -335,10 +335,9 @@ menuconfig CGROUPS
>          use with process control subsystems such as Cpusets, CFS, memory
>          controls or device isolation.
>          See
> -               - Documentation/cpusets.txt     (Cpusets)
>                - Documentation/scheduler/sched-design-CFS.txt  (CFS)
> -               - Documentation/cgroups/ (features for grouping, isolation)
> -               - Documentation/controllers/ (features for resource control)
> +               - Documentation/cgroups/ (features for grouping, isolation
> +                                         and resource control)
>
>          Say N if unsure.
>
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 647c77a..a856788 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -568,7 +568,7 @@ update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
>  * load balancing domains (sched domains) as specified by that partial
>  * partition.
>  *
> - * See "What is sched_load_balance" in Documentation/cpusets.txt
> + * See "What is sched_load_balance" in Documentation/cgroups/cpusets.txt
>  * for a background explanation of this.
>  *
>  * Does not return errors, on the theory that the callers of this
>
