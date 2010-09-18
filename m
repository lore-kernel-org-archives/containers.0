From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/2] exec: move core_pattern pipe helper into the crashing
	namespace
Date: Fri, 17 Sep 2010 21:33:52 -0500
Message-ID: <AANLkTimPC5Ns06L_zqzETtrXrBOohyyLSk7JPhV-Ay8S__37363.5872536854$1284777281$gmane$org@mail.gmail.com>
References: <20100917152639.0e88341a@basil.nowhere.org>
	<1284736618-27153-2-git-send-email-wad@chromium.org>
	<20100917181556.GA2499@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100917181556.GA2499-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 17, 2010 at 1:15 PM, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Fri, Sep 17, 2010 at 10:16:58AM -0500, Will Drewry wrote:
>> Presently, a core_pattern pipe endpoint will be run in the init
>> namespace. =A0It will receive the virtual pid (task_tgid_vnr->%p) of the
>> core dumping process but will have no access to that processes /proc
>> without walking the init namespace /proc looking through all the global
>> pids until it finds the one it thinks matches.
>>
>> One option for implementing this I've already posed:
>> =A0 https://patchwork.kernel.org/patch/185912/
>> However, it's unclear if it is desirable for the core_pattern to run
>> outside the namespace. =A0In particular, it can easily access the mounts
>> via /proc/[pid_nr]/root, but if there is a net namespace, it will not
>> have access. =A0(Originally introduced in 2007 in commit
>> b488893a390edfe027bae7a46e9af8083e740668 )
>>
>> Instead, this change implements the more complex option two. =A0It
>> migrates the ____call_usermodehelper() thread into the same namespaces
>> as the dumping process. =A0It does not assign a pid in that namespace so
>> the collector will appear to be pid 0. =A0(Using alloc_pid and change_pid
>> are options though. I avoided it because kernel_thread's returned pid
>> will then mismatch the actual threads pid.)
>>
>> Signed-off-by: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> ---
>> =A0fs/exec.c | =A0 56 ++++++++++++++++++++++++++++++++++++++++++++++++++=
+++---
>> =A01 files changed, 53 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 828dd24..3b82607 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -51,6 +51,7 @@
>> =A0#include <linux/audit.h>
>> =A0#include <linux/tracehook.h>
>> =A0#include <linux/kmod.h>
>> +#include <linux/nsproxy.h>
>> =A0#include <linux/fsnotify.h>
>> =A0#include <linux/fs_struct.h>
>> =A0#include <linux/pipe_fs_i.h>
>> @@ -65,6 +66,12 @@ char core_pattern[CORENAME_MAX_SIZE] =3D "core";
>> =A0unsigned int core_pipe_limit;
>> =A0int suid_dumpable =3D 0;
>>
>> +struct coredump_pipe_params {
>> + =A0 =A0 struct coredump_params *params;
>> + =A0 =A0 struct nsproxy *nsproxy;
>> + =A0 =A0 struct fs_struct *fs;
>> +};
>> +
> Generally, I like this approach, but i think perhaps it would be better i=
f you
> made the coredump_pipe_params struct a member of the coredump_params stru=
cture
> (perhaps within an anonymous union, so you can handle future core dump ty=
pes, if
> those ever come along). =A0That will save you needing the extra pointer t=
o the
> coredump_params structure itself.

I'll rework it as suggested while also taking into account Oleg's
feedback (another mail coming).

Thanks!

>> =A0/* The maximal length of core_pattern is also specified in sysctl.c */
>>
>> =A0static LIST_HEAD(formats);
>> @@ -1819,8 +1826,34 @@ static int umh_pipe_setup(struct subprocess_info =
*info)
>> =A0{
>> =A0 =A0 =A0 struct file *rp, *wp;
>> =A0 =A0 =A0 struct fdtable *fdt;
>> - =A0 =A0 struct coredump_params *cp =3D (struct coredump_params *)info-=
>data;
>> - =A0 =A0 struct files_struct *cf =3D current->files;
>> + =A0 =A0 struct coredump_pipe_params *pipe_params =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 (struct coredump_pipe_params *)info->data;
> If you do the above, you can just reference this as cp->pipe_params, or
> what-not.
>
>> + =A0 =A0 struct coredump_params *cp =3D pipe_params->params;
>> + =A0 =A0 struct task_struct *tsk =3D current;
>> + =A0 =A0 struct files_struct *cf =3D tsk->files;
>> + =A0 =A0 struct fs_struct *cfs =3D tsk->fs;
>> +
>> + =A0 =A0 /* Migrate this thread into the crashing namespaces, but
>> + =A0 =A0 =A0* don't change its pid struct to avoid breaking any other
>> + =A0 =A0 =A0* dependencies. =A0This will mean the process is pid=3D0 if=
 it
>> + =A0 =A0 =A0* was migrated into a pid namespace.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (pipe_params->nsproxy && pipe_params->fs) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 int kill;
>> + =A0 =A0 =A0 =A0 =A0 =A0 switch_task_namespaces(tsk, pipe_params->nspro=
xy);
>> + =A0 =A0 =A0 =A0 =A0 =A0 pipe_params->nsproxy =3D NULL;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 task_lock(tsk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 tsk->fs =3D pipe_params->fs;
>> + =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(tsk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 pipe_params->fs =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Clean up the previous fs struct */
>> + =A0 =A0 =A0 =A0 =A0 =A0 write_lock(&cfs->lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 kill =3D !--cfs->users;
>> + =A0 =A0 =A0 =A0 =A0 =A0 write_unlock(&cfs->lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (kill)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_fs_struct(cfs);
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 wp =3D create_write_pipe(0);
>> =A0 =A0 =A0 if (IS_ERR(wp))
>> @@ -1911,6 +1944,7 @@ void do_coredump(long signr, int exit_code, struct=
 pt_regs *regs)
>> =A0 =A0 =A0 if (ispipe) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int dump_count;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 char **helper_argv;
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct coredump_pipe_params pipe_params =3D { =
.params =3D &cprm };
>>
> And you won't have to allocate this, it will just be part of the
> coredump_params.
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cprm.limit =3D=3D 1) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> @@ -1950,10 +1984,26 @@ void do_coredump(long signr, int exit_code, stru=
ct pt_regs *regs)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_dropcount;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Run the core_collector in the crashing name=
spaces */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_namespaces_unattached(0, current,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &pipe_params.nsproxy, &pipe_pa=
rams.fs)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "%s failed=
 to copy namespaces\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argv_free(helper_argv);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_dropcount;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D call_usermodehelper_fns(helper_ar=
gv[0], helper_argv,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 NULL, UMH_WAIT_EXEC, umh_pipe_setup,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 NULL, &cprm);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 NULL, &pipe_params);
> And you can pass a pointer to coredump_params here, instead of a pointer =
to a
> pipe_specific coredumps, to a function that isn't specific to pipes
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 argv_free(helper_argv);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* nsproxy and fs will survive if call_usermod=
ehelper_fns hits
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* ENOMEM prior to creating a new thread.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pipe_params.nsproxy)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_nsproxy(pipe_params.nsprox=
y);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pipe_params.fs) =A0/* not in use by anythi=
ng else */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_fs_struct(pipe_params.fs);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "Core dump =
to %s pipe failed\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0corename);
>> --
>> 1.7.0.4
>>
>>
>
>
> Regards
> Neil
>
>
