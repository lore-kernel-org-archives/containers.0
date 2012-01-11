From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 1/1][V5] Add reboot_pid_ns to handle the reboot syscall
Date: Wed, 11 Jan 2012 11:23:46 +0100
Message-ID: <20120111102346.GB8504@peqn>
References: <1325754410-32600-1-git-send-email-daniel.lezcano@free.fr>
	<1325754410-32600-2-git-send-email-daniel.lezcano@free.fr>
	<20120105192954.GA16083@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120105192954.GA16083@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge Hallyn (serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org):
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> > In the case of a child pid namespace, rebooting the system does not
> > really makes sense. When the pid namespace is used in conjunction
> > with the other namespaces in order to create a linux container, the
> > reboot syscall leads to some problems.
> > 
> > A container can reboot the host. That can be fixed by dropping
> > the sys_reboot capability but we are unable to correctly to poweroff/
> > halt/reboot a container and the container stays stuck at the shutdown
> > time with the container's init process waiting indefinitively.
> > 
> > After several attempts, no solution from userspace was found to reliabily
> > handle the shutdown from a container.
> > 
> > This patch propose to make the init process of the child pid namespace to
> > exit with a signal status set to : SIGINT if the child pid namespace called
> > "halt/poweroff" and SIGHUP if the child pid namespace called "reboot".
> > When the reboot syscall is called and we are not in the initial
> > pid namespace, we kill the pid namespace for "HALT", "POWEROFF", "RESTART",
> > and "RESTART2". Otherwise we return EINVAL.
> > 
> > Returning EINVAL is also an easy way to check if this feature is supported
> > by the kernel when invoking another 'reboot' option like CAD.
> > 
> > By this way the parent process of the child pid namespace knows if
> > it rebooted or not and can take the right decision.
> > 
> > Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> > Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Reviewed-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> The testcase in [PATCH 0/1] passed for me, and reboot from init_pid_ns
> works as usual.
> 
> Tested-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Hi Andrew,

Are you considering taking this patch into -mm?

thanks,
-serge

> 
> thanks,
> -serge
> 
> > ---
> >  include/linux/pid_namespace.h |    8 +++++++-
> >  kernel/pid_namespace.c        |   33 +++++++++++++++++++++++++++++++++
> >  kernel/sys.c                  |    8 ++++++++
> >  3 files changed, 48 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> > index e7cf666..b90c798 100644
> > --- a/include/linux/pid_namespace.h
> > +++ b/include/linux/pid_namespace.h
> > @@ -32,6 +32,7 @@ struct pid_namespace {
> >  #endif
> >  	gid_t pid_gid;
> >  	int hide_pid;
> > +	int reboot;
> >  };
> >  
> >  extern struct pid_namespace init_pid_ns;
> > @@ -47,6 +48,7 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
> >  extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
> >  extern void free_pid_ns(struct kref *kref);
> >  extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
> > +extern int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd);
> >  
> >  static inline void put_pid_ns(struct pid_namespace *ns)
> >  {
> > @@ -74,11 +76,15 @@ static inline void put_pid_ns(struct pid_namespace *ns)
> >  {
> >  }
> >  
> > -
> >  static inline void zap_pid_ns_processes(struct pid_namespace *ns)
> >  {
> >  	BUG();
> >  }
> > +
> > +static inline int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
> > +{
> > +	return 0;
> > +}
> >  #endif /* CONFIG_PID_NS */
> >  
> >  extern struct pid_namespace *task_active_pid_ns(struct task_struct *tsk);
> > diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> > index a896839..0d355e8 100644
> > --- a/kernel/pid_namespace.c
> > +++ b/kernel/pid_namespace.c
> > @@ -15,6 +15,7 @@
> >  #include <linux/acct.h>
> >  #include <linux/slab.h>
> >  #include <linux/proc_fs.h>
> > +#include <linux/reboot.h>
> >  
> >  #define BITS_PER_PAGE		(PAGE_SIZE*8)
> >  
> > @@ -187,6 +188,9 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
> >  		rc = sys_wait4(-1, NULL, __WALL, NULL);
> >  	} while (rc != -ECHILD);
> >  
> > +	if (pid_ns->reboot)
> > +		current->signal->group_exit_code = pid_ns->reboot;
> > +
> >  	acct_exit_ns(pid_ns);
> >  	return;
> >  }
> > @@ -221,6 +225,35 @@ static struct ctl_table pid_ns_ctl_table[] = {
> >  
> >  static struct ctl_path kern_path[] = { { .procname = "kernel", }, { } };
> >  
> > +int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
> > +{
> > +	if (pid_ns == &init_pid_ns)
> > +		return 0;
> > +
> > +	switch(cmd) {
> > +	case LINUX_REBOOT_CMD_RESTART2:
> > +	case LINUX_REBOOT_CMD_RESTART:
> > +		pid_ns->reboot = SIGHUP;
> > +		break;
> > +
> > +	case LINUX_REBOOT_CMD_POWER_OFF:
> > +	case LINUX_REBOOT_CMD_HALT:
> > +		pid_ns->reboot = SIGINT;
> > +		break;
> > +	default:
> > +		return -EINVAL;
> > +	}
> > +
> > +	read_lock(&tasklist_lock);
> > +	force_sig(SIGKILL, pid_ns->child_reaper);
> > +	read_unlock(&tasklist_lock);
> > +
> > +	do_exit(0);
> > +
> > +	/* Not reached */
> > +	return 0;
> > +}
> > +
> >  static __init int pid_namespaces_init(void)
> >  {
> >  	pid_ns_cachep = KMEM_CACHE(pid_namespace, SLAB_PANIC);
> > diff --git a/kernel/sys.c b/kernel/sys.c
> > index 4070153..bd924fa 100644
> > --- a/kernel/sys.c
> > +++ b/kernel/sys.c
> > @@ -444,6 +444,14 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
> >  	                magic2 != LINUX_REBOOT_MAGIC2C))
> >  		return -EINVAL;
> >  
> > +	/* In case the pid namespaces are enabled, the current task is in a
> > +	 * child pid_namespace and the command is handled by 'reboot_pid_ns',
> > +	 * this one will invoke 'do_exit'.
> > +	 */
> > +	ret = reboot_pid_ns(task_active_pid_ns(current), cmd);
> > +	if (ret)
> > +		return ret;
> > +
> >  	/* Instead of trying to make the power_off code look like
> >  	 * halt when pm_power_off is not set do it the easy way.
> >  	 */
> > -- 
> > 1.7.5.4
> > 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
