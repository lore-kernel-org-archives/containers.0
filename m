From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 8/9] [RFC] Example multi-bindable subsystem: a per-cgroup
	notes field
Date: Fri, 03 Jul 2009 16:58:03 +0800
Message-ID: <4A4DC81B.3050608__41309.3693940484$1246611468$gmane$org@cn.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021133.14469.35140.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021133.14469.35140.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> [RFC] Example multi-bindable subsystem: a per-cgroup notes field
> 
> As an example of a multiply-bindable subsystem, this patch introduces
> the "info" subsystem, which provides a single file, "info.notes", in
> which user-space middleware can store an arbitrary (by default up to
> one page) binary string representing configuration data about that
> cgroup.  This reduces the need to keep additional state outside the
> cgroup filesystem.  The maximum notes size for a hierarchy can be set
> by updating the "info.size" file in the root cgroup.
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  include/linux/cgroup_subsys.h |    6 ++
>  init/Kconfig                  |    9 +++
>  kernel/Makefile               |    1 
>  kernel/info_cgroup.c          |  133 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 149 insertions(+), 0 deletions(-)
>  create mode 100644 kernel/info_cgroup.c
> 
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index f78605e..5dfea38 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -60,3 +60,9 @@ SUBSYS(net_cls)
>  #endif
>  
>  /* */
> +
> +#ifdef CONFIG_CGROUP_INFO
> +MULTI_SUBSYS(info)
> +#endif
> +
> +/* */
> diff --git a/init/Kconfig b/init/Kconfig
> index d904d6c..3bd4685 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -604,6 +604,15 @@ config CGROUP_MEM_RES_CTLR_SWAP
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
>  
> +config CGROUP_INFO
> +	bool "Simple application-specific info cgroup subsystem"
> +	depends on CGROUPS
> +	help
> +	  Provides a simple cgroups subsystem with an "info.notes"
> +	  field, which can be used by middleware to store
> +	  application-specific configuration data about a cgroup. Can
> +	  be mounted on multiple hierarchies at once.
> +
>  endif # CGROUPS
>  
>  config MM_OWNER
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 7ffdc16..e713a67 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -61,6 +61,7 @@ obj-$(CONFIG_CGROUPS) += cgroup.o
>  obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
>  obj-$(CONFIG_CPUSETS) += cpuset.o
>  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
> +obj-$(CONFIG_CGROUP_INFO) += info_cgroup.o
>  obj-$(CONFIG_UTS_NS) += utsname.o
>  obj-$(CONFIG_USER_NS) += user_namespace.o
>  obj-$(CONFIG_PID_NS) += pid_namespace.o
> diff --git a/kernel/info_cgroup.c b/kernel/info_cgroup.c
> new file mode 100644
> index 0000000..34cfdb8
> --- /dev/null
> +++ b/kernel/info_cgroup.c
> @@ -0,0 +1,133 @@
> +/*
> + * info_cgroup.c - simple cgroup providing a "notes" field
> + */
> +
> +#include "linux/cgroup.h"
> +#include "linux/err.h"
> +#include "linux/seq_file.h"
> +

#include <linux/xxx>

And I got compile error, because of missing
#include <linux/uaccess.h>

> +struct info_cgroup {
> +	struct cgroup_subsys_state css;
> +	/* notes string for this cgroup */
> +	const char *notes;
> +	size_t len;
> +	/*
> +	 * size limit for notes in this hierarchy. Only relevant for
> +	 * the root cgroup. Not synchronized since it's a single word
> +	 * value and writes to it never depend on previously read
> +	 * values.
> +	 */
> +	size_t max_len;

If it's not per cgroup, it can be a global value.
But why not make it per cgroup?

> +	spinlock_t lock;
> +};
> +
> +static inline struct info_cgroup *cg_info(struct cgroup *cg)
> +{
> +	return container_of(cgroup_subsys_state(cg, info_subsys_id),
> +			    struct info_cgroup, css);
> +}
> +
> +static struct cgroup_subsys_state *info_create(struct cgroup_subsys *ss,
> +					       struct cgroup *cg)
> +{
> +	struct info_cgroup *info = kzalloc(sizeof(*info), GFP_KERNEL);

newline needed

> +	if (!info)
> +		return ERR_PTR(-ENOMEM);
> +	spin_lock_init(&info->lock);
> +	if (!cg->parent)
> +		info->max_len = PAGE_SIZE;
> +	return &info->css;
> +}
> +
> +static void info_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
> +{
> +	struct info_cgroup *css = cg_info(cont);

newline needed

> +	kfree(css->notes);
> +	kfree(css);
> +}
> +
> +
> +static int info_read(struct cgroup *cont,
> +		     struct cftype *cft,
> +		     struct seq_file *seq)
> +{
> +	struct info_cgroup *css = cg_info(cont);

newline needed

> +	spin_lock(&css->lock);
> +	if (css->notes)
> +		seq_write(seq, css->notes, css->len);
> +	spin_unlock(&css->lock);
> +	return 0;
> +}
> +
> +/*
> + * Use a custom write function so that we can handle binary data
> + */
> +
> +static ssize_t info_write(struct cgroup *cgrp, struct cftype *cft,
> +			  struct file *file,
> +			  const char __user *userbuf,
> +			  size_t nbytes, loff_t *unused_ppos) {
> +	struct info_cgroup *css = cg_info(cgrp);
> +	char *notes = NULL;

newline needed

> +	if (nbytes > cg_info(cgrp->top_cgroup)->max_len)
> +		return -E2BIG;
> +	if (nbytes) {
> +		notes = kmalloc(nbytes, GFP_USER);
> +		if (!notes)
> +			return -ENOMEM;
> +		if (copy_from_user(notes, userbuf, nbytes))

missing kfree(notes)

> +			return -EFAULT;
> +	}
> +
> +	spin_lock(&css->lock);
> +	kfree(css->notes);
> +	css->notes = notes;
> +	css->len = nbytes;
> +	spin_unlock(&css->lock);
> +	return nbytes;
> +}
> +
> +static u64 notes_size_read(struct cgroup *cont, struct cftype *cft)
> +{
> +	struct info_cgroup *css = cg_info(cont);
> +	return css->max_len;
> +}
> +
> +static int notes_size_write(struct cgroup *cont, struct cftype *cft, u64 val)
> +{
> +	struct info_cgroup *css = cg_info(cont);
> +	css->max_len = val;
> +	return 0;
> +}
> +
> +static struct cftype info_files[] =  {
> +	{
> +		.name = "notes",
> +		.read_seq_string = info_read,
> +		.write = info_write,
> +	},
> +};
> +
> +static struct cftype info_root_files[] = {
> +	{
> +		.name = "size",
> +		.read_u64 = notes_size_read,
> +		.write_u64 = notes_size_write,
> +	},
> +};
> +
> +static int info_populate(struct cgroup_subsys *ss, struct cgroup *cont)
> +{
> +	if (!cont->parent)
> +		cgroup_add_files(cont, ss, info_root_files,
> +				 ARRAY_SIZE(info_root_files));
> +	return cgroup_add_files(cont, ss, info_files, ARRAY_SIZE(info_files));
> +}
> +
> +struct cgroup_subsys info_subsys = {
> +	.name = "info",
> +	.create = info_create,
> +	.destroy = info_destroy,
> +	.populate = info_populate,
> +	.subsys_id = info_subsys_id,
> +};
> 
> 
> 
