From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: Containerized syslog  (Take II)
Date: Tue, 16 Feb 2010 15:59:09 -0800
Message-ID: <20100216235909.GB3604@count0.beaverton.ibm.com>
References: <201002161520.o1GFKC6Q013851@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201002161520.o1GFKC6Q013851-X4ZF2iejbABnc3BsFfMrZw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 16, 2010 at 10:24:17AM -0500, Jean-Marc Pigeon wrote:
> 	Containerized syslog is now part of nsproxy.
> 	A new flag CLONE_SYSLOG allow to unshare
> 	syslog area.
> 	Main containerized syslog purpose is to allow
> 	full container not to leak or compromise
> 	hosts syslog data.

Hi Jean-Marc,

	I think this last point deserves significant elaboration. What
does it mean to "not leak or compromise hosts syslog data"? Is it possible
to guarantee that we don't leak or is this just a best-effort sort of thing?
My hunch is it's the latter. You really must respond to Eric's question of
why this is useful. I know it might seem obvious to you but it's not
actualy clear. I've found that carefuly explaining my reasoning when it
seemed obvious often uncovers hidden assumptions I made and may even
suggest problems and/or alternate approaches.

Kernel patch guidelines suggests you should split the patch up so it's
one change at a time. One possible way to divide this into a series of
patches is:

	patch to add krefs
	patch to move syslog_ns from user_namespace to nsproxy
	patch to rename syslog_current_ns() (or whatever)
	patch to rename X to Y

(There may be better ways to break up the patches -- these just came to mind)

But the krefs patch probably deals with correctness so it should eventually
be merged with the first patch (for clean bisectability). The name changes
are nice right now, but should also be merged since introducing new code
only to change the names later is often pointless. So you're left with:

	<modified original patch>
	patch to move syslog_ns from user_namespace to nsproxy
	...

	Each of these patches should have a clear description of why it's
necessary/good -- not just "this patch adds krefs" for example. What
problem does adding the krefs solve?

> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index abec69b..30b479e 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -11,6 +11,7 @@
>  #include <linux/user_namespace.h>
>  #include <linux/securebits.h>
>  #include <net/net_namespace.h>
> +#include <linux/syslog.h>
> 
>  extern struct files_struct init_files;
>  extern struct fs_struct init_fs;
> @@ -37,6 +38,7 @@ extern struct nsproxy init_nsproxy;
>  	.count		= ATOMIC_INIT(1),				\
>  	.uts_ns		= &init_uts_ns,					\
>  	.mnt_ns		= NULL,						\
> +	.syslog_ns	= &init_kernel_syslog_ns,			\

s/_kernel_//

(We know it's kernel code..)

<snip>

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 78efe7c..659cc81 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -9,6 +9,7 @@
>  #define CLONE_FS	0x00000200	/* set if fs info shared between processes */
>  #define CLONE_FILES	0x00000400	/* set if open files shared between processes */
>  #define CLONE_SIGHAND	0x00000800	/* set if signal handlers and blocked signals shared */
> +#define CLONE_SYSLOG	0x00001000	/* set if we need private syslog (/proc/kmsg)	*/

Check with Suka on this one -- I seem to recall specific unused CLONE_ flags
are, unfortunately, reserved. Otherwise yes, this is the right place and what
Serge suggested.

<snip>

> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 3d0c73e..cc4f453 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -14,7 +14,6 @@ struct user_namespace {
>  	struct hlist_head	uidhash_table[UIDHASH_SZ];
>  	struct user_struct	*creator;
>  	struct work_struct	destroyer;
> -	struct syslog_ns        *syslog;
>  };
> 
>  extern struct user_namespace init_user_ns;
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f88bd98..38c8d8c 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1647,7 +1647,7 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
>  	err = -EINVAL;
>  	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
>  				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
> -				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
> +				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|CLONE_SYSLOG))

You shouldn't be able to unshare syslog -- I think it's a security concern.
I think just keeping CLONE_SYSLOG out of this set is sufficient for sys_unshare.
There's a corresponding check in clone/clone2/eclone which would be similar to
how CLONE_NEWPID is privileged.

>  		goto bad_unshare_out;
> 
>  	/*
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 09b4ff9..ff968db 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -44,6 +44,8 @@ static inline struct nsproxy *create_nsproxy(void)
>  static struct nsproxy *create_new_namespaces(unsigned long flags,
>  			struct task_struct *tsk, struct fs_struct *new_fs)
>  {
> +#define	CONTAINER_BUF_LEN	4096	/*should be enough for container syslog	*/
> +
>  	struct nsproxy *new_nsp;
>  	int err;
> 
> @@ -80,9 +82,17 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>  		err = PTR_ERR(new_nsp->net_ns);
>  		goto out_net;
>  	}
> -
> +	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk->nsproxy->syslog_ns);
> +	if (IS_ERR(new_nsp->syslog_ns)) {
> +		err = PTR_ERR(new_nsp->syslog_ns);
> +		goto out_syslog;
> +	}
> +	
>  	return new_nsp;
> 
> +out_syslog:
> +	if (new_nsp->net_ns) 
> +		put_net(new_nsp->net_ns);
>  out_net:
>  	if (new_nsp->pid_ns)
>  		put_pid_ns(new_nsp->pid_ns);
> @@ -116,7 +126,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  	get_nsproxy(old_ns);
> 
>  	if (!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
> -				CLONE_NEWPID | CLONE_NEWNET)))
> +				CLONE_NEWPID | CLONE_NEWNET | CLONE_SYSLOG)))
>  		return 0;
> 
>  	if (!capable(CAP_SYS_ADMIN)) {
> @@ -151,6 +161,8 @@ out:
> 
>  void free_nsproxy(struct nsproxy *ns)
>  {
> +	if (ns->syslog_ns)
> +		ns->syslog_ns=release_syslog_ns(ns->syslog_ns);

style: space around the assignment operator.
See the kernel Documentation on contributing patches and the style of
kernel code -- those are our standards too. scripts/checkpatch.pl will
also find many of these things for you.

>  	if (ns->mnt_ns)
>  		put_mnt_ns(ns->mnt_ns);
>  	if (ns->uts_ns)
> @@ -173,7 +185,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
>  	int err = 0;
> 
>  	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
> -			       CLONE_NEWNET)))
> +			       CLONE_NEWNET | CLONE_SYSLOG )))

You shouldn't be able to unshare syslog. It should require using a privileged
clone() call like CLONE_NEWPID. So CLONE_SYSLOG doesn't belong here I think.

>  		return 0;
> 
>  	if (!capable(CAP_SYS_ADMIN))
> diff --git a/kernel/printk.c b/kernel/printk.c
> index fd0a05c..3c7f213 100644
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
> @@ -148,7 +148,7 @@ static int saved_console_loglevel = -1;
>   */
>  void log_buf_kexec_setup(void)
>  {
> -	struct syslog_ns *syslog_ns = syslog_get_current();
> +	struct syslog_ns *syslog_ns = get_current_syslog_ns();
> 
>  	VMCOREINFO_SYMBOL(sys_log_buf);
>  	VMCOREINFO_SYMBOL(sys_log_end);
> @@ -163,7 +163,7 @@ static int __init log_buf_len_setup(char *str)
> 
>  	if (size) {
>  		size = roundup_pow_of_two(size);
> -		(void) syslog_realloc(&init_kernel_syslog_ns,size);
> +		(void) realloc_syslog_ns(&init_kernel_syslog_ns,size);

style: The namechange looks fine. The (void) cast does not.

>  	}
>  	return 1;
>  }
> @@ -244,7 +244,7 @@ int do_syslog(int type, char __user *buf, int len)
>  	int do_clear = 0;
>  	char c;
>  	int error = 0;
> -	struct syslog_ns *syslog_ns = syslog_get_current();
> +	struct syslog_ns *syslog_ns = get_current_syslog_ns();
> 
>  	error = security_syslog(type);
>  	if (error)
> @@ -638,7 +638,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
>  {
>  	int printed_len = 0;
>  	int current_log_level = default_message_loglevel;
> -	struct syslog_ns *syslog_ns = syslog_get_current();
> +	struct syslog_ns *syslog_ns = get_current_syslog_ns();
>  	unsigned long flags;
>  	int this_cpu;
>  	char *p;
> @@ -1012,7 +1012,7 @@ void release_console_sem(void)
>  		unsigned long flags;
>  		unsigned _con_start, _log_end;
>  		unsigned wake_klogd = 0;
> -		struct syslog_ns *syslog_ns = syslog_get_current();
> +		struct syslog_ns *syslog_ns = get_current_syslog_ns();

In kernel code, especially namespaces, "get" implies taking an extra reference. 
So get_current_syslog_ns() needs a different name. I'd name it like the pid
namespace: anything without _ns on the end uses "current".

> 
>  		for ( ; ; ) {
>  			spin_lock_irqsave(&sys_log_lock, flags);
> @@ -1252,7 +1252,7 @@ void register_console(struct console *newcon)
>  		 * for us.
>  		 */
> 
> -		struct syslog_ns *syslog_ns = syslog_get_current();
> +		struct syslog_ns *syslog_ns = get_current_syslog_ns();

I don't think current necessarily has the relevant syslog_ns here.
Current will probably be the tasks involved in device coldplugging --
not the tasks that will be using the console for output. Console/tty code
is especially tricky as I recall. This needs more review from someone more
familiar with that area I think.

> 
>  		spin_lock_irqsave(&sys_log_lock, flags);
>  		sys_log_con_start = sys_log_start;
> @@ -1462,7 +1462,7 @@ void kmsg_dump(enum kmsg_dump_reason reason)
>  	const char *s1, *s2;
>  	unsigned long l1, l2;
>  	unsigned long flags;
> -	struct syslog_ns *syslog_ns = syslog_get_current();
> +	struct syslog_ns *syslog_ns = get_current_syslog_ns();
> 
>  	/* Theoretically, the log could move on after we do this, but
>  	   there's not a lot we can do about that. The new messages
> diff --git a/kernel/syslog.c b/kernel/syslog.c
> index 69d30a9..0088a85 100644
> --- a/kernel/syslog.c
> +++ b/kernel/syslog.c
> @@ -22,35 +22,66 @@
>   *
>   */
> 
> +#include <linux/module.h>
>  #include <linux/bootmem.h>
>  #include <linux/slab.h>
>  #include <linux/cred.h>
> +#include <linux/kref.h>
>  #include <linux/user_namespace.h>
>  #include <linux/syslog.h>
> 
> +#ifdef CONFIG_PRINTK

Shouldn't syslog.c only be compiled if CONFIG_PRINTK is defined?
That's a patch to the kernel/Makefile:

obj-$(CONFIG_PRINTK) += syslog.o

Then I think you can avoid this #ifdef entirely.

>  /*
>   * Static memory definition, used to assign a syslog
>   * to the kernel itself
>   *
>   */
> -
> -#ifdef CONFIG_PRINTK

I suppose. Again, not a substantial change. To me the comment
is unnecessary. This init_foo_ns pattern is quite recognizable to
anyone familiar with how things are initialized in the kernel.

>  #define __LOG_BUF_LEN   (1 << CONFIG_LOG_BUF_SHIFT)
> 
>  static char __log_buf[__LOG_BUF_LEN];
> 
>  struct syslog_ns init_kernel_syslog_ns = {
> +	.kref = {
> +		.refcount	= ATOMIC_INIT(2),
> +	},
>          .wait = __WAIT_QUEUE_HEAD_INITIALIZER(init_kernel_syslog_ns.wait),
>          .buf_len = __LOG_BUF_LEN,
>          .buf = __log_buf
>  };
> +EXPORT_SYMBOL_GPL(init_kernel_syslog_ns);
>  #endif
> +/*
> + * Procedure to free all ressources tied to syslog
> + *
> + */
> +struct syslog_ns *syslog_free(struct syslog_ns *syslog)
> +
> +{
> +	if (syslog != (struct syslog_ns *)0) {
> +		(void) kfree(syslog->buf);
> +		(void) kfree(syslog);
> +		syslog = (struct syslog_ns *)0;
> +		}

Ugh. Please run your stuff through checkpatch before the next posting.

> +	return syslog;
> +}
> 
>  /*
> + * Procedure to interface kref _put with syslog_free
> + *
> + */
> +static void syslog_out(struct kref *kref)
> +
> +{
> +	struct syslog_ns *sl;
> +
> +	sl=container_of(kref, struct syslog_ns, kref);	
> +	sl=syslog_free(sl);
> +}
> +/*
>   * Procedure to assign memory for syslog area
>   *
>   */
> -struct syslog_ns * syslog_malloc(unsigned container_buf_len)
> +static struct syslog_ns * malloc_syslog_ns(unsigned container_buf_len)

For namespaces we've been using "create" rather than foo_[m]alloc.
create_pid_namespace, create_user_ns, create_uts_ns, etc.

>  {
>  	struct syslog_ns *ns;
> 
> @@ -61,6 +92,8 @@ struct syslog_ns * syslog_malloc(unsigned container_buf_len)
>  	if (!ns)
>  		return ERR_PTR(-ENOMEM);
> 
> +	(void) kref_init(&(ns->kref));
> +
>  	ns->buf_len = container_buf_len;
>  	ns->buf = kzalloc(container_buf_len, GFP_KERNEL);
>  	if (!ns->buf) {
> @@ -77,7 +110,7 @@ struct syslog_ns * syslog_malloc(unsigned container_buf_len)
>   * If syslog_ns is NULL, assign a brand new syslog_ns
>   *
>   */
> -struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned container_buf_len)
> +struct syslog_ns * realloc_syslog_ns(struct syslog_ns *syslog_ns, unsigned container_buf_len)

Does this change the syslog_ns pointer, or just the buffer size? If the latter
then resize might be a better word.

> 
>  {
>  	if ((syslog_ns == &init_kernel_syslog_ns ) && (container_buf_len > syslog_ns->buf_len)) {
> @@ -102,7 +135,7 @@ struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned containe
>  			(void) free_bootmem((unsigned long)old_buf, old_buf_len);
>  		}
>  	if (!syslog_ns)
> -		return syslog_malloc(container_buf_len);
> +		return malloc_syslog_ns(container_buf_len);
>  	if (syslog_ns->buf_len > container_buf_len) {
>  		(void) printk(KERN_WARNING "log_buf_len: Not allowed to decrease syslog buffer\n");
>  		return ERR_PTR(-EINVAL);
> @@ -126,32 +159,51 @@ struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned containe
>  	(void) printk(KERN_NOTICE "log_buf_len: %u\n", syslog_ns->buf_len);
>  	return syslog_ns;
>  }
> +
>  /*
> - * Procedure to free all ressources tied to syslog
> + * Procedure to use current syslog unless a CLONE_SYSLOG is set
> + * such a new syslog area is defined and used
>   *
>   */
> -struct syslog_ns *syslog_free(struct syslog_ns *syslog)
> +struct syslog_ns *copy_syslog_ns(unsigned long flags,struct syslog_ns *current_syslog_ns)
> 
>  {
> -	if (syslog != (struct syslog_ns *)0) {
> -		(void) kfree(syslog->buf);
> -		(void) kfree(syslog);
> -		syslog = (struct syslog_ns *)0;
> -		}
> -	return syslog;
> +#define	CONTAINER_BUF_LEN	4096	/*should be enough for container syslog	*/
> +
> +	BUG_ON(!current_syslog_ns);
> +	if ((flags & CLONE_SYSLOG) == 0) /*incrementing usage reference count	*/
> +		(void) kref_get(&(current_syslog_ns->kref));
> +	else
> +		current_syslog_ns=malloc_syslog_ns(CONTAINER_BUF_LEN);
> +	return current_syslog_ns;
> +	
> +}
> +
> +/*
> + * Procedure to decrement syslog usage count and free memory
> + * if syslog usage count reach zero.
> + *
> + */
> +struct syslog_ns *release_syslog_ns(struct syslog_ns *current_syslog_ns)
> +
> +{
> +	if (kref_put(&(current_syslog_ns->kref), syslog_out)==0)
> +	   current_syslog_ns=(struct syslog_ns *)0;
> +	return current_syslog_ns;
>  }
> 
>  /*
> - * Procedure to get the current syslog area linked to a container (by CLONE_USER)
> + * Procedure to get the current syslog area linked to a container (by CLONE_SYSLOG)
>   * if trouble, pin down the problem before it propagate.
>   *
>   */
> -struct syslog_ns *syslog_get_current(void) 
> +struct syslog_ns *get_current_syslog_ns(void) 
> 
>  {
> +

Whitespace changes mixed with other changes are also frowned upon.
This one is totally unnecessary.

So please read up on kernel style and patch submission. Please use checkpatch.pl
Please break up your patch where it's logical to do so.

Cheers,
	-Matt Helsley
