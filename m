From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 00/10] namespaces: log namespaces per task
Date: Wed, 22 Apr 2015 23:07:51 -0400
Message-ID: <20150423030751.GA6712@madcap2.tricolour.ca>
References: <cover.1429252659.git.rgb@redhat.com>
	<87vbgqw163.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vbgqw163.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 15/04/20, Eric W. Biederman wrote:
> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > The purpose is to track namespace instances in use by logged processes from the
> > perspective of init_*_ns by logging the namespace IDs (device ID and namespace
> > inode - offset).
> 
> In broad strokes the user interface appears correct.
> 
> Things that I see that concern me:
> 
> - After Als most recent changes these inodes no longer live in the proc
>   superblock so the device number reported in these patches is
>   incorrect.

Ok, found the patchset you're talking about:
	3d3d35b kill proc_ns completely
	e149ed2 take the targets of /proc/*/ns/* symlinks to separate fs
	f77c801 bury struct proc_ns in fs/proc
	33c4294 copy address of proc_ns_ops into ns_common
	6344c43 new helpers: ns_alloc_inum/ns_free_inum
	6496452 make proc_ns_operations work with struct ns_common * instead of void *
	3c04118 switch the rest of proc_ns_operations to working with &...->ns
	ff24870 netns: switch ->get()/->put()/->install()/->inum() to working with &net->ns
	58be2825 make mntns ->get()/->put()/->install()/->inum() work with &mnt_ns->ns
	435d5f4 common object embedded into various struct ....ns

Ok, I've got some minor jigging to do to get inum too...

> - I am nervous about audit logs being flooded with users creating lots
>   of namespaces.  But that is more your lookout than mine.

There was a thought to create a filter to en/disable this logging...
It is an auxiliary record to syscalls, so they can be ignored by userspace tools.

> - unshare is not logging when it creates new namespaces.

They are all covered:
sys_unshare > unshare_userns > create_user_ns
sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_mnt_ns
sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_utsname > clone_uts_ns
sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_ipcs > get_ipc_ns
sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_pid_ns > create_pid_namespace
sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_net_ns

> As small numbers are nice and these inodes all live in their own
> superblock now we should be able to remove the games with
> PROC_DYNAMIC_FIRST and just use small numbers for these inodes
> everywhere.

That is compelling if I can untangle the proc inode allocation code from the
ida/idr.  Should be as easy as defining a new ns_alloc_inum (and ns_free_inum)
to use instead of proc_alloc_inum with its own ns_inum_ida and ns_inum_lock,
then defining a NS_DYNAMIC_FIRST and defining NS_{IPC,UTS,USER,PID}_INIT_INO in
the place of the existing PROC_*_INIT_INO.

> I have answered your comments below.

More below...

> > 1/10 exposes proc's ns entries structure which lists a number of useful
> > operations per namespace type for other subsystems to use.
> >
> > 2/10  proc_ns: define PROC_*_INIT_INO in terms of PROC_DYNAMIC_FIRST
> >
> > 3/10 provides an example of usage for audit_log_task_info() which is used by
> > syscall audits, among others.  audit_log_task() and audit_common_recv_message()
> > would be other potential use cases.
> >
> > Proposed output format:
> > This differs slightly from Aristeu's patch because of the label conflict with
> > "pid=" due to including it in existing records rather than it being a seperate
> > record.  It has now returned to being a seperate record.  The proc device
> > major/minor are listed in hexadecimal and namespace IDs are the proc inode
> > minus the base offset.
> > 	type=NS_INFO msg=audit(1408577535.306:82): dev=00:03 netns=3 utsns=-3 ipcns=-4 pidns=-1 userns=-2 mntns=0
> >
> > 4/10 change audit startup from __initcall to subsys_initcall to get it started
> > earlier to be able to receive initial namespace log messages.
> >
> > 5/10 tracks the creation and deletion of namespaces, listing the type of
> > namespace instance, proc device ID, related namespace id if there is one and
> > the newly minted namespace ID.
> >
> > Proposed output format for initial namespace creation:
> > 	type=AUDIT_NS_INIT_UTS msg=audit(1408577534.868:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_utsns=(none) utsns=-3 res=1
> > 	type=AUDIT_NS_INIT_USER msg=audit(1408577534.868:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_userns=(none) userns=-2 res=1
> > 	type=AUDIT_NS_INIT_PID msg=audit(1408577534.868:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_pidns=(none) pidns=-1 res=1
> > 	type=AUDIT_NS_INIT_MNT msg=audit(1408577534.868:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_mntns=(none) mntns=0 res=1
> > 	type=AUDIT_NS_INIT_IPC msg=audit(1408577534.868:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_ipcns=(none) ipcns=-4 res=1
> > 	type=AUDIT_NS_INIT_NET msg=audit(1408577533.500:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_netns=(none) netns=2 res=1
> >
> > And a CLONE action would result in:
> > 	type=type=AUDIT_NS_INIT_NET msg=audit(1408577535.306:81): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 old_netns=2 netns=3 res=1
> >
> > While deleting a namespace would result in:
> > 	type=type=AUDIT_NS_DEL_MNT msg=audit(1408577552.221:85): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 mntns=4 res=1
> >
> > 6/10 accepts a PID from userspace and requests logging an AUDIT_NS_INFO record
> > type (CAP_AUDIT_CONTROL required).
> >
> > 7/10 is a macro for CLONE_NEW_* flags.
> >
> > 8/10 adds auditing on creation of namespace(s) in fork.
> >
> > 9/10 adds auditing a change of namespace on setns.
> >
> > 10/10 attaches a AUDIT_NS_INFO record to AUDIT_VIRT_CONTROL records
> > (CAP_AUDIT_WRITE required).
> >
> >
> > v5 -> v6:
> > 	Switch to using namespace ID based on namespace proc inode minus base offset
> > 	Added proc device ID to qualify proc inode reference
> > 	Eliminate exposed /proc interface
> >
> > v4 -> v5:
> > 	Clean up prototypes for dependencies on CONFIG_NAMESPACES.
> > 	Add AUDIT_NS_INFO record type to AUDIT_VIRT_CONTROL record.
> > 	Log AUDIT_NS_INFO with PID.
> > 	Move /proc/<pid>/ns_* patches to end of patchset to deprecate them.
> > 	Log on changing ns (setns).
> > 	Log on creating new namespaces when forking.
> > 	Added a macro for CLONE_NEW*.
> >
> > v3 -> v4:
> > 	Seperate out the NS_INFO message from the SYSCALL message.
> > 	Moved audit_log_namespace_info() out of audit_log_task_info().
> > 	Use a seperate message type per namespace type for each of INIT/DEL.
> > 	Make ns= easier to search across NS_INFO and NS_INIT/DEL_XXX msg types.
> > 	Add /proc/<pid>/ns/ documentation.
> > 	Fix dynamic initial ns logging.
> >
> > v2 -> v3:
> > 	Use atomic64_t in ns_serial to simplify it.
> > 	Avoid funciton duplication in proc, keying on dentry.
> > 	Squash down audit patch to avoid rcu sleep issues.
> > 	Add tracking for creation and deletion of namespace instances.
> >
> > v1 -> v2:
> > 	Avoid rollover by switching from an int to a long long.
> > 	Change rollover behaviour from simply avoiding zero to raising a BUG.
> > 	Expose serial numbers in /proc/<pid>/ns/*_snum.
> > 	Expose ns_entries and use it in audit.
> >
> >
> > Notes:
> > As for CAP_AUDIT_READ, a patchset has been accepted upstream to check
> > capabilities of userspace processes that try to join netlink broadcast groups.
> >
> > This set does not try to solve the non-init namespace audit messages and
> > auditd problem yet.  That will come later, likely with additional auditd
> > instances running in another namespace with a limited ability to influence the
> > master auditd.  I echo Eric B's idea that messages destined for different
> > namespaces would have to be tailored for that namespace with references that
> > make sense (such as the right pid number reported to that pid namespace, and
> > not leaking info about parents or peers).
> >
> > Questions:
> > Is there a way to link serial numbers of namespaces involved in migration of a
> > container to another kernel?  It sounds like what is needed is a part of a
> > mangement application that is able to pull the audit records from constituent
> > hosts to build an audit trail of a container.
> 
> I honestly don't know how much we are going to care about namespace ids
> during migration.  So far this is not a problem that has come up.

Not for CRIU, but it will be an issue for a container auditor that aggregates
information from individually auditted hosts.

> I don't think migration becomes a practical concern (other than
> interface wise) until achieve a non-init namespace auditd.  The easy way
> to handle migration would be to log a setns of every process from their
> old namespaces to their new namespaces.  As you appear to have a setns
> event defined.

Again, this would be taken care of by a layer above that is container-aware
across multiple hosts.

> How to handle the more general case beyond audit remains unclear.  I
> think it will be a little while yet before we start dealing with
> migrating applications that care.  When we do we will either need to
> generate some kind of hot-plug event that userspace can respond to and
> discover all of the appropriate file-system nodes have changed, or we
> will need to build a mechanism in the kernel to preserve these numbers.

I don't expect to need to preserve these numbers.  The higher layer application
will be able to do that translation.

> I really don't know which solution we will wind up with in the kernel at
> this point.
> 
> > What additional events should list this information?
> 
> At least unshare.

Already covered as noted above.  If it is a brand new namespace, it will show
the old one as "(none)" (or maybe zero now that we are looking at renumbering
the NS inodes).  If it is an unshared one, it will show the old one from which
it was unshared.

> > Does this present any problematic information leaks?  Only CAP_AUDIT_CONTROL
> > (and now CAP_AUDIT_READ) in init_user_ns can get to this information in
> > the init namespace at the moment from audit.
> 
> Good question.  Today access to this information is generally guarded
> with CAP_SYS_PTRACE.
> 
> I suspect for some of audits tracing features like this one we should
> also use CAP_SYS_PTRACE so that we have a consistent set of checks for
> getting information about applications.

I assume CAP_SYS_PTRACE is orthogonal to CAP_AUDIT_{CONTROL,READ} and that
CAP_SYS_PTRACE would need to be insufficient to get that information.


Thanks for your thoughtful feedback, Eric.

> Eric
> 
> > Richard Guy Briggs (10):
> >   namespaces: expose ns_entries
> >   proc_ns: define PROC_*_INIT_INO in terms of PROC_DYNAMIC_FIRST
> >   audit: log namespace ID numbers
> >   audit: initialize at subsystem time rather than device time
> >   audit: log creation and deletion of namespace instances
> >   audit: dump namespace IDs for pid on receipt of AUDIT_NS_INFO
> >   sched: add a macro to ref all CLONE_NEW* flags
> >   fork: audit on creation of new namespace(s)
> >   audit: log on switching namespace (setns)
> >   audit: emit AUDIT_NS_INFO record with AUDIT_VIRT_CONTROL record
> >
> >  fs/namespace.c                   |   13 +++
> >  fs/proc/generic.c                |    3 +-
> >  fs/proc/namespaces.c             |    2 +-
> >  include/linux/audit.h            |   20 +++++
> >  include/linux/proc_ns.h          |   10 ++-
> >  include/uapi/linux/audit.h       |   21 +++++
> >  include/uapi/linux/sched.h       |    6 ++
> >  ipc/namespace.c                  |   12 +++
> >  kernel/audit.c                   |  169 +++++++++++++++++++++++++++++++++++++-
> >  kernel/auditsc.c                 |    2 +
> >  kernel/fork.c                    |    3 +
> >  kernel/nsproxy.c                 |    4 +
> >  kernel/pid_namespace.c           |   13 +++
> >  kernel/user_namespace.c          |   13 +++
> >  kernel/utsname.c                 |   12 +++
> >  net/core/net_namespace.c         |   12 +++
> >  security/integrity/ima/ima_api.c |    2 +
> >  17 files changed, 309 insertions(+), 8 deletions(-)

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
