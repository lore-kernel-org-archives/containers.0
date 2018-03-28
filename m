From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Wed, 28 Mar 2018 07:10:12 -0400
Message-ID: <bc03161e-394b-bf4d-48c4-858dcf05458a__8346.02436884797$1522235358$gmane$org@linux.vnet.ibm.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87sh8lcecn.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/27/2018 07:01 PM, Eric W. Biederman wrote:
> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>
>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>
>> Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
>> namespace upon CLONE_NEWUSER flag. Attach the ima_ns data structure
>> to user_namespace. ima_ns is allocated and freed upon IMA namespace
>> creation and exit, which is tied to USER namespace creation and exit.
>> Currently, the ima_ns contains no useful IMA data but only a dummy
>> interface. This patch creates the framework for namespacing the different
>> aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).
> Tying IMA to the user namespace is far better than tying IMA
> to the mount namespace.  It may even be the proper answer.
>
>
> You had asked what it would take to unstick this so you won't have
> problems next time you post and I did not get as far as answering.
>
> I had a conversation a while back with Mimi and I believe what was
> agreed was that IMA to start doing it's thing early needs a write
> to securityfs/imafs.

Above you say 'proper answer' for user namespace. Now this sounds like 
making it independent.

>
> As such I expect the best way to create the ima namespace is by simply
> writing to securityfs/imafs.  Possibly before the user namespace is
> even unshared.  That would allow IMA to keep track of things from
> before a container is created.

So you are saying to not tie it to user namespace but make it an 
independent namespace and to not use a clone flag (0x1000) but use the 
filesystem to spawn a new namespace. Should that be an IMA specific file 
or a file that can be shared with other subsystems?

    Stefan

>
> Eric
>
>> Changelog:
>> v3:
>> * Use CLONE_NEWUSER instead of CLONE_NEWNW flag
>>
>> v2:
>> * Moved ima_init_ns and related functions into own file that is
>>    always compiled; init_ima_ns will always be there
>> * Fixed putting of imans->parent
>> * Move IMA namespace creation from nsproxy into mount namespace
>>    code; get rid of procfs operations for IMA namespace
>>
>> v1:
>> * Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
>> * Use existing ima.h headers
>> * Move the ima_namespace.c to security/integrity/ima/ima_ns.c
>> * Fix typo INFO->INO
>> * Each namespace free's itself, removed recursively free'ing
>>    until init_ima_ns from free_ima_ns()
>>
>> Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> ---
>>   include/linux/ima.h                      | 64 ++++++++++++++++++++++++
>>   include/linux/user_namespace.h           |  4 ++
>>   init/Kconfig                             |  8 +++
>>   kernel/user.c                            |  7 +++
>>   kernel/user_namespace.c                  | 18 +++++++
>>   security/integrity/ima/Makefile          |  3 +-
>>   security/integrity/ima/ima.h             |  4 ++
>>   security/integrity/ima/ima_init.c        |  4 ++
>>   security/integrity/ima/ima_init_ima_ns.c | 37 ++++++++++++++
>>   security/integrity/ima/ima_ns.c          | 86 ++++++++++++++++++++++++++++++++
>>   10 files changed, 234 insertions(+), 1 deletion(-)
>>   create mode 100644 security/integrity/ima/ima_init_ima_ns.c
>>   create mode 100644 security/integrity/ima/ima_ns.c
>>
>> diff --git a/include/linux/ima.h b/include/linux/ima.h
>> index 0e4647e0eb60..8bca67df0ad3 100644
>> --- a/include/linux/ima.h
>> +++ b/include/linux/ima.h
>> @@ -12,6 +12,7 @@
>>   
>>   #include <linux/fs.h>
>>   #include <linux/kexec.h>
>> +#include <linux/user_namespace.h>
>>   struct linux_binprm;
>>   
>>   #ifdef CONFIG_IMA
>> @@ -105,4 +106,67 @@ static inline int ima_inode_removexattr(struct dentry *dentry,
>>   	return 0;
>>   }
>>   #endif /* CONFIG_IMA_APPRAISE */
>> +
>> +struct ima_namespace {
>> +	struct kref kref;
>> +	struct ima_namespace *parent;
>> +};
>> +
>> +extern struct ima_namespace init_ima_ns;
>> +
>> +void imans_install(struct ns_common *new);
>> +
>> +static inline struct ima_namespace *to_ima_ns(struct ns_common *ns)
>> +{
>> +	return container_of(ns, struct user_namespace, ns)->ima_ns;
>> +}
>> +
>> +#ifdef CONFIG_IMA_NS
>> +
>> +void free_ima_ns(struct kref *kref);
>> +
>> +static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
>> +{
>> +	BUG_ON(!ns);
>> +	if (ns)
>> +		kref_get(&ns->kref);
>> +	return ns;
>> +}
>> +
>> +static inline void put_ima_ns(struct ima_namespace *ns)
>> +{
>> +	BUG_ON(!ns);
>> +	if (ns)
>> +		kref_put(&ns->kref, free_ima_ns);
>> +}
>> +
>> +struct ima_namespace *copy_ima(struct ima_namespace *old_ns);
>> +
>> +static inline struct ima_namespace *get_current_ns(void)
>> +{
>> +	return current_user_ns()->ima_ns;
>> +}
>> +
>> +#else
>> +
>> +static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
>> +{
>> +	return ns;
>> +}
>> +
>> +static inline void put_ima_ns(struct ima_namespace *ns)
>> +{
>> +	return;
>> +}
>> +
>> +static inline struct ima_namespace *copy_ima(struct ima_namespace *old_ns)
>> +{
>> +	return old_ns;
>> +}
>> +
>> +static inline struct ima_namespace *get_current_ns(void)
>> +{
>> +	return NULL;
>> +}
>> +#endif /* CONFIG_IMA_NS */
>>   #endif /* _LINUX_IMA_H */
>> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
>> index d6b74b91096b..8884b22d991c 100644
>> --- a/include/linux/user_namespace.h
>> +++ b/include/linux/user_namespace.h
>> @@ -36,6 +36,7 @@ struct uid_gid_map { /* 64 bytes -- 1 cache line */
>>   #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
>>   
>>   struct ucounts;
>> +struct ima_namespace;
>>   
>>   enum ucount_type {
>>   	UCOUNT_USER_NAMESPACES,
>> @@ -76,6 +77,9 @@ struct user_namespace {
>>   #endif
>>   	struct ucounts		*ucounts;
>>   	int ucount_max[UCOUNT_COUNTS];
>> +#ifdef CONFIG_IMA
>> +	struct ima_namespace	*ima_ns;
>> +#endif
>>   } __randomize_layout;
>>   
>>   struct ucounts {
>> diff --git a/init/Kconfig b/init/Kconfig
>> index a9a2e2c86671..a1ad5384e081 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -931,6 +931,14 @@ config NET_NS
>>   	help
>>   	  Allow user space to create what appear to be multiple instances
>>   	  of the network stack.
>> +config IMA_NS
>> +	bool "IMA namespace"
>> +	depends on IMA
>> +	default y
>> +	help
>> +	  Allow the creation of IMA namespaces for each mount namespace.
>> +	  Namespaced IMA data enables having IMA features work separately
>> +	  for each mount namespace.
>>   
>>   endif # NAMESPACES
>>   
>> diff --git a/kernel/user.c b/kernel/user.c
>> index 9a20acce460d..31c946f3adce 100644
>> --- a/kernel/user.c
>> +++ b/kernel/user.c
>> @@ -19,6 +19,10 @@
>>   #include <linux/user_namespace.h>
>>   #include <linux/proc_ns.h>
>>   
>> +#ifdef CONFIG_IMA
>> +extern struct ima_namespace init_ima_ns;
>> +#endif
>> +
>>   /*
>>    * userns count is 1 for root user, 1 for init_uts_ns,
>>    * and 1 for... ?
>> @@ -66,6 +70,9 @@ struct user_namespace init_user_ns = {
>>   	.persistent_keyring_register_sem =
>>   	__RWSEM_INITIALIZER(init_user_ns.persistent_keyring_register_sem),
>>   #endif
>> +#ifdef CONFIG_IMA
>> +	.ima_ns = &init_ima_ns,
>> +#endif
>>   };
>>   EXPORT_SYMBOL_GPL(init_user_ns);
>>   
>> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> index 246d4d4ce5c7..7d6e7d6e6a34 100644
>> --- a/kernel/user_namespace.c
>> +++ b/kernel/user_namespace.c
>> @@ -25,6 +25,7 @@
>>   #include <linux/fs_struct.h>
>>   #include <linux/bsearch.h>
>>   #include <linux/sort.h>
>> +#include <linux/ima.h>
>>   
>>   static struct kmem_cache *user_ns_cachep __read_mostly;
>>   static DEFINE_MUTEX(userns_state_mutex);
>> @@ -140,8 +141,20 @@ int create_user_ns(struct cred *new)
>>   	if (!setup_userns_sysctls(ns))
>>   		goto fail_keyring;
> Having the functions be #ifdef'd rather than the code would
> be preferabble.
>>   
>> +#if CONFIG_IMA
>> +	ns->ima_ns = copy_ima(parent_ns->ima_ns);
>> +	if (IS_ERR(ns->ima_ns)) {
>> +		ret = PTR_ERR(ns->ima_ns);
>> +		goto fail_userns_sysctls;
>> +	}
>> +#endif
>> +
>>   	set_cred_user_ns(new, ns);
>>   	return 0;
>> +#if CONFIG_IMA
>> +fail_userns_sysctls:
>> +	retire_userns_sysctls(ns);
>> +#endif
>>   fail_keyring:
>>   #ifdef CONFIG_PERSISTENT_KEYRINGS
>>   	key_put(ns->persistent_keyring_register);
>> @@ -195,6 +208,9 @@ static void free_user_ns(struct work_struct *work)
>>   			kfree(ns->projid_map.forward);
>>   			kfree(ns->projid_map.reverse);
>>   		}
>> +#ifdef CONFIG_IMA
>> +		put_ima_ns(ns->ima_ns);
>> +#endif
>>   		retire_userns_sysctls(ns);
>>   #ifdef CONFIG_PERSISTENT_KEYRINGS
>>   		key_put(ns->persistent_keyring_register);
>> @@ -1285,6 +1301,8 @@ static int userns_install(struct nsproxy *nsproxy, struct ns_common *ns)
>>   	put_user_ns(cred->user_ns);
>>   	set_cred_user_ns(cred, get_user_ns(user_ns));
>>   
>> +	imans_install(ns);
>> +
>>   	return commit_creds(cred);
>>   }
>>   
>> diff --git a/security/integrity/ima/Makefile b/security/integrity/ima/Makefile
>> index d921dc4f9eb0..cc60f726e651 100644
>> --- a/security/integrity/ima/Makefile
>> +++ b/security/integrity/ima/Makefile
>> @@ -7,7 +7,8 @@
>>   obj-$(CONFIG_IMA) += ima.o
>>   
>>   ima-y := ima_fs.o ima_queue.o ima_init.o ima_main.o ima_crypto.o ima_api.o \
>> -	 ima_policy.o ima_template.o ima_template_lib.o
>> +	 ima_policy.o ima_template.o ima_template_lib.o ima_init_ima_ns.o
>>   ima-$(CONFIG_IMA_APPRAISE) += ima_appraise.o
>> +ima-$(CONFIG_IMA_NS) += ima_ns.o
>>   ima-$(CONFIG_HAVE_IMA_KEXEC) += ima_kexec.o
>>   obj-$(CONFIG_IMA_BLACKLIST_KEYRING) += ima_mok.o
>> diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
>> index d52b487ad259..e98c11c7cf75 100644
>> --- a/security/integrity/ima/ima.h
>> +++ b/security/integrity/ima/ima.h
>> @@ -291,6 +291,10 @@ static inline int ima_read_xattr(struct dentry *dentry,
>>   
>>   #endif /* CONFIG_IMA_APPRAISE */
>>   
>> +int ima_ns_init(void);
>> +struct ima_namespace;
>> +int ima_init_namespace(struct ima_namespace *ns);
>> +
>>   /* LSM based policy rules require audit */
>>   #ifdef CONFIG_IMA_LSM_RULES
>>   
>> diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
>> index 2967d497a665..7f884a71fa1c 100644
>> --- a/security/integrity/ima/ima_init.c
>> +++ b/security/integrity/ima/ima_init.c
>> @@ -137,5 +137,9 @@ int __init ima_init(void)
>>   
>>   	ima_init_policy();
>>   
>> +	rc = ima_ns_init();
>> +	if (rc != 0)
>> +		return rc;
>> +
>>   	return ima_fs_init();
>>   }
>> diff --git a/security/integrity/ima/ima_init_ima_ns.c b/security/integrity/ima/ima_init_ima_ns.c
>> new file mode 100644
>> index 000000000000..52cb94b1d392
>> --- /dev/null
>> +++ b/security/integrity/ima/ima_init_ima_ns.c
>> @@ -0,0 +1,37 @@
>> +/*
>> + * Copyright (C) 2016-2018 IBM Corporation
>> + * Author:
>> + *   Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> + *   Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation, version 2 of the License.
>> + */
>> +
>> +#include <linux/export.h>
>> +#include <linux/user_namespace.h>
>> +#include <linux/ima.h>
>> +
>> +int ima_init_namespace(struct ima_namespace *ns)
>> +{
>> +	return 0;
>> +}
>> +
>> +int __init ima_ns_init(void)
>> +{
>> +	return ima_init_namespace(&init_ima_ns);
>> +}
>> +
>> +struct ima_namespace init_ima_ns = {
>> +	.kref = KREF_INIT(1),
>> +	.parent = NULL,
>> +};
>> +EXPORT_SYMBOL(init_ima_ns);
>> +
>> +void imans_install(struct ns_common *new)
>> +{
>> +	struct ima_namespace *ns = to_ima_ns(new);
>> +
>> +	get_ima_ns(ns);
>> +}
>> diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
>> new file mode 100644
>> index 000000000000..62148908015a
>> --- /dev/null
>> +++ b/security/integrity/ima/ima_ns.c
>> @@ -0,0 +1,86 @@
>> +/*
>> + * Copyright (C) 2016-2018 IBM Corporation
>> + * Author:
>> + *  Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> + *  Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation, version 2 of the License.
>> + */
>> +
>> +#include <linux/kref.h>
>> +#include <linux/slab.h>
>> +#include <linux/ima.h>
>> +#include <linux/mount.h>
>> +
>> +#include "ima.h"
>> +
>> +static struct ima_namespace *create_ima_ns(void)
>> +{
>> +	struct ima_namespace *ima_ns;
>> +
>> +	ima_ns = kmalloc(sizeof(*ima_ns), GFP_KERNEL);
>> +	if (ima_ns)
>> +		kref_init(&ima_ns->kref);
>> +
>> +	return ima_ns;
>> +}
>> +
>> +/**
>> + * Clone a new ns copying an original ima namespace, setting refcount to 1
>> + *
>> + * @old_ns: old ima namespace to clone
>> + * Return ERR_PTR(-ENOMEM) on error (failure to kmalloc), new ns otherwise
>> + */
>> +static struct ima_namespace *clone_ima_ns(struct ima_namespace *old_ns)
>> +{
>> +	struct ima_namespace *ns;
>> +
>> +	ns = create_ima_ns();
>> +	if (!ns)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	get_ima_ns(old_ns);
>> +	ns->parent = old_ns;
>> +
>> +	ima_init_namespace(ns);
>> +
>> +	return ns;
>> +}
>> +
>> +/**
>> + * Copy task's ima namespace, or clone it if flags specifies CLONE_NEWNS.
>> + *
>> + * @flags: flags used in the clone syscall
>> + * @old_ns: old ima namespace to clone
>> + */
>> +
>> +struct ima_namespace *copy_ima(struct ima_namespace *old_ns)
>> +{
>> +	struct ima_namespace *new_ns;
>> +
>> +	BUG_ON(!old_ns);
>> +	get_ima_ns(old_ns);
>> +
>> +	new_ns = clone_ima_ns(old_ns);
>> +	put_ima_ns(old_ns);
>> +
>> +	return new_ns;
>> +}
>> +
>> +static void destroy_ima_ns(struct ima_namespace *ns)
>> +{
>> +	put_ima_ns(ns->parent);
>> +	kfree(ns);
>> +}
>> +
>> +void free_ima_ns(struct kref *kref)
>> +{
>> +	struct ima_namespace *ns;
>> +
>> +	ns = container_of(kref, struct ima_namespace, kref);
>> +	BUG_ON(ns == &init_ima_ns);
>> +
>> +	destroy_ima_ns(ns);
>> +}
