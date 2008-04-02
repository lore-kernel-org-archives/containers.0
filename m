From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][patch 3/11][CFQ-cgroup] Introduce cgroup subsystem
Date: Wed, 2 Apr 2008 15:41:58 -0700
Message-ID: <6599ad830804021541s3c1e3197y77d87f63bf47e4b3__2765.04388680241$1207176939$gmane$org@mail.gmail.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>
	<008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 1, 2008 at 2:32 AM, Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org> wrote:
> This patch introduces a simple cgroup subsystem.
>  New cgroup subsystem is called cfq_cgroup.
>
>    Signed-off-by: Satoshi UCHIDA <uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
>
>  diff --git a/block/Makefile b/block/Makefile
>  index 5a43c7d..ea07b46 100644
>  --- a/block/Makefile
>  +++ b/block/Makefile
>  @@ -11,6 +11,7 @@ obj-$(CONFIG_IOSCHED_NOOP)    += noop-iosched.o
>   obj-$(CONFIG_IOSCHED_AS)       += as-iosched.o
>   obj-$(CONFIG_IOSCHED_DEADLINE) += deadline-iosched.o
>   obj-$(CONFIG_IOSCHED_CFQ)      += cfq-iosched.o
>  +obj-$(CONFIG_CGROUP_CFQ)       += cfq-cgroup.o
>
>   obj-$(CONFIG_BLK_DEV_IO_TRACE) += blktrace.o
>   obj-$(CONFIG_BLOCK_COMPAT)     += compat_ioctl.o
>  diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
>  new file mode 100644
>  index 0000000..cea2b92
>  --- /dev/null
>  +++ b/block/cfq-cgroup.c
>  @@ -0,0 +1,57 @@
>  +/*
>  + *  CFQ CGROUP disk scheduler.
>  + *
>  + *     This program is a wrapper program that is
>  + *     extend CFQ disk scheduler for handling
>  + *     cgroup subsystem.
>  + *
>  + *     This program is based on original CFQ code.
>  + *
>  + *  Copyright (C) 2008 Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
>  + *   and NEC Corp.
>  + */
>  +
>  +#include <linux/blkdev.h>
>  +#include <linux/cgroup.h>
>  +#include <linux/cfq-iosched.h>
>  +
>  +struct cfq_cgroup {
>  +       struct cgroup_subsys_state css;
>  +};
>  +
>  +
>  +static inline struct cfq_cgroup *cgroup_to_cfq_cgroup(struct cgroup *cont)
>  +{
>  +       return container_of(cgroup_subsys_state(cont, cfq_cgroup_subsys_id),
>  +                           struct cfq_cgroup, css);
>  +}
>  +
>  +static struct cgroup_subsys_state *
>  +cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  +{
>  +       struct cfq_cgroup *cfqc;
>  +
>  +       if (!capable(CAP_SYS_ADMIN))
>  +               return ERR_PTR(-EPERM);
>  +
>  +       if (!cgroup_is_descendant(cont))
>  +               return ERR_PTR(-EPERM);

What are these checks for? Cgroups already provides filesystem
permissions to control directory creation, and the "descendant" check
looks like it may have been cut/pasted from the nsproxy subsystem.


>  +
>  +       cfqc = kzalloc(sizeof(struct cfq_cgroup), GFP_KERNEL);
>  +       if (unlikely(!cfqc))
>  +               return ERR_PTR(-ENOMEM);
>  +
>  +       return &cfqc->css;
>  +}
>  +
>  +static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
>  +{
>  +       kfree(cgroup_to_cfq_cgroup(cont));
>  +}
>  +
>  +struct cgroup_subsys cfq_cgroup_subsys = {
>  +       .name = "cfq_cgroup",
>  +       .create = cfq_cgroup_create,
>  +       .destroy = cfq_cgroup_destroy,
>  +       .subsys_id = cfq_cgroup_subsys_id,
>  +};
>  diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
>  index 1ddebfc..5d2e991 100644
>  --- a/include/linux/cgroup_subsys.h
>  +++ b/include/linux/cgroup_subsys.h
>  @@ -42,3 +42,9 @@ SUBSYS(mem_cgroup)
>   #endif
>
>   /* */
>  +
>  +#ifdef CONFIG_CGROUP_CFQ
>  +SUBSYS(cfq_cgroup)
>  +#endif
>  +
>  +/* */

To fit with the convention for other subsystems, simply "cfq" would be
a better name than "cfq_cgroup". (Clearly it's a cgroup subsystem from
context).

Is this subsystem meant to allow you to control any device that uses
CFQ, or is it specific to disks? It would be nice to be able to allow
different groups have different guarantees on different disks.

Paul
