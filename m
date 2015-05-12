From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 00/10] namespaces: log namespaces per task
Date: Tue, 12 May 2015 16:02:37 -0400
Message-ID: <cover.1431451547.git.rgb@redhat.com>
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
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

The purpose is to track namespace instances in use by logged processes from the
perspective of init_*_ns by logging the namespace IDs (namespace device ID and
namespace inode).


1/10 exposes proc's ns entries structure which lists a number of useful
operations per namespace type for other subsystems to use.

2/10 creates and switches to a dedicated inode pool for the namespace
filesystem.

3/10 add the nsfs device ID to ns_common for each namespace instance for quick
access.

4/10 provides an example of usage for audit_log_task_info() which is used by
syscall audits, among others.

Proposed output format:
This differs slightly from Aristeu's patch because of the label conflict with
"pid=" due to including it in existing records rather than it being a seperate
record.  "pid=" here is the target pid for a potentially unactivated task for
which the nsproxy has been created.  It has now returned to being a seperate
record.  The nsfs device major/minor are listed in hexadecimal and namespace
IDs are the ns inode.
	type=NS_INFO msg=audit(1408577535.306:82): pid=310 dev=00:03 netns=7 utsns=3 ipcns=4 pidns=1 userns=2 mntns=5

5/10 change audit startup from __initcall to subsys_initcall to get it started
earlier to be able to receive initial namespace log messages.

6/10 tracks the creation and deletion of namespaces, listing the type of
namespace instance, nsfs device ID, related namespace id if there is one and
the newly minted namespace ID.

Proposed output format for initial namespace creation:
	type=AUDIT_NS_INIT_UTS msg=audit(1431115986.147:5): dev=00:03 old_utsns=(none) utsns=2 res=1
	type=AUDIT_NS_INIT_USER msg=audit(1431115986.148:6): dev=00:03 old_userns=(none) userns=3 res=1
	type=AUDIT_NS_INIT_PID msg=audit(1431115986.149:7): dev=00:03 old_pidns=(none) pidns=4 res=1
	type=AUDIT_NS_INIT_MNT msg=audit(1431115986.150:8): dev=00:00 old_mntns=(none) mntns=5 res=1
	type=AUDIT_NS_INIT_IPC msg=audit(1431115986.151:9): dev=00:03 old_ipcns=(none) ipcns=1 res=1
	type=AUDIT_NS_INIT_NET msg=audit(1431115985.500:10): dev=00:03 old_netns=(none) netns=7 res=1

And a CLONE action would result in:
	type=AUDIT_NS_INIT_NET msg=audit(1408577535.306:81): dev=00:03 old_netns=7 netns=8 res=1

While deleting a namespace would result in:
	type=AUDIT_NS_DEL_MNT msg=audit(1431116003.205:534): dev=00:03 mntns=8 res=1

7/10 accepts a PID from userspace and requests logging an AUDIT_NS_INFO record
type (CAP_AUDIT_CONTROL required).

8/10 adds auditing on creation of namespace(s) in fork for unshare(2) and
clone(2), adding the CLONE_NEW_*ALL macro.

9/10 adds auditing a change of namespace on setns(2).
	type=AUDIT_NS_SET_NET msg=audit(1408577535.306:81): dev=00:03 old_netns=7 netns=8 res=1

10/10 attaches a AUDIT_NS_INFO record to AUDIT_VIRT_CONTROL records
(CAP_AUDIT_WRITE required).


v6 -> v7:
	Added sys_unshare to the sys_clone patch.
	Combined the CLONE_NEW_*_ALL macro and audit clone and unshare patches.
	Rebased on Al Viro's NSFS from v3.19-rc1 adding nsfs device ID to ns_common.
	Create and switch to an nsfs inode db.
	Switch AUDIT_NS_{INIT,DEL,SET}_* to auxiliary records.
	Fix NULL dereference bug in AUDIT_NS_INFO call from AUDIT_VIRT_CONTROL type.
	Remove call for audit_log_common_recv_msg.
	Only emit info, init, del, set messages on audit_enabled.

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

Do any additional events need this information?

Does this present any problematic information leaks?  Only CAP_AUDIT_CONTROL
(and now CAP_AUDIT_READ) in init_user_ns can get to this information in
the init namespace at the moment from audit.


Richard Guy Briggs (10):
  namespaces: expose ns_entries
  nsfs: switch to dedicated inode pool
  nsfs: add nsfs device ID to ns_common
  audit: log namespace ID numbers
  audit: initialize at subsystem time rather than device time
  audit: log creation and deletion of namespace instances
  audit: dump namespace IDs for pid on receipt of AUDIT_NS_INFO
  fork: audit on creation of new namespace(s) with clone and unshare
  audit: log on switching namespace (setns)
  audit: emit AUDIT_NS_INFO record with AUDIT_VIRT_CONTROL record

 fs/namespace.c                   |   15 +++
 fs/nsfs.c                        |   65 ++++++++++++++
 fs/proc/internal.h               |    2 +
 fs/proc/namespaces.c             |    2 +-
 include/linux/audit.h            |   27 ++++++
 include/linux/ns_common.h        |    1 +
 include/linux/proc_ns.h          |   22 ++---
 include/uapi/linux/audit.h       |   21 +++++
 include/uapi/linux/sched.h       |    6 ++
 init/version.c                   |    2 +-
 ipc/msgutil.c                    |    2 +-
 ipc/namespace.c                  |   13 +++
 kernel/audit.c                   |  180 +++++++++++++++++++++++++++++++++++++-
 kernel/auditsc.c                 |    2 +
 kernel/fork.c                    |   13 ++-
 kernel/nsproxy.c                 |    2 +
 kernel/pid.c                     |    2 +-
 kernel/pid_namespace.c           |   13 +++
 kernel/user.c                    |    2 +-
 kernel/user_namespace.c          |   13 +++
 kernel/utsname.c                 |   12 +++
 net/core/net_namespace.c         |   13 +++
 security/integrity/ima/ima_api.c |    2 +
 23 files changed, 410 insertions(+), 22 deletions(-)
