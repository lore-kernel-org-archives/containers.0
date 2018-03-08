From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 1/5] ima: extend clone() with IMA namespace support
Date: Thu, 8 Mar 2018 08:39:22 -0500
Message-ID: <2fac8414-6957-1fce-6b40-ad4b687ca83c__13966.8276453905$1520516287$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170720225033.21298-2-mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/20/2017 06:50 PM, Mehmet Kayaalp wrote:
> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
> namespace upon CLONE_NEWNS flag. Add ima_ns data structure in nsproxy.
> ima_ns is allocated and freed upon IMA namespace creation and exit.
> Currently, the ima_ns contains no useful IMA data but only a dummy
> interface. This patch creates the framework for namespacing the different
> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
>
> Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> Changelog:
> * Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
> * Use existing ima.h headers
> * Move the ima_namespace.c to security/integrity/ima/ima_ns.c
> * Fix typo INFO->INO
> * Each namespace free's itself, removed recursively free'ing
> until init_ima_ns from free_ima_ns()

With this patch we would use CLONE_NEWNS and create an IMA and mount 
namespace at the same time. However, the code below creates two inodes 
to handle the two namespaces separately via setns(). The consequence of 
this is that an application doing a setns() on the created mount 
namespace will not join the IMA namespace that was created as part of 
the clone(CLONE_NEWNS). Is that expected behavior? If not, we'll have to 
modify the code below and remove its proc_ns_operations and modify the 
mount namespace's proc_ns_operations to call into IMA code as well. I 
don't know of another namespace that would do something like this. Is 
that an acceptable solution?

    Stefan

>
> Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>   fs/proc/namespaces.c              |   3 +
>   include/linux/ima.h               |  37 ++++++++
>   include/linux/nsproxy.h           |   1 +
>   include/linux/proc_ns.h           |   2 +
>   init/Kconfig                      |   8 ++
>   kernel/nsproxy.c                  |  15 ++++
>   security/integrity/ima/Makefile   |   1 +
>   security/integrity/ima/ima.h      |   9 ++
>   security/integrity/ima/ima_init.c |   4 +
>   security/integrity/ima/ima_ns.c   | 183 ++++++++++++++++++++++++++++++++++++++
>   10 files changed, 263 insertions(+)
>   create mode 100644 security/integrity/ima/ima_ns.c
>
> diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
> index 3803b24..222a64e 100644
> --- a/fs/proc/namespaces.c
> +++ b/fs/proc/namespaces.c
> @@ -32,6 +32,9 @@ static const struct proc_ns_operations *ns_entries[] = {
>   #ifdef CONFIG_CGROUPS
>   	&cgroupns_operations,
>   #endif
> +#ifdef CONFIG_IMA_NS
> +	&imans_operations,
> +#endif
>   };
>
>   static const char *proc_ns_get_link(struct dentry *dentry,
> diff --git a/include/linux/ima.h b/include/linux/ima.h
> index 0e4647e..11e4841 100644
> --- a/include/linux/ima.h
> +++ b/include/linux/ima.h
> @@ -105,4 +105,41 @@ static inline int ima_inode_removexattr(struct dentry *dentry,
>   	return 0;
>   }
>   #endif /* CONFIG_IMA_APPRAISE */
> +
> +struct ima_namespace {
> +	struct kref kref;
> +	struct user_namespace *user_ns;
> +	struct ns_common ns;
> +	struct ima_namespace *parent;
> +};
> +
> +extern struct ima_namespace init_ima_ns;
> +
> +#ifdef CONFIG_IMA_NS
> +void put_ima_ns(struct ima_namespace *ns);
> +struct ima_namespace *copy_ima(unsigned long flags,
> +			       struct user_namespace *user_ns,
> +			       struct ima_namespace *old_ns);
> +static inline struct ima_namespace *get_current_ns(void)
> +{
> +	return current->nsproxy->ima_ns;
> +}
> +#else
> +static inline void put_ima_ns(struct ima_namespace *ns)
> +{
> +	return;
> +}
> +
> +static inline struct ima_namespace *copy_ima(unsigned long flags,
> +					     struct user_namespace *user_ns,
> +					     struct ima_namespace *old_ns)
> +{
> +	return old_ns;
> +}
> +
> +static inline struct ima_namespace *get_current_ns(void)
> +{
> +	return NULL;
> +}
> +#endif /* CONFIG_IMA_NS */
>   #endif /* _LINUX_IMA_H */
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index ac0d65b..a97031d 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -35,6 +35,7 @@ struct nsproxy {
>   	struct pid_namespace *pid_ns_for_children;
>   	struct net 	     *net_ns;
>   	struct cgroup_namespace *cgroup_ns;
> +	struct ima_namespace *ima_ns;
>   };
>   extern struct nsproxy init_nsproxy;
>
> diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
> index 58ab28d..c7c1239 100644
> --- a/include/linux/proc_ns.h
> +++ b/include/linux/proc_ns.h
> @@ -31,6 +31,7 @@ extern const struct proc_ns_operations pidns_for_children_operations;
>   extern const struct proc_ns_operations userns_operations;
>   extern const struct proc_ns_operations mntns_operations;
>   extern const struct proc_ns_operations cgroupns_operations;
> +extern const struct proc_ns_operations imans_operations;
>
>   /*
>    * We always define these enumerators
> @@ -42,6 +43,7 @@ enum {
>   	PROC_USER_INIT_INO	= 0xEFFFFFFDU,
>   	PROC_PID_INIT_INO	= 0xEFFFFFFCU,
>   	PROC_CGROUP_INIT_INO	= 0xEFFFFFFBU,
> +	PROC_IMA_INIT_INO	= 0xEFFFFFFAU,
>   };
>
>   #ifdef CONFIG_PROC_FS
> diff --git a/init/Kconfig b/init/Kconfig
> index 1d3475f..339f84d 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1287,6 +1287,14 @@ config NET_NS
>   	help
>   	  Allow user space to create what appear to be multiple instances
>   	  of the network stack.
> +config IMA_NS
> +	bool "IMA namespace"
> +	depends on IMA
> +	default y
> +	help
> +	  Allow the creation of IMA namespaces for each mount namespace.
> +	  Namespaced IMA data enables having IMA features work separately
> +	  for each mount namespace.
>
>   endif # NAMESPACES
>
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index f6c5d33..85be341 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -27,6 +27,7 @@
>   #include <linux/syscalls.h>
>   #include <linux/cgroup.h>
>   #include <linux/perf_event.h>
> +#include <linux/ima.h>
>
>   static struct kmem_cache *nsproxy_cachep;
>
> @@ -44,6 +45,9 @@ struct nsproxy init_nsproxy = {
>   #ifdef CONFIG_CGROUPS
>   	.cgroup_ns		= &init_cgroup_ns,
>   #endif
> +#ifdef CONFIG_IMA_NS
> +	.ima_ns                 = &init_ima_ns,
> +#endif
>   };
>
>   static inline struct nsproxy *create_nsproxy(void)
> @@ -110,8 +114,17 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>   		goto out_net;
>   	}
>
> +	new_nsp->ima_ns = copy_ima(flags, user_ns, tsk->nsproxy->ima_ns);
> +	if (IS_ERR(new_nsp->ima_ns)) {
> +		err = PTR_ERR(new_nsp->ima_ns);
> +		goto out_ima;
> +	}
> +
>   	return new_nsp;
>
> +out_ima:
> +	if (new_nsp->ima_ns)
> +		put_ima_ns(new_nsp->ima_ns);
>   out_net:
>   	put_cgroup_ns(new_nsp->cgroup_ns);
>   out_cgroup:
> @@ -181,6 +194,8 @@ void free_nsproxy(struct nsproxy *ns)
>   	if (ns->pid_ns_for_children)
>   		put_pid_ns(ns->pid_ns_for_children);
>   	put_cgroup_ns(ns->cgroup_ns);
> +	if (ns->ima_ns)
> +		put_ima_ns(ns->ima_ns);
>   	put_net(ns->net_ns);
>   	kmem_cache_free(nsproxy_cachep, ns);
>   }
> diff --git a/security/integrity/ima/Makefile b/security/integrity/ima/Makefile
> index 29f198b..20493f0 100644
> --- a/security/integrity/ima/Makefile
> +++ b/security/integrity/ima/Makefile
> @@ -8,5 +8,6 @@ obj-$(CONFIG_IMA) += ima.o
>   ima-y := ima_fs.o ima_queue.o ima_init.o ima_main.o ima_crypto.o ima_api.o \
>   	 ima_policy.o ima_template.o ima_template_lib.o
>   ima-$(CONFIG_IMA_APPRAISE) += ima_appraise.o
> +ima-$(CONFIG_IMA_NS) += ima_ns.o
>   ima-$(CONFIG_HAVE_IMA_KEXEC) += ima_kexec.o
>   obj-$(CONFIG_IMA_BLACKLIST_KEYRING) += ima_mok.o
> diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
> index d52b487..8a8234a 100644
> --- a/security/integrity/ima/ima.h
> +++ b/security/integrity/ima/ima.h
> @@ -291,6 +291,15 @@ static inline int ima_read_xattr(struct dentry *dentry,
>
>   #endif /* CONFIG_IMA_APPRAISE */
>
> +#ifdef CONFIG_IMA_NS
> +int ima_ns_init(void);
> +#else
> +static inline int ima_ns_init(void)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_IMA_NS */
> +
>   /* LSM based policy rules require audit */
>   #ifdef CONFIG_IMA_LSM_RULES
>
> diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
> index 2967d49..7f884a7 100644
> --- a/security/integrity/ima/ima_init.c
> +++ b/security/integrity/ima/ima_init.c
> @@ -137,5 +137,9 @@ int __init ima_init(void)
>
>   	ima_init_policy();
>
> +	rc = ima_ns_init();
> +	if (rc != 0)
> +		return rc;
> +
>   	return ima_fs_init();
>   }
> diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
> new file mode 100644
> index 0000000..383217b
> --- /dev/null
> +++ b/security/integrity/ima/ima_ns.c
> @@ -0,0 +1,183 @@
> +/*
> + * Copyright (C) 2008 IBM Corporation
> + * Author: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation, version 2 of the License.
> + */
> +
> +#include <linux/export.h>
> +#include <linux/user_namespace.h>
> +#include <linux/proc_ns.h>
> +#include <linux/kref.h>
> +#include <linux/slab.h>
> +#include <linux/ima.h>
> +
> +#include "ima.h"
> +
> +static void get_ima_ns(struct ima_namespace *ns);
> +
> +int ima_init_namespace(struct ima_namespace *ns)
> +{
> +	return 0;
> +}
> +
> +int ima_ns_init(void)
> +{
> +	return ima_init_namespace(&init_ima_ns);
> +}
> +
> +static struct ima_namespace *create_ima_ns(void)
> +{
> +	struct ima_namespace *ima_ns;
> +
> +	ima_ns = kmalloc(sizeof(*ima_ns), GFP_KERNEL);
> +	if (ima_ns)
> +		kref_init(&ima_ns->kref);
> +
> +	return ima_ns;
> +}
> +
> +/**
> + * Clone a new ns copying an original ima namespace, setting refcount to 1
> + *
> + * @old_ns: old ima namespace to clone
> + * @user_ns: user namespace that current task runs in
> + * Return ERR_PTR(-ENOMEM) on error (failure to kmalloc), new ns otherwise
> + */
> +static struct ima_namespace *clone_ima_ns(struct user_namespace *user_ns,
> +					  struct ima_namespace *old_ns)
> +{
> +	struct ima_namespace *ns;
> +	int err;
> +
> +	ns = create_ima_ns();
> +	if (!ns)
> +		return ERR_PTR(-ENOMEM);
> +
> +	err = ns_alloc_inum(&ns->ns);
> +	if (err) {
> +		kfree(ns);
> +		return ERR_PTR(err);
> +	}
> +
> +	ns->ns.ops = &imans_operations;
> +	get_ima_ns(old_ns);
> +	ns->parent = old_ns;
> +	ns->user_ns = get_user_ns(user_ns);
> +
> +	ima_init_namespace(ns);
> +
> +	return ns;
> +}
> +
> +/**
> + * Copy task's ima namespace, or clone it if flags specifies CLONE_NEWNS.
> + *
> + * @flags: flags used in the clone syscall
> + * @user_ns: user namespace that current task runs in
> + * @old_ns: old ima namespace to clone
> + */
> +
> +struct ima_namespace *copy_ima(unsigned long flags,
> +			       struct user_namespace *user_ns,
> +			       struct ima_namespace *old_ns)
> +{
> +	struct ima_namespace *new_ns;
> +
> +	BUG_ON(!old_ns);
> +	get_ima_ns(old_ns);
> +
> +	if (!(flags & CLONE_NEWNS))
> +		return old_ns;
> +
> +	new_ns = clone_ima_ns(user_ns, old_ns);
> +	put_ima_ns(old_ns);
> +
> +	return new_ns;
> +}
> +
> +static void destroy_ima_ns(struct ima_namespace *ns)
> +{
> +	put_user_ns(ns->user_ns);
> +	ns_free_inum(&ns->ns);
> +	kfree(ns);
> +}
> +
> +static void free_ima_ns(struct kref *kref)
> +{
> +	struct ima_namespace *ns;
> +
> +	ns = container_of(kref, struct ima_namespace, kref);
> +	destroy_ima_ns(ns);
> +}
> +
> +static void get_ima_ns(struct ima_namespace *ns)
> +{
> +	kref_get(&ns->kref);
> +}
> +
> +void put_ima_ns(struct ima_namespace *ns)
> +{
> +	kref_put(&ns->kref, free_ima_ns);
> +}
> +
> +static inline struct ima_namespace *to_ima_ns(struct ns_common *ns)
> +{
> +	return container_of(ns, struct ima_namespace, ns);
> +}
> +
> +static struct ns_common *imans_get(struct task_struct *task)
> +{
> +	struct ima_namespace *ns = NULL;
> +	struct nsproxy *nsproxy;
> +
> +	task_lock(task);
> +	nsproxy = task->nsproxy;
> +	if (nsproxy) {
> +		ns = nsproxy->ima_ns;
> +		get_ima_ns(ns);
> +	}
> +	task_unlock(task);
> +
> +	return ns ? &ns->ns : NULL;
> +}
> +
> +static void imans_put(struct ns_common *ns)
> +{
> +	put_ima_ns(to_ima_ns(ns));
> +}
> +
> +static int imans_install(struct nsproxy *nsproxy, struct ns_common *new)
> +{
> +	struct ima_namespace *ns = to_ima_ns(new);
> +
> +	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN) ||
> +	    !ns_capable(current_user_ns(), CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	get_ima_ns(ns);
> +	put_ima_ns(nsproxy->ima_ns);
> +	nsproxy->ima_ns = ns;
> +	return 0;
> +}
> +
> +const struct proc_ns_operations imans_operations = {
> +	.name = "ima",
> +	.type = CLONE_NEWNS,
> +	.get = imans_get,
> +	.put = imans_put,
> +	.install = imans_install,
> +};
> +
> +struct ima_namespace init_ima_ns = {
> +	.kref = KREF_INIT(2),
> +	.user_ns = &init_user_ns,
> +	.ns.inum = PROC_IMA_INIT_INO,
> +#ifdef CONFIG_IMA_NS
> +	.ns.ops = &imans_operations,
> +#endif
> +	.parent = NULL,
> +};
> +EXPORT_SYMBOL(init_ima_ns);
