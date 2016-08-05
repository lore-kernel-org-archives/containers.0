From: 'Andrei Vagin' <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 1/2] Limit dump_pipe program's permission to init for
	container
Date: Fri, 5 Aug 2016 10:13:40 -0700
Message-ID: <20160805171339.GA19853@gmail.com>
References: <cover.1470128571.git.zhaolei@cn.fujitsu.com>
	<c7d8e45aa76a414c73082d22d325cd5a13979773.1470128572.git.zhaolei@cn.fujitsu.com>
	<CANaxB-yz2AbjQYLLfXF03A-H=b5FV6+Dc8egorFFydbtZO-9Mg@mail.gmail.com>
	<012701d1eeee$4ec38a80$ec4a9f80$@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <012701d1eeee$4ec38a80$ec4a9f80$@cn.fujitsu.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: 'Linux Containers' <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, 'LKML' <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "'Eric W. Biederman'" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 05, 2016 at 03:52:25PM +0800, Zhao Lei wrote:
> Hi, Andrei Vagin
> 
> Thanks for your detailed review and suggestion.
> 
> > -----Original Message-----
> > From: Andrei Vagin [mailto:avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
> > Sent: Friday, August 05, 2016 2:32 PM
> > To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; Linux Containers
> > <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>; Eric W. Biederman
> > <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > Subject: Re: [PATCH v2 1/2] Limit dump_pipe program's permission to init for
> > container
> > 
> > On Tue, Aug 2, 2016 at 2:08 AM, Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> > > Currently when we set core_pattern to a pipe, the pipe program is
> > > forked by kthread running with root's permission, and write dumpfile
> > > into host's filesystem.
> > > Same thing happened for container, the dumper and dumpfile are also
> > > in host(not in container).
> > >
> > > It have following program:
> > > 1: Not consistent with file_type core_pattern
> > >    When we set core_pattern to a file, the container will write dump
> > >    into container's filesystem instead of host.
> > > 2: Not safe for privileged container
> > >    In a privileged container, user can destroy host system by following
> > >    command:
> > >    # # In a container
> > >    # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
> > >    # make_dump
> > >
> > > This patch switch dumper program's environment to init task, so, for
> > > container, dumper program have same environment with init task in
> > > container, which make dumper program put in container's filesystem, and
> > > write coredump into container's filesystem.
> > > The dumper's permission is also limited into subset of container's init
> > > process.
> > 
> > Does it change the current behavior? A pid namespace may be used for
> > sandboxes. For example, chrome uses it. In this case, we probably want
> > to collect core dumps from a root pid namespace.
> > 
> > If we are going to virtualize core_pattern relative to the pid
> > namespace, maybe it's better to make it optional for a pid namespace.
> > I mean it core_pattern is not set for the current pid namespace, we
> > can check a parent pid namespace and so on. A helper will be executed
> > in a pid namespace, where core_pattern is set.
> > 
> Is it means, we don't want to always gather dump from the container ifself,
> wnd we want to custom which level of the container can gather dump
> information?
> 
> If it is exact, current patch have similar function as above.
> 
> If user had not set core_pattern in a namespace, the dump setting in
> the parent namespace will be used.
> For example,
> HOST        change core_pattern
> Container1  no change
> Container2  change core_pattern
> Container3  no change
> Container4  no change
> 
> If code dump happened in container 2, 3 and 4, the dumper's environment
> is same as container2.
> And if dump happened in container 1 and HOST, the dumper's environment
> will be same as HOST.
> 
> So,
> 1: if a container want to make the custom core dump,
>   it can set core_pattern in container, and the gathered information
>   will be limited in this container.
> 2: If the host(or some top level container) want to gather dump information
>   more than a container internal, the host(or some top level container)
>   can set core_pattern, and not change core_pattern in the container,
>   then the pipe program will be run in same environment as the host,
>   and gather information from host's env.

The behavior which you described is the same with what I'm thinking
about.

But I don't understand how you implement it in a code.
I see that you call find_task_by_vpid(1) to get a base task, so the base
that is always the init task of the current pid namespace. I think we
need to get the init task from a pid namespace where core_pattern is
set, don't we?

pidns1 task1 (core_pattern is set)
\_pidns2 task2 (core_pattern isn't set)
 \_pidns2 ...
  \_pidns2 taskX (crashed and call do_coredump())

find_task_by_vpid(1) is called from do_coredump() and will return task2,
but if I understand you correctly, the base_task has to be task1 in this
case.

> 
> > After reading these patches, I think it may be a good idea to add one
> > more mode to handle core files, when a core file is sent to an
> > existing process instead of executing a usermode helpers. This mode
> > will cover of use-cases where the pipe mode is used now. And it looks
> > more secure, because in this case we control namespaces and credential
> > for the abort daemon (a process which handles core files).u
> > 
> > How it can be done. An abort daemon creates an abstract listening unix
> > socket and writes its name into /proc/sys/kernel/core_pattern. The
> > kernel saves this name and the network namespace. Then when any
> > process is crashed, the kernel creates a new unix socket and connect
> > it to the socket of the abort daemon and streams a core file into this
> > socket.
> > 
> Good idea.
> 
> And do it means if we want to custom core_pattern for each container,
> we can create more than one abort daemon for it?

Yes.

> If the abort daemon is running in the host, the dump file will be write
> into host's env, and if abort daemon is running in container, the dump
> file will be write into container's fs.

Yes. An abort daemon handles core files in its namespaces. The abort
daemon knows a pid of a crashed process, so it has access to namespaces of
the crashed task via /proc/pid/ns/* and can work with them. I want to say
that this daemon can decided in which context to handle a core file.

I don't like the idea to play with namespaces, credentials, an security
context for user helpers.

> 
> > >
> > > Suggested-by: Eric W. Biederman <ebieyderm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > > Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > >
> > > Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > > ---
> > >  fs/coredump.c           | 87
> > ++++++++++++++++++++++++++++++++++++++++++++++++-
> > >  include/linux/binfmts.h |  1 +
> > >  2 files changed, 87 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/fs/coredump.c b/fs/coredump.c
> > > index 281b768..8511267 100644
> > > --- a/fs/coredump.c
> > > +++ b/fs/coredump.c
> > > @@ -516,6 +516,8 @@ static int umh_pipe_setup(struct subprocess_info
> > *info, struct cred *new)
> > >  {
> > >         struct file *files[2];
> > >         struct coredump_params *cp = (struct coredump_params
> > *)info->data;
> > > +       struct task_struct *base_task;
> > > +
> > >         int err = create_pipe_files(files, 0);
> > >         if (err)
> > >                 return err;
> > > @@ -524,10 +526,79 @@ static int umh_pipe_setup(struct subprocess_info
> > *info, struct cred *new)
> > >
> > >         err = replace_fd(0, files[0], 0);
> > >         fput(files[0]);
> > > +       if (err)
> > > +               return err;
> > > +
> > >         /* and disallow core files too */
> > >         current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
> > >
> > > -       return err;
> > > +       base_task = cp->base_task;
> > > +       if (base_task) {
> > > +               const struct cred *base_cred;
> > > +
> > > +               /* Set fs_root to base_task */
> > > +               spin_lock(&base_task->fs->lock);
> > > +               set_fs_root(current->fs, &base_task->fs->root);
> > > +               spin_unlock(&base_task->fs->lock);
> > > +
> > > +               /* Set namespaces to base_task */
> > > +               get_nsproxy(base_task->nsproxy);
> > > +               switch_task_namespaces(current, base_task->nsproxy);
> > 
> > This task will continue running in the current pid namespace, because
> > switch_task_namespaces doesn't change a pid for the task. Ussualy, we
> > need to make setns+fork to switch a pid namespace.
> > 
> Yes.
> Now I known why I had not find this problem in my test,
> I output pids by a shell command, and the shell command is already got forked.
> 
> Seems need double fork(make code complex...) to do it.
> 
> > > +
> > > +               /* Set cgroup to base_task */
> > > +               current->flags &= ~PF_NO_SETAFFINITY;
> > > +               err = cgroup_attach_task_all(base_task, current);
> > > +               if (err < 0)
> > > +                       return err;
> > > +
> > > +               /* Set cred to base_task */
> > > +               base_cred = get_task_cred(base_task);
> > > +
> > 
> > I think you can use prepare_kernel_cred here
> > 
> prepare_kernel_cred() is called by caller of this function(call_usermodehelper_exec_async()),
> and this function is a hook, which can set additional cred property like:
> call_usermodehelper_exec_async()
> {
>     prepare_kernel_cred()
>     this_function()
>     {
>         custom_cred struct
>     } 
>     commit_creds(new);
> }
> 
> So we can only change cred's container here.
> 
> But seems we need rewrite this code when we move to above "double fork".
> 
> Before rewrite, could you give me some suggestion, if current code
> already can custom to dump information of "container internal" and "parent level container",
> is this meet your request?
> 
> Thanks
> Zhaolei
> 
> > > +               new->uid   = base_cred->uid;
> > > +               new->gid   = base_cred->gid;
> > > +               new->suid  = base_cred->suid;
> > > +               new->sgid  = base_cred->sgid;
> > > +               new->euid  = base_cred->euid;
> > > +               new->egid  = base_cred->egid;
> > > +               new->fsuid = base_cred->fsuid;
> > > +               new->fsgid = base_cred->fsgid;
> > > +
> > > +               new->securebits = base_cred->securebits;
> > > +
> > > +               new->cap_inheritable = base_cred->cap_inheritable;
> > > +               new->cap_permitted   = base_cred->cap_permitted;
> > > +               new->cap_effective   = base_cred->cap_effective;
> > > +               new->cap_bset        = base_cred->cap_bset;
> > > +               new->cap_ambient     = base_cred->cap_ambient;
> > > +
> > > +               security_cred_free(new);
> > > +#ifdef CONFIG_SECURITY
> > > +               new->security = NULL;
> > > +#endif
> > > +               err = security_prepare_creds(new, base_cred,
> > GFP_KERNEL);
> > > +               if (err < 0) {
> > > +                       put_cred(base_cred);
> > > +                       return err;
> > > +               }
> > > +
> > > +               free_uid(new->user);
> > > +               new->user = base_cred->user;
> > > +               get_uid(new->user);
> > > +
> > > +               put_user_ns(new->user_ns);
> > > +               new->user_ns = base_cred->user_ns;
> > > +               get_user_ns(new->user_ns);
> > > +
> > > +               put_group_info(new->group_info);
> > > +               new->group_info = base_cred->group_info;
> > > +               get_group_info(new->group_info);
> > > +
> > > +               put_cred(base_cred);
> > > +
> > > +               validate_creds(new);
> > > +       }
> > > +
> > > +       return 0;
> > >  }
> > >
> > >  void do_coredump(const siginfo_t *siginfo)
> > > @@ -590,6 +661,7 @@ void do_coredump(const siginfo_t *siginfo)
> > >
> > >         if (ispipe) {
> > >                 int dump_count;
> > > +               struct task_struct *vinit_task;
> > >                 char **helper_argv;
> > >                 struct subprocess_info *sub_info;
> > >
> > > @@ -631,6 +703,14 @@ void do_coredump(const siginfo_t *siginfo)
> > >                         goto fail_dropcount;
> > >                 }
> > >
> > > +               rcu_read_lock();
> > > +               vinit_task = find_task_by_vpid(1);
> > > +               rcu_read_unlock();
> > > +               if (!vinit_task) {
> > > +                       printk(KERN_WARNING "failed getting init task
> > info, skipping core dump\n");
> > > +                       goto fail_dropcount;
> > > +               }
> > > +
> > >                 helper_argv = argv_split(GFP_KERNEL, cn.corename,
> > NULL);
> > >                 if (!helper_argv) {
> > >                         printk(KERN_WARNING "%s failed to allocate
> > memory\n",
> > > @@ -638,6 +718,10 @@ void do_coredump(const siginfo_t *siginfo)
> > >                         goto fail_dropcount;
> > >                 }
> > >
> > > +               get_task_struct(vinit_task);
> > > +
> > > +               cprm.base_task = vinit_task;
> > > +
> > >                 retval = -ENOMEM;
> > >                 sub_info = call_usermodehelper_setup(helper_argv[0],
> > >                                                 helper_argv,
> > NULL, GFP_KERNEL,
> > > @@ -646,6 +730,7 @@ void do_coredump(const siginfo_t *siginfo)
> > >                         retval = call_usermodehelper_exec(sub_info,
> > >
> > UMH_WAIT_EXEC);
> > >
> > > +               put_task_struct(vinit_task);
> > >                 argv_free(helper_argv);
> > >                 if (retval) {
> > >                         printk(KERN_INFO "Core dump to |%s pipe
> > failed\n",
> > > diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
> > > index 314b3ca..0c9a72c 100644
> > > --- a/include/linux/binfmts.h
> > > +++ b/include/linux/binfmts.h
> > > @@ -59,6 +59,7 @@ struct linux_binprm {
> > >
> > >  /* Function parameter for binfmt->coredump */
> > >  struct coredump_params {
> > > +       struct task_struct *base_task;
> > >         const siginfo_t *siginfo;
> > >         struct pt_regs *regs;
> > >         struct file *file;
> > > --
> > > 1.8.5.1
> > >
> > >
> > >
> > > _______________________________________________
> > > Containers mailing list
> > > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > > https://lists.linuxfoundation.org/mailman/listinfo/containers
> > 
> 
> 
> 
> 
