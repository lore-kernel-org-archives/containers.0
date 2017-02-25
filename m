From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: Re: [PATCH RFC] coredump: virtualize core dump path configuration
Date: Sat, 25 Feb 2017 19:48:25 +0300
Message-ID: <7b89eb7a-72ac-2fc5-097d-d2d97cd7e8d5@yandex-team.ru>
References: <148802737321.604836.9948660933476794784.stgit@buzz>
	<20170225160123.GC11144@pc.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170225160123.GC11144-J1fxOzX/cBvk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 25.02.2017 19:01, Jann Horn wrote:
> On Sat, Feb 25, 2017 at 03:56:13PM +0300, Konstantin Khlebnikov wrote:
>> This patch adds per-mount-namespace core dump pattern.
>>
>> Kernel writes coredump in chroot/container where application is
>> executed or starts pipe helper in the same chroot according to
>> pattern set by sysctl "kernel.core_pattern".
>
> I'm pretty sure it doesn't, and if it did, that would be a security bug.
>
> Coredump helpers have, as far as I know, always been executed in the
> root directory of init, not inside the chroot.

Ah, right. Nowdays helpers are executed via kmod.
Obviously this kernel thread lives in init namespace.
IIRR in ancient times they were forked from dumping task in chroot.

This changes everything.
Patch is wrong, but mount-ns still looks like a right place.

>
> Absolute core patterns used to write coredumps into the root directory
> of the chroot, and that was a security issue, which I fixed:
>
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=378c6520e7d29280f400ef2ceaf155c86f05a71a

I've missed this change. But it works only for SUID_DUMP_ROOT.
Normal applications still dumps into chroot even for absolute patterns.
Am I wrong?

>
>> This configuration is
>> global and this sysctl couldn't be extended without breaking anything.
>>
>> This patch adds second sysctl "kernel.core_pattern_ns" which overrides
>> global configuration for tasks in current mount namespace.
>> Resetting it to empty string reverts core dumps back to global pattern.
>>
>> New namespace gets a copy of this configuration from parent.
>> [...]
>> +char *namespace_core_pattern(bool alloc)
>> +{
>> +	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
>> +
>> +	if (!ns->core_pattern && alloc) {
>> +		char *new = kzalloc(CORENAME_MAX_SIZE, GFP_KERNEL);
>> +
>> +		if (new && cmpxchg(&ns->core_pattern, NULL, new))
>> +			kfree(new);
>> +	}
>> +
>> +	return ns->core_pattern;
>> +}
>> +
>> +static char *current_core_pattern(void)
>> +{
>> +	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
>> +
>> +	if (ns->core_pattern && ns->core_pattern[0])
>> +		return ns->core_pattern;
>> +
>> +	return core_pattern;
>> +}
>
>
>
>>  /* format_corename will inspect the pattern parameter, and output a
>>   * name into corename, which must have space for at least
>>   * CORENAME_MAX_SIZE bytes plus one byte for the zero terminator.
>> @@ -187,7 +212,7 @@ static int cn_print_exe_file(struct core_name *cn)
>>  static int format_corename(struct core_name *cn, struct coredump_params *cprm)
>>  {
>>  	const struct cred *cred = current_cred();
>> -	const char *pat_ptr = core_pattern;
>> +	const char *pat_ptr = current_core_pattern();
>>  	int ispipe = (*pat_ptr == '|');
>>  	int pid_in_pattern = 0;
>>  	int err = 0;
>
> If you don't change more here, the behavior is going to be that
> the namespaced core pattern causes coredump helpers to be launched
> and absolute-path coredumps to be written relative to init's root
> directory and with the privileges of root in the init namespace.
>
> Those semantics seem unintuitive to me. Shouldn't the coredumps
> be written relative to some sort of root directory of the user
> namespace? (Yes, I realize that no clear semantics for that are
> defined.) And shouldn't the coredumps be written with the
> privileges of the user namespace on which the coredump pattern
> was set?

There is no integration with user-ns. Permissions are the same as for global pattern.
This patch just allows to alter core_pattern depending on mount-ns.
I've planned to configure this by privileged application who starts container.
Invention of proper security model for user-ns will take a lot of time for sure.

Fine, once helper is always executed in host then I'll probably abandon this
virtualization in kernel and try to implement all this in userspace as a helper
which routes dumps into right container.

>
>
>> diff --git a/fs/mount.h b/fs/mount.h
>> index 2c856fc47ae3..894bca887104 100644
>> --- a/fs/mount.h
>> +++ b/fs/mount.h
>> @@ -16,6 +16,7 @@ struct mnt_namespace {
>>  	u64 event;
>>  	unsigned int		mounts; /* # of mounts in the namespace */
>>  	unsigned int		pending_mounts;
>> +	char			*core_pattern;
>>  };
>>
>>  struct mnt_pcp {
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index 487ba30bb5c6..a8dd58eb10da 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -24,6 +24,7 @@
>>  #include <linux/magic.h>
>>  #include <linux/bootmem.h>
>>  #include <linux/task_work.h>
>> +#include <linux/binfmts.h>	/* CORENAME_MAX_SIZE */
>>  #include "pnode.h"
>>  #include "internal.h"
>>
>> @@ -2828,6 +2829,7 @@ static void free_mnt_ns(struct mnt_namespace *ns)
>>  	ns_free_inum(&ns->ns);
>>  	dec_mnt_namespaces(ns->ucounts);
>>  	put_user_ns(ns->user_ns);
>> +	kfree(ns->core_pattern);
>>  	kfree(ns);
>>  }
>>
>> @@ -2872,6 +2874,7 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
>>  	new_ns->ucounts = ucounts;
>>  	new_ns->mounts = 0;
>>  	new_ns->pending_mounts = 0;
>> +	new_ns->core_pattern = NULL;
>>  	return new_ns;
>>  }
>>
>> @@ -2899,6 +2902,15 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
>>  	if (IS_ERR(new_ns))
>>  		return new_ns;
>>
>> +	if (ns->core_pattern) {
>> +		new_ns->core_pattern = kmemdup(ns->core_pattern,
>> +					       CORENAME_MAX_SIZE, GFP_KERNEL);
>> +		if (!new_ns->core_pattern) {
>> +			free_mnt_ns(new_ns);
>> +			return ERR_PTR(-ENOMEM);
>> +		}
>> +	}
>> +
>
> AFAICS copying it this way means that in the following scenario,
> namespace B will still use the core_pattern "foo" while namespace A
> is using core_pattern "bar":
>  - you set the core_pattern of namespace A to "foo"
>  - namespace A creates a child namespace B
>  - you set the core_pattern of namespace A to "bar"
>
> Those are pretty unintuitive semantics. It might be better
> to not copy the pattern and instead loop up through the
> namespaces in current_core_pattern() or so.
>
> Also, wouldn't you have to use an atomic read here or so?

Yep, probably this needs ACCESS_ONCE and friends to read and write pointer at whole.

>
>>  	namespace_lock();
>>  	/* First pass: copy the tree topology */
>>  	copy_flags = CL_COPY_UNBINDABLE | CL_EXPIRE;
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index 1aea594a54db..9e66daf1e236 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -483,6 +483,13 @@ static struct ctl_table kern_table[] = {
>>  		.proc_handler	= proc_dostring_coredump,
>>  	},
>>  	{
>> +		.procname	= "core_pattern_ns",
>> +		.data		= NULL,
>> +		.maxlen		= CORENAME_MAX_SIZE,
>> +		.mode		= 0644,
>> +		.proc_handler	= proc_dostring_coredump,
>> +	},
>> +	{
>
> Only root can write it? That seems weird if you intend to use it
> for containers.
>
>>  		.procname	= "core_pipe_limit",
>>  		.data		= &core_pipe_limit,
>>  		.maxlen		= sizeof(unsigned int),
>> @@ -2408,10 +2415,27 @@ static int proc_dointvec_minmax_coredump(struct ctl_table *table, int write,
>>  }
>>
>>  #ifdef CONFIG_COREDUMP
>> +extern char *namespace_core_pattern(bool alloc);
>> +
>>  static int proc_dostring_coredump(struct ctl_table *table, int write,
>>  		  void __user *buffer, size_t *lenp, loff_t *ppos)
>>  {
>> -	int error = proc_dostring(table, write, buffer, lenp, ppos);
>> +	struct ctl_table tmp_table;
>> +	char empty[] = "";
>> +	int error;
>> +
>> +	if (!table->data) {
>> +		tmp_table = *table;
>> +		table = &tmp_table;
>> +		table->data = namespace_core_pattern(write);
>> +		if (!table->data) {
>> +			if (write)
>> +				return -ENOMEM;
>> +			table->data = empty;
>> +		}
>> +	}
>> +
>> +	error = proc_dostring(table, write, buffer, lenp, ppos);
>>  	if (!error)
>>  		validate_coredump_safety();
>>  	return error;
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
