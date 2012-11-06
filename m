From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 06 Nov 2012 08:10:10 -0800
Message-ID: <87sj8mogpp.fsf__433.924413710152$1352218239$gmane$org@xmission.com>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org> <871ug6rbio.fsf@xmission.com>
	<20121106154320.GE30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121106154320.GE30069-9pTldWuhBndy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Tue, 6 Nov 2012 07:43:20 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Hey, Eric.
>
> On Tue, Nov 06, 2012 at 07:34:07AM -0800, Eric W. Biederman wrote:
>> Having thought about this a little more I can give a definitive answer.
>> 
>> Adding a process to the device control group is equivalent to calling
>> mknod, as it allows that process to open device nodes, or equivalently
>> not open device nodes.  Therefore a capable check is absolutely
>> required.
>> 
>> Without a capability check it would be possible to remove access to
>> /dev/console for a suid root application keeping it from reporting
>> attempts to hack it for example.
>
> You understand that the whole thing is gated by VFS permission check,
> right?  I'm kinda lost what you're talking about.

mknod is gated by the vfs with a capability call.

open does not perform the CAP_MKNOD check.

Since the device cgroup prevents opening of device nodes adding
permission to access a new device node (update_access) is roughly
equivalent to mknod when the device cgroup does not exist.

To preserve the notion that only a privileged user can grant access to
device nodes we need a capability check.  Especially since the device
cgroup is designed to limit processes with uid == 0.

Without a capability check a process with CAP_DAC_OVERRIDE can go
shopping for a device control group that happens to have the device it
wants to use.

Similary without a capability check a process with CAP_DAD_OVERRIDE can
add or remove any device node into a device control group.

I don't see how the device control group can limit uid == 0 with the
device control group without making the operations require a capability
you don't give to ever user who has uid == 0.

>> The generic cgroup check in attach_task_by_pid to see if you can move
>> another process into a cgroup needs to be a capability call and not a
>> test for uid == 0.
>> 
>> static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
>> {
>> 	if (pid) {
>> 		tsk = find_task_by_vpid(pid);
>> 
>> 		/*
>> 		 * even if we're attaching all tasks in the thread group, we
>> 		 * only need to check permissions on one of them.
>> 		 */
>> 		tcred = __task_cred(tsk);
>> 		if (!uid_eq(cred->euid, GLOBAL_ROOT_UID) &&
>>                                         ^^^^^^^^^^^^^^^
>> 		    !uid_eq(cred->euid, tcred->uid) &&
>> 		    !uid_eq(cred->euid, tcred->suid)) {
>> 			rcu_read_unlock();
>> 			ret = -EACCES;
>> 			goto out_unlock_cgroup;
>
> This one isn't gated by VFS so we need to add CAP check to this
> function.  No?

correct.  The check should read something like:

 		tcred = __task_cred(tsk);
 		if (!uid_eq(cred->euid, tcred->uid) &&
 		    !uid_eq(cred->euid, tcred->suid) &&
                    !capable(CAP_SYS_ADMIN)) {
 			rcu_read_unlock();
 			ret = -EACCES;
 			goto out_unlock_cgroup;

Eric
