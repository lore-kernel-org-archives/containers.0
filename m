From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC] catching sys_reboot syscall
Date: Wed, 10 Aug 2011 22:10:28 +0200
Message-ID: <20110810221028.2e0c8590@neptune.home>
References: <4E4051A0.8030009@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E4051A0.8030009-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC Development <Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Daniel,

[I'm adding containers ml as we had a discussion there some time ago
 for this feature]

One comment below:

On Mon, 08 August 2011 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
> Hi all,
> 
> I am trying to solve one of the problems the linux container community
> is facing :
> 
>    How to catch when a process called the 'reboot' syscall in a container ?
> 
> In the case of a VPS, when we shutdown/halt/reboot the container, the
> reboot utility will invoke the sys_reboot syscall which has the bad
> effect to reboot the host. The way to fix that is to drop the
> CAP_SYS_REBOOT capability in the container.
> 
> In this case, the container shutdowns correctly but, at the end, the
> init process is waiting indefinitely and we have the containers stuck
> with one process (the init process).
> 
> In order to fix that, we used a hypervisor process, parent of the
> container's init process, watching for the container's utmp file and
> detecting when the runlevel changes. When this runlevel change is
> detected we wait for the container to have one process left and then we
> kill the container's init.
> 
> That works well if we modify the distro configuration files, we make
> /var/run to not be a tmpfs and we remove all the files inside this
> directory when the container boots. *But* as soon as we upgrade the
> container distro, all the tweaks are lost. So this method works but at
> the cost of tweaking the containers configuration files again and again,
> each time there is an update, which is not tolerable in a production
> environment.
> 
> This problem is easy to solve with a small hack in the kernel:
> 
> diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
> index 942d30b..61f3d02 100644
> --- a/include/asm-generic/siginfo.h
> +++ b/include/asm-generic/siginfo.h
> @@ -218,7 +218,8 @@ typedef struct siginfo {
>  #define CLD_TRAPPED    (__SI_CHLD|4)    /* traced child has trapped */
>  #define CLD_STOPPED    (__SI_CHLD|5)    /* child has stopped */
>  #define CLD_CONTINUED    (__SI_CHLD|6)    /* stopped child has continued */
> -#define NSIGCHLD    6
> +#define CLD_REBOOTED    (__SI_CHLD|7)   /* process was killed by a
> reboot */
> +#define NSIGCHLD    7
>  
>  /*
>   * SIGPOLL si_codes
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 67f5688..41e0889 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2103,6 +2103,7 @@ extern int kill_pgrp(struct pid *pid, int sig, int
> priv);
>  extern int kill_pid(struct pid *pid, int sig, int priv);
>  extern int kill_proc_info(int, struct siginfo *, pid_t);
>  extern int do_notify_parent(struct task_struct *, int);
> +extern void do_notify_parent_cldreboot(struct task_struct *, int, char *);
>  extern void __wake_up_parent(struct task_struct *p, struct task_struct
> *parent);
>  extern void force_sig(int, struct task_struct *);
>  extern int send_sig(int, struct task_struct *, int);
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 4e3cff1..09fc254 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1522,6 +1522,46 @@ int do_notify_parent(struct task_struct *tsk, int
> sig)
>      return ret;
>  }
>  
> +void do_notify_parent_cldreboot(struct task_struct *tsk, int why, char
> *buffer)
> +{
> +    struct siginfo info = { };
> +    struct task_struct *parent;
> +    struct sighand_struct *sighand;
> +    unsigned long flags;
> +
> +    if (task_ptrace(tsk))
> +        parent = tsk->parent;
> +    else {
> +        tsk = tsk->group_leader;
> +        parent = tsk->real_parent;
> +    }
> +
> +    info.si_signo = SIGCHLD;
> +    info.si_errno = 0;
> +    info.si_status = why;
> +
> +    rcu_read_lock();
> +    info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
> +    info.si_uid = __task_cred(tsk)->uid;
> +    rcu_read_unlock();
> +
> +    info.si_utime = cputime_to_clock_t(tsk->utime);
> +    info.si_stime = cputime_to_clock_t(tsk->stime);
> +
> +    info.si_code = CLD_REBOOTED;
> +
> +    sighand = parent->sighand;
> +    spin_lock_irqsave(&sighand->siglock, flags);
> +    if (sighand->action[SIGCHLD-1].sa.sa_handler != SIG_IGN &&
> +        sighand->action[SIGCHLD-1].sa.sa_flags & SA_CLDREBOOT)
> +        __group_send_sig_info(SIGCHLD, &info, parent);
> +    /*
> +     * Even if SIGCHLD is not generated, we must wake up wait4 calls.
> +     */
> +    __wake_up_parent(tsk, parent);
> +    spin_unlock_irqrestore(&sighand->siglock, flags);
> +}
> +
>  static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
>  {
>      struct siginfo info;
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 18da702..b50449c 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -361,6 +361,13 @@ void kernel_power_off(void)
>  }
>  EXPORT_SYMBOL_GPL(kernel_power_off);
>  
> +static void pid_namespace_reboot(struct pid_namespace *pid_ns,
> +                int cmd, char *buffer)
> +{
> +    struct task_struct *tsk = pid_ns->child_reaper;
> +    do_notify_parent_cldreboot(tsk, cmd, buffer);
> +}
> +
>  static DEFINE_MUTEX(reboot_mutex);
>  
>  /*
> @@ -374,13 +381,10 @@ static DEFINE_MUTEX(reboot_mutex);
>  SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>          void __user *, arg)
>  {
> -    char buffer[256];
> +    struct pid_namespace *pid_ns = current->nsproxy->pid_ns;
> +    char buffer[256] = { 0 };
>      int ret = 0;
>  
> -    /* We only trust the superuser with rebooting the system. */
> -    if (!capable(CAP_SYS_BOOT))
> -        return -EPERM;
> -
>      /* For safety, we require "magic" arguments. */
>      if (magic1 != LINUX_REBOOT_MAGIC1 ||
>          (magic2 != LINUX_REBOOT_MAGIC2 &&
> @@ -395,12 +399,45 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2,
> unsigned int, cmd,
>      if ((cmd == LINUX_REBOOT_CMD_POWER_OFF) && !pm_power_off)
>          cmd = LINUX_REBOOT_CMD_HALT;
>  
> +    /* check the cmd parameter */
> +    if (cmd != LINUX_REBOOT_CMD_RESTART &&
> +#ifdef CONFIG_KEXEC
> +        cmd != LINUX_REBOOT_CMD_KEXEC &&
> +#endif
> +#ifdef CONFIG_HIBERNATION
> +        cmd != LINUX_REBOOT_CMD_SW_SUSPEND &&
> +#endif
> +        cmd != LINUX_REBOOT_CMD_CAD_ON &&
> +        cmd != LINUX_REBOOT_CMD_CAD_OFF &&
> +        cmd != LINUX_REBOOT_CMD_HALT &&
> +        cmd != LINUX_REBOOT_CMD_POWER_OFF &&
> +        cmd != LINUX_REBOOT_CMD_RESTART2)
> +        return -EINVAL;
> +
> +    if (cmd == LINUX_REBOOT_CMD_RESTART2)
> +        if (strncpy_from_user(&buffer[0], arg, sizeof(buffer) - 1) < 0)
> +            return -EFAULT;
> +
> +    /* If we are not in the initial pid namespace, we send a signal
> +     * to the parent of this init pid namespace, notifying a shutdown
> +     * occured */
> +    if (pid_ns != &init_pid_ns)
> +        pid_namespace_reboot(pid_ns, cmd, buffer);

Should there be a return here?
Or does pid_namespace_reboot() never return by submitting signal to
parent?

Thanks,
Bruno



> +
> +    /* We only trust the superuser with rebooting the system. */
> +    if (!capable(CAP_SYS_BOOT))
> +        return -EPERM;
> +
>      mutex_lock(&reboot_mutex);
>      switch (cmd) {
>      case LINUX_REBOOT_CMD_RESTART:
>          kernel_restart(NULL);
>          break;
>  
> +    case LINUX_REBOOT_CMD_RESTART2:
> +        kernel_restart(buffer);
> +        break;
> +
>      case LINUX_REBOOT_CMD_CAD_ON:
>          C_A_D = 1;
>          break;
> @@ -419,16 +456,6 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2,
> unsigned int, cmd,
>          do_exit(0);
>          break;
>  
> -    case LINUX_REBOOT_CMD_RESTART2:
> -        if (strncpy_from_user(&buffer[0], arg, sizeof(buffer) - 1) < 0) {
> -            ret = -EFAULT;
> -            break;
> -        }
> -        buffer[sizeof(buffer) - 1] = '\0';
> -
> -        kernel_restart(buffer);
> -        break;
> -
>  #ifdef CONFIG_KEXEC
>      case LINUX_REBOOT_CMD_KEXEC:
>          ret = kernel_kexec();
> @@ -440,10 +467,6 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2,
> unsigned int, cmd,
>          ret = hibernate();
>          break;
>  #endif
> -
> -    default:
> -        ret = -EINVAL;
> -        break;
>      }
>      mutex_unlock(&reboot_mutex);
>      return ret;
> 
> 
> With this patch, the container's init parent will receive a SIGCHLD,
> with ssi_code set with the sys_reboot parameter value, when one of the
> process in the container invoke sys_reboot. This solution works very
> well and solves the problem but is it acceptable ? I don't see any
> alternative usable for other use cases. It is probable nobody cares
> about sys_reboot was called because there is nothing to do as the system
> will halt a few microseconds after :)
> 
> Does anyone have an idea ?
> 
> Thanks in advance
>   -- Daniel
