From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 06 Nov 2012 07:34:07 -0800
Message-ID: <871ug6rbio.fsf__38975.5758493722$1352216069$gmane$org@xmission.com>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121106150639.GB30069-9pTldWuhBndy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Tue, 6 Nov 2012 07:06:39 -0800")
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

> Hello, Serge.
>
> On Tue, Nov 06, 2012 at 09:01:32AM -0600, Serge Hallyn wrote:
>> More practically, lacking user namespaces you can create a full (i.e.
>> ubuntu) container that doesn't have CAP_SYS_ADMIN, but not one without
>> root.  So this allows you to prevent containers from bypassing devices
>> cgroup restrictions set by the parent.  (In reality we are not using
>> that in ubuntu - we grant CAP_SYS_ADMIN and use apparmor to restrict -
>> but other distros do.)
>
> Do you even mount cgroupfs in containers?  If you just bind-mount
> cgroupfs verbatim in containers, I don't think that's gonna work very
> well.  If not, all this doesn't make any difference for containers.
>
> So, you don't really have any actual use case for the explicit CAP_*
> checks, right?

Having thought about this a little more I can give a definitive answer.

Adding a process to the device control group is equivalent to calling
mknod, as it allows that process to open device nodes, or equivalently
not open device nodes.  Therefore a capable check is absolutely
required.

Without a capability check it would be possible to remove access to
/dev/console for a suid root application keeping it from reporting
attempts to hack it for example.

update_access can allow access to previously unaccessible devices
and so is equivalent to mknod and as such requires a capability call.

static int devcgroup_update_access(struct dev_cgroup *devcgroup,
				   int filetype, const char *buffer)
{
....
	if (!capable(CAP_SYS_ADMIN))
		return -EPERM;


Likewise move to a different cgroup can give you a completely different
set of devices you can use.  And is roughly equivalent to mknod, and
needs a capability call. 

static int devcgroup_can_attach(struct cgroup *new_cgrp,
				struct cgroup_taskset *set)
{
	struct task_struct *task = cgroup_taskset_first(set);

	if (current != task && !capable(CAP_SYS_ADMIN))
		return -EPERM;


The generic cgroup check in attach_task_by_pid to see if you can move
another process into a cgroup needs to be a capability call and not a
test for uid == 0.

static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
{
	if (pid) {
		tsk = find_task_by_vpid(pid);

		/*
		 * even if we're attaching all tasks in the thread group, we
		 * only need to check permissions on one of them.
		 */
		tcred = __task_cred(tsk);
		if (!uid_eq(cred->euid, GLOBAL_ROOT_UID) &&
                                        ^^^^^^^^^^^^^^^
		    !uid_eq(cred->euid, tcred->uid) &&
		    !uid_eq(cred->euid, tcred->suid)) {
			rcu_read_unlock();
			ret = -EACCES;
			goto out_unlock_cgroup;

Eric
