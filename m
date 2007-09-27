From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 2/5] Move the UST namespace under the option
Date: Thu, 27 Sep 2007 14:29:33 +0200
Message-ID: <46FBA22D.9070704@fr.ibm.com>
References: <46FA7D4D.8040808@openvz.org> <46FA7EC8.3020800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756714AbXI0M3t@vger.kernel.org>
In-Reply-To: <46FA7EC8.3020800@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Serge Hallyn <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Currently all the namespace management code is in the
> kernel/utsname.c file, so just compile it out and make
> stub in .h file.
> 
> The init namespace itself is in init/version.c and is
> left in the kernel.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Cedric Le Goater <clg@fr.ibm.com>

Thanks !

C. 
> 
> ---
> 
> diff --git a/include/linux/utsname.h b/include/linux/utsname.h
> index 923db99..52b9116 100644
> --- a/include/linux/utsname.h
> +++ b/include/linux/utsname.h
> @@ -35,6 +35,7 @@ struct new_utsname {
>  #include <linux/sched.h>
>  #include <linux/kref.h>
>  #include <linux/nsproxy.h>
> +#include <linux/err.h>
>  #include <asm/atomic.h>
> 
>  struct uts_namespace {
> @@ -43,6 +44,7 @@ struct uts_namespace {
>  };
>  extern struct uts_namespace init_uts_ns;
> 
> +#ifdef CONFIG_NAMESPACES
>  static inline void get_uts_ns(struct uts_namespace *ns)
>  {
>  	kref_get(&ns->kref);
> @@ -56,6 +58,25 @@ static inline void put_uts_ns(struct uts
>  {
>  	kref_put(&ns->kref, free_uts_ns);
>  }
> +#else
> +static inline void get_uts_ns(struct uts_namespace *ns)
> +{
> +}
> +
> +static inline void put_uts_ns(struct uts_namespace *ns)
> +{
> +}
> +
> +static inline struct uts_namespace *copy_utsname(unsigned long flags,
> +					struct uts_namespace *ns)
> +{
> +	if (flags & CLONE_NEWUTS)
> +		return ERR_PTR(-EINVAL);
> +
> +	return ns;
> +}
> +#endif
> +
>  static inline struct new_utsname *utsname(void)
>  {
>  	return &current->nsproxy->uts_ns->name;
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 76f782f..5817bfe 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -4,8 +4,7 @@
>  	    signal.o sys.o kmod.o workqueue.o pid.o \
>  	    rcupdate.o extable.o params.o posix-timers.o \
>  	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o mutex.o \
> -	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o \
> -	    utsname.o notifier.o sysctl.o
> +	    hrtimer.o rwsem.o latency.o nsproxy.o srcu.o notifier.o sysctl.o
> 
>  obj-$(CONFIG_SYSCTL) += sysctl_check.o
>  obj-$(CONFIG_STACKTRACE) += stacktrace.o
> @@ -50,6 +49,7 @@ obj-$(CONFIG_AUDITSYSCALL) += auditsc.o
>  obj-$(CONFIG_AUDIT_TREE) += audit_tree.o
>  obj-$(CONFIG_KPROBES) += kprobes.o
>  obj-$(CONFIG_KGDB) += kgdb.o
> +obj-$(CONFIG_NAMESPACES) += utsname.o
>  obj-$(CONFIG_SYSFS) += ksysfs.o
>  obj-$(CONFIG_DETECT_SOFTLOCKUP) += softlockup.o
>  obj-$(CONFIG_GENERIC_HARDIRQS) += irq/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
