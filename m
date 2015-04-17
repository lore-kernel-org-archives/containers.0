From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V6 00/10] namespaces: log namespaces per task
Date: Fri, 17 Apr 2015 03:35:47 -0400
Message-ID: <cover.1429252659.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

The purpose is to track namespace instances in use by logged processes from the
perspective of init_*_ns by logging the namespace IDs (device ID and namespace
inode - offset).


1/10 exposes proc's ns entries structure which lists a number of useful
operations per namespace type for other subsystems to use.

2/10  proc_ns: define PROC_*_INIT_INO in terms of PROC_DYNAMIC_FIRST

3/10 provides an example of usage for audit_log_task_info() which is used by
syscall audits, among others.  audit_log_task() and audit_common_recv_message()
would be other potential use cases.

Proposed output format:
This differs slightly from Aristeu's patch because of the label conflict with
"pid=" due to including it in existing records rather than it being a seperate
record.  It has now returned to being a seperate record.  The proc device
major/minor are listed in hexadecimal and namespace IDs are the proc inode
minus the base offset.
	type=NS_INFO msg=audit(1408577535.306:82): dev=00:03 netns=3 utsns=-3 ipcns=-4 pidns=-1 userns=-2 mntns=0

4/10 change audit startup from __initcall to subsys_initcall to get it started
earlier to be able to receive initial namespace log messages.

5/10 tracks the creation and deletion of namespaces, listing the type of
namespace instance, proc device ID, related namespace id if there is one and
the newly minted namespace ID.

Proposed output format for initial namespace creation:
	type=AUDIT_NS_INIT_UTS msg=audit(1408577534.868:5): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_utsns=(none) utsns=-3 res=1
	type=AUDIT_NS_INIT_USER msg=audit(1408577534.868:6): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_userns=(none) userns=-2 res=1
	type=AUDIT_NS_INIT_PID msg=audit(1408577534.868:7): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_pidns=(none) pidns=-1 res=1
	type=AUDIT_NS_INIT_MNT msg=audit(1408577534.868:8): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_mntns=(none) mntns=0 res=1
	type=AUDIT_NS_INIT_IPC msg=audit(1408577534.868:9): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_ipcns=(none) ipcns=-4 res=1
	type=AUDIT_NS_INIT_NET msg=audit(1408577533.500:10): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_netns=(none) netns=2 res=1

And a CLONE action would result in:
	type=type=AUDIT_NS_INIT_NET msg=audit(1408577535.306:81): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 old_netns=2 netns=3 res=1

While deleting a namespace would result in:
	type=type=AUDIT_NS_DEL_MNT msg=audit(1408577552.221:85): pid=481 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03 mntns=4 res=1

6/10 accepts a PID from userspace and requests logging an AUDIT_NS_INFO record
type (CAP_AUDIT_CONTROL required).

7/10 is a macro for CLONE_NEW_* flags.

8/10 adds auditing on creation of namespace(s) in fork.

9/10 adds auditing a change of namespace on setns.

10/10 attaches a AUDIT_NS_INFO record to AUDIT_VIRT_CONTROL records
(CAP_AUDIT_WRITE required).


v5 -> v6:
	Switch to using namespace ID based on namespace proc inode minus base offset
	Added proc device ID to qualify proc inode reference
	Eliminate exposed /proc interface

v4 -> v5:
	Clean up prototypes for dependencies on CONFIG_NAMESPACES.
	Add AUDIT_NS_INFO record type to AUDIT_VIRT_CONTROL record.
	Log AUDIT_NS_INFO with PID.
	Move /proc/<pid>/ns_* patches to end of patchset to deprecate them.
	Log on changing ns (setns).
	Log on creating new namespaces when forking.
	Added a macro for CLONE_NEW*.

v3 -> v4:
	Seperate out the NS_INFO message from the SYSCALL message.
	Moved audit_log_namespace_info() out of audit_log_task_info().
	Use a seperate message type per namespace type for each of INIT/DEL.
	Make ns= easier to search across NS_INFO and NS_INIT/DEL_XXX msg types.
	Add /proc/<pid>/ns/ documentation.
	Fix dynamic initial ns logging.

v2 -> v3:
	Use atomic64_t in ns_serial to simplify it.
	Avoid funciton duplication in proc, keying on dentry.
	Squash down audit patch to avoid rcu sleep issues.
	Add tracking for creation and deletion of namespace instances.

v1 -> v2:
	Avoid rollover by switching from an int to a long long.
	Change rollover behaviour from simply avoiding zero to raising a BUG.
	Expose serial numbers in /proc/<pid>/ns/*_snum.
	Expose ns_entries and use it in audit.


Notes:
As for CAP_AUDIT_READ, a patchset has been accepted upstream to check
capabilities of userspace processes that try to join netlink broadcast groups.

This set does not try to solve the non-init namespace audit messages and
auditd problem yet.  That will come later, likely with additional auditd
instances running in another namespace with a limited ability to influence the
master auditd.  I echo Eric B's idea that messages destined for different
namespaces would have to be tailored for that namespace with references that
make sense (such as the right pid number reported to that pid namespace, and
not leaking info about parents or peers).

Questions:
Is there a way to link serial numbers of namespaces involved in migration of a
container to another kernel?  It sounds like what is needed is a part of a
mangement application that is able to pull the audit records from constituent
hosts to build an audit trail of a container.

What additional events should list this information?

Does this present any problematic information leaks?  Only CAP_AUDIT_CONTROL
(and now CAP_AUDIT_READ) in init_user_ns can get to this information in
the init namespace at the moment from audit.


Richard Guy Briggs (10):
  namespaces: expose ns_entries
  proc_ns: define PROC_*_INIT_INO in terms of PROC_DYNAMIC_FIRST
  audit: log namespace ID numbers
  audit: initialize at subsystem time rather than device time
  audit: log creation and deletion of namespace instances
  audit: dump namespace IDs for pid on receipt of AUDIT_NS_INFO
  sched: add a macro to ref all CLONE_NEW* flags
  fork: audit on creation of new namespace(s)
  audit: log on switching namespace (setns)
  audit: emit AUDIT_NS_INFO record with AUDIT_VIRT_CONTROL record

 fs/namespace.c                   |   13 +++
 fs/proc/generic.c                |    3 +-
 fs/proc/namespaces.c             |    2 +-
 include/linux/audit.h            |   20 +++++
 include/linux/proc_ns.h          |   10 ++-
 include/uapi/linux/audit.h       |   21 +++++
 include/uapi/linux/sched.h       |    6 ++
 ipc/namespace.c                  |   12 +++
 kernel/audit.c                   |  169 +++++++++++++++++++++++++++++++++++++-
 kernel/auditsc.c                 |    2 +
 kernel/fork.c                    |    3 +
 kernel/nsproxy.c                 |    4 +
 kernel/pid_namespace.c           |   13 +++
 kernel/user_namespace.c          |   13 +++
 kernel/utsname.c                 |   12 +++
 net/core/net_namespace.c         |   12 +++
 security/integrity/ima/ima_api.c |    2 +
 17 files changed, 309 insertions(+), 8 deletions(-)
