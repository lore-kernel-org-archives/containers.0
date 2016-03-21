From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH v2 3/3] Make core_pattern support namespace
Date: Mon, 21 Mar 2016 15:16:31 +0800
Message-ID: <00fa01d18341$986e1880$c94a4980$@cn.fujitsu.com>
References: <cover.1458305141.git.zhaolei@cn.fujitsu.com>	<77053bb2bdd21489e09b6ef362044d283e1ba12b.1458305141.git.zhaolei@cn.fujitsu.com>
	<87twk0tlok.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87twk0tlok.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "'Eric W. Biederman'" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Eric W. Biederman

> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
> Sent: Monday, March 21, 2016 2:00 PM
> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
> Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Subject: Re: [PATCH v2 3/3] Make core_pattern support namespace
> 
> Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
> > Currently, each container shared one copy of coredump setting
> > with the host system, if host system changed the setting, each
> > running containers will be affected.
> >
> > Moreover, it is not easy to let each container keeping their own
> > coredump setting.
> >
> > We can use some workaround as pipe program to make the second
> > requirement possible, but it is not simple, and both host and
> > container are limited to set to fixed pipe program.
> > In one word, for host running contailer, we can't change core_pattern
> > anymore.
> > To make the problem more hard, if a host running more than one
> > container product, each product will try to snatch the global
> > coredump setting to fit their own requirement.
> >
> > For container based on namespace design, it is good to allow
> > each container keeping their own coredump setting.
> >
> > It will bring us following benefit:
> > 1: Each container can change their own coredump setting
> >    based on operation on /proc/sys/kernel/core_pattern
> > 2: Coredump setting changed in host will not affect
> >    running containers.
> > 3: Support both case of "putting coredump in guest" and
> >    "putting curedump in host".
> >
> > Each namespace-based software(lxc, docker, ..) can use this function
> > to custom their dump setting.
> >
> > And this function makes each continer working as separate system,
> > it fit for design goal of namespace
> 
> There are a lot of questionable things with this patchset.
> 
> > @@ -183,7 +182,7 @@ put_exe_file:
> >  static int format_corename(struct core_name *cn, struct
> coredump_params *cprm)
> >  {
> >  	const struct cred *cred = current_cred();
> > -	const char *pat_ptr = core_pattern;
> > +	const char *pat_ptr =
> current->nsproxy->pid_ns_for_children->core_pattern;
> 
> current->nsproxy->pid_ns_for_children as the name implies is completely
> inappropriate for getting the pid namespace of the current task.
> 
> This should use task_active_pid_namespace.
> 
In 5 members in nsproxy struct, pid_ns_for_children seems the best place
for this variable.

And no variable named task_active_pid_namespace in source,
could you explain it deeply?

> >  	int ispipe = (*pat_ptr == '|');
> >  	int pid_in_pattern = 0;
> >  	int err = 0;
> > diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> > index 918b117..a5af1e9 100644
> > --- a/include/linux/pid_namespace.h
> > +++ b/include/linux/pid_namespace.h
> > @@ -9,6 +9,7 @@
> >  #include <linux/nsproxy.h>
> >  #include <linux/kref.h>
> >  #include <linux/ns_common.h>
> > +#include <linux/binfmts.h>
> >
> >  struct pidmap {
> >         atomic_t nr_free;
> > @@ -45,6 +46,7 @@ struct pid_namespace {
> >  	int hide_pid;
> >  	int reboot;	/* group exit code if this pidns was rebooted */
> >  	struct ns_common ns;
> > +	char core_pattern[CORENAME_MAX_SIZE];
> >  };
> >
> >  extern struct pid_namespace init_pid_ns;
> > diff --git a/kernel/pid.c b/kernel/pid.c
> > index 4d73a83..c79c1d5 100644
> > --- a/kernel/pid.c
> > +++ b/kernel/pid.c
> > @@ -83,6 +83,7 @@ struct pid_namespace init_pid_ns = {
> >  #ifdef CONFIG_PID_NS
> >  	.ns.ops = &pidns_operations,
> >  #endif
> > +	.core_pattern = "core",
> >  };
> >  EXPORT_SYMBOL_GPL(init_pid_ns);
> >
> > diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> > index a65ba13..16d6d21 100644
> > --- a/kernel/pid_namespace.c
> > +++ b/kernel/pid_namespace.c
> > @@ -123,6 +123,9 @@ static struct pid_namespace
> *create_pid_namespace(struct user_namespace *user_ns
> >  	for (i = 1; i < PIDMAP_ENTRIES; i++)
> >  		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
> >
> > +	strncpy(ns->core_pattern, parent_pid_ns->core_pattern,
> > +		sizeof(ns->core_pattern));
> > +
> 
> This is pretty horrible.  You are giving unprivileged processes the
> ability to run an already specified core dump helper in a pid namespace
> of their choosing.
> 
Similar problem before patch.
In piped core_pattern setting, any panic process will trigger a
running of core_dump process.

Comparing to current code, current code maybe more horrible,
the guest can destroy host system, and after this patch, the guest
can only destroy itself.
(As the script in patch description)

Actually it is not so horrible, only the root user can modify code_pattern,
and normal user/process have no chance to do bad thing.

> That is not backwards compatible, and it is possible this can lead to
> privilege escalation by triciking a privileged dump process to do
> something silly because it is running in the wrong pid namespace.
> 
In current code, the dump process is forking from kernel thread,
it is in a most-privileged namespace, dumping contents into host's fs,
it really cause problem.
Compare to current code, running dump process in container's
namespace maybe the right way.

The only thing this patch do is letting dump program running in
container's namespace instead of host.

> Similarly the entire concept of forking from the program dumping core
> suffers from the same problem but for all other namespaces.
> 
> I was hoping that I would see a justification somewhere in the patch
> descriptions describing why this set of decisions could be safe.  I do
> not and so I assume this case was not considered.
> 
> If you had managed to fork for the child_reaper of the pid_namespace
> that set the core pattern (as has been suggested) there would be some
> chance that things would work correctly.
Do you mean do fork in kthread(who is running in host's namespace, as corrent code)
with some special operation to change new thread running in container's
namespace?

> As you are forking from the program actually dumping core I see no
> chance that this patchset is either safe or backwards compatible as
> currently written.
> 
Current code have obvious problem, this forking new thread in container's
namespace is nothing but safe than host's namespace.
At least we need to solve the problem descripted in script in patch
description.

The only thing is backwards compatible, as our discussion in v1 patch,
it is the thing we need to change.

Thanks
Zhaolei
