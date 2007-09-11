From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [-mm PATCH 1/9] Memory controller resource counters (v6)
Date: Mon, 10 Sep 2007 17:42:20 -0700
Message-ID: <6599ad830709101742k658234b4of59f14ef27e40d14@mail.gmail.com>
References: <20070817084228.26003.12568.sendpatchset@balbir-laptop>
	<20070817084238.26003.7733.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070817084238.26003.7733.sendpatchset@balbir-laptop>
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
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Balbir/Pavel,

As I mentioned to you directly at the kernel summit, I think it might
be cleaner to integrate resource counters more closely with control
groups. So rather than controllers such as the memory controller
having to create their own boilerplate cf_type structures and
read/write functions, it should be possible to just call a function
something like

control_group_add_rescounter(struct cgroup *cg, struct cgroup_subsys *ss,
                                             struct res_counter *res,
const char *name)

and have it handle all the userspace API. This would simplify the task
of keeping a consistent userspace API between different controllers
using the resource counter abstraction.

Paul


On 8/17/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> From: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>
> Introduce generic structures and routines for resource accounting.
>
> Each resource accounting container is supposed to aggregate it,
> container_subsystem_state and its resource-specific members within.
>
> Signed-off-by: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Signed-off-by: <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>
>  include/linux/res_counter.h |  102 +++++++++++++++++++++++++++++++++++++
>  init/Kconfig                |    7 ++
>  kernel/Makefile             |    1
>  kernel/res_counter.c        |  120 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 230 insertions(+)
>
> diff -puN /dev/null include/linux/res_counter.h
> --- /dev/null   2007-06-01 20:42:04.000000000 +0530
> +++ linux-2.6.23-rc2-mm2-balbir/include/linux/res_counter.h     2007-08-17 13:14:18.000000000 +0530
> @@ -0,0 +1,102 @@
> +#ifndef __RES_COUNTER_H__
> +#define __RES_COUNTER_H__
> +
> +/*
> + * Resource Counters
> + * Contain common data types and routines for resource accounting
> + *
> + * Copyright 2007 OpenVZ SWsoft Inc
> + *
> + * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + */
> +
> +#include <linux/container.h>
> +
> +/*
> + * The core object. the container that wishes to account for some
> + * resource may include this counter into its structures and use
> + * the helpers described beyond
> + */
> +
> +struct res_counter {
> +       /*
> +        * the current resource consumption level
> +        */
> +       unsigned long usage;
> +       /*
> +        * the limit that usage cannot exceed
> +        */
> +       unsigned long limit;
> +       /*
> +        * the number of unsuccessful attempts to consume the resource
> +        */
> +       unsigned long failcnt;
> +       /*
> +        * the lock to protect all of the above.
> +        * the routines below consider this to be IRQ-safe
> +        */
> +       spinlock_t lock;
> +};
> +
> +/*
> + * Helpers to interact with userspace
> + * res_counter_read/_write - put/get the specified fields from the
> + * res_counter struct to/from the user
> + *
> + * @counter:     the counter in question
> + * @member:  the field to work with (see RES_xxx below)
> + * @buf:     the buffer to opeate on,...
> + * @nbytes:  its size...
> + * @pos:     and the offset.
> + */
> +
> +ssize_t res_counter_read(struct res_counter *counter, int member,
> +               const char __user *buf, size_t nbytes, loff_t *pos);
> +ssize_t res_counter_write(struct res_counter *counter, int member,
> +               const char __user *buf, size_t nbytes, loff_t *pos);
> +
> +/*
> + * the field descriptors. one for each member of res_counter
> + */
> +
> +enum {
> +       RES_USAGE,
> +       RES_LIMIT,
> +       RES_FAILCNT,
> +};
> +
> +/*
> + * helpers for accounting
> + */
> +
> +void res_counter_init(struct res_counter *counter);
> +
> +/*
> + * charge - try to consume more resource.
> + *
> + * @counter: the counter
> + * @val: the amount of the resource. each controller defines its own
> + *       units, e.g. numbers, bytes, Kbytes, etc
> + *
> + * returns 0 on success and <0 if the counter->usage will exceed the
> + * counter->limit _locked call expects the counter->lock to be taken
> + */
> +
> +int res_counter_charge_locked(struct res_counter *counter, unsigned long val);
> +int res_counter_charge(struct res_counter *counter, unsigned long val);
> +
> +/*
> + * uncharge - tell that some portion of the resource is released
> + *
> + * @counter: the counter
> + * @val: the amount of the resource
> + *
> + * these calls check for usage underflow and show a warning on the console
> + * _locked call expects the counter->lock to be taken
> + */
> +
> +void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val);
> +
> +#endif
> diff -puN init/Kconfig~res_counters_infra init/Kconfig
> --- linux-2.6.23-rc2-mm2/init/Kconfig~res_counters_infra        2007-08-17 13:14:18.000000000 +0530
> +++ linux-2.6.23-rc2-mm2-balbir/init/Kconfig    2007-08-17 13:14:18.000000000 +0530
> @@ -337,6 +337,13 @@ config CPUSETS
>
>           Say N if unsure.
>
> +config RESOURCE_COUNTERS
> +       bool "Resource counters"
> +       help
> +         This option enables controller independent resource accounting
> +          infrastructure that works with containers
> +       depends on CONTAINERS
> +
>  config SYSFS_DEPRECATED
>         bool "Create deprecated sysfs files"
>         default y
> diff -puN kernel/Makefile~res_counters_infra kernel/Makefile
> --- linux-2.6.23-rc2-mm2/kernel/Makefile~res_counters_infra     2007-08-17 13:14:18.000000000 +0530
> +++ linux-2.6.23-rc2-mm2-balbir/kernel/Makefile 2007-08-17 13:14:18.000000000 +0530
> @@ -58,6 +58,7 @@ obj-$(CONFIG_RELAY) += relay.o
>  obj-$(CONFIG_SYSCTL) += utsname_sysctl.o
>  obj-$(CONFIG_TASK_DELAY_ACCT) += delayacct.o
>  obj-$(CONFIG_TASKSTATS) += taskstats.o tsacct.o
> +obj-$(CONFIG_RESOURCE_COUNTERS) += res_counter.o
>
>  ifneq ($(CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER),y)
>  # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
> diff -puN /dev/null kernel/res_counter.c
> --- /dev/null   2007-06-01 20:42:04.000000000 +0530
> +++ linux-2.6.23-rc2-mm2-balbir/kernel/res_counter.c    2007-08-17 13:14:18.000000000 +0530
> @@ -0,0 +1,120 @@
> +/*
> + * resource containers
> + *
> + * Copyright 2007 OpenVZ SWsoft Inc
> + *
> + * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + */
> +
> +#include <linux/types.h>
> +#include <linux/parser.h>
> +#include <linux/fs.h>
> +#include <linux/res_counter.h>
> +#include <linux/uaccess.h>
> +
> +void res_counter_init(struct res_counter *counter)
> +{
> +       spin_lock_init(&counter->lock);
> +       counter->limit = (unsigned long)LONG_MAX;
> +}
> +
> +int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> +{
> +       if (counter->usage > (counter->limit - val)) {
> +               counter->failcnt++;
> +               return -ENOMEM;
> +       }
> +
> +       counter->usage += val;
> +       return 0;
> +}
> +
> +int res_counter_charge(struct res_counter *counter, unsigned long val)
> +{
> +       int ret;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&counter->lock, flags);
> +       ret = res_counter_charge_locked(counter, val);
> +       spin_unlock_irqrestore(&counter->lock, flags);
> +       return ret;
> +}
> +
> +void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> +{
> +       if (WARN_ON(counter->usage < val))
> +               val = counter->usage;
> +
> +       counter->usage -= val;
> +}
> +
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&counter->lock, flags);
> +       res_counter_uncharge_locked(counter, val);
> +       spin_unlock_irqrestore(&counter->lock, flags);
> +}
> +
> +
> +static inline unsigned long *res_counter_member(struct res_counter *counter,
> +                                               int member)
> +{
> +       switch (member) {
> +       case RES_USAGE:
> +               return &counter->usage;
> +       case RES_LIMIT:
> +               return &counter->limit;
> +       case RES_FAILCNT:
> +               return &counter->failcnt;
> +       };
> +
> +       BUG();
> +       return NULL;
> +}
> +
> +ssize_t res_counter_read(struct res_counter *counter, int member,
> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
> +{
> +       unsigned long *val;
> +       char buf[64], *s;
> +
> +       s = buf;
> +       val = res_counter_member(counter, member);
> +       s += sprintf(s, "%lu\n", *val);
> +       return simple_read_from_buffer((void __user *)userbuf, nbytes,
> +                       pos, buf, s - buf);
> +}
> +
> +ssize_t res_counter_write(struct res_counter *counter, int member,
> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
> +{
> +       int ret;
> +       char *buf, *end;
> +       unsigned long tmp, *val;
> +
> +       buf = kmalloc(nbytes + 1, GFP_KERNEL);
> +       ret = -ENOMEM;
> +       if (buf == NULL)
> +               goto out;
> +
> +       buf[nbytes] = '\0';
> +       ret = -EFAULT;
> +       if (copy_from_user(buf, userbuf, nbytes))
> +               goto out_free;
> +
> +       ret = -EINVAL;
> +       tmp = simple_strtoul(buf, &end, 10);
> +       if (*end != '\0')
> +               goto out_free;
> +
> +       val = res_counter_member(counter, member);
> +       *val = tmp;
> +       ret = nbytes;
> +out_free:
> +       kfree(buf);
> +out:
> +       return ret;
> +}
> _
>
> --
>         Warm Regards,
>         Balbir Singh
>         Linux Technology Center
>         IBM, ISTL
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
>
