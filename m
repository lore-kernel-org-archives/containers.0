From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 0/6] namespaces: log namespaces per task
Date: Fri,  9 May 2014 20:27:21 -0400
Message-ID: <cover.1399681022.git.rgb@redhat.com>
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
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

The purpose is to track namespaces in use by logged processes from the
perspective of init_*_ns.  The first patch defines a function to generate them
and assigns them.  The second patch provides an example of usage for
audit_log_task_info() which is used by syscall audits, among others.
audit_log_task() and audit_common_recv_message() would be other potential use
cases.

Use a serial number per namespace (unique across one boot of one kernel)
instead of the inode number (which is claimed to have had the right to change
reserved and is not necessarily unique if there is more than one proc fs).  It
could be argued that the inode numbers have now become a defacto interface and
can't change now, but I'm proposing this approach to see if this helps address
some of the objections to the earlier patchset.

There could also have messages added to track the creation and the destruction
of namespaces, listing the parent for hierarchical namespaces such as pidns,
userns, and listing other ids for non-hierarchical namespaces, as well as other
information to help identify a namespace.

There has been some progress made for audit in net namespaces and pid
namespaces since this previous thread.  net namespaces are now served as peers
by one auditd in the init_net namespace with processes in a non-init_net
namespace being able to write records if they are in the init_user_ns and have
CAP_AUDIT_WRITE.  Processes in a non-init_pid_ns can now similarly write
records.  As for CAP_AUDIT_READ, I just posted a patchset to check capabilities
of userspace processes that try to join netlink broadcast groups.


Questions:
Is there a way to link serial numbers of namespaces involved in migration of a
container to another kernel?  It sounds like what is needed is a part of a
mangement application that is able to pull the audit rcords from constituent
hosts to build an audit trail of a container.

What additional events should list this information?

Does this present any problematic information leaks?  Only CAP_AUDIT_CONTROL
(and proposed CAP_AUDIT_READ) in init_user_ns can get to this information in
the init namespace at the moment from audit.  *However*, the addition of the
proc/<pid>/ns/*_snum does make it available to other processes now.


Proposed output format:
This differs slightly from Aristeu's patch because of the label conflict with
"pid=" due to including it in existing records rather than it being a seperate
record.  The serial numbers are printed in hex.
	type=SYSCALL msg=audit(1399651071.433:72): arch=c000003e syscall=272 success=yes exit=0 a0=40000000 a1=ffffffffffffffff a2=0 a3=22 items=0 ppid=1 pid=483 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="(t-daemon)" exe="/usr/lib/systemd/systemd" netns=97 utsns=2 ipcns=1 pidns=4 userns=3 mntns=5 subj=system_u:system_r:init_t:s0 key=(null)

The third patch adds access functions to get to the serial numbers in a similar
way to inode access for namespace proc operations.

The fourth patch implements, as suggested by Serge Hallyn, making these serial
numbers available in /proc/self/ns/{ipc,mnt,net,pid,user,uts}_snum.  I chose
"snum" instead of "seq" for consistency with inum and there are a number of
other uses of "seq" in the namespace code.

**Although it works as expected, I'm not that happy with that patch because it
duplicates a lot of code, including minor changes to proc_ns_follow_link(),
proc_ns_readlink(), ns_dname().  The only way I could see to get that
information into those functions would be through dentry.  Maybe the
information I need is already in there in d_name or d_iname?  Or I could add a
flag to d_flags (there are 9 bits unused?) but that flag isn't useful for any
other types of entries, so I'm not so keen to pollute it.

The fifth patch exposes proc's ns entries structure which lists a number of
useful operations per namespace type for other subsystems to use.

The sixth patch converts the audit namespace serial number logging over to use
the ns_entries access methods.

The two audit patches should really be squashed down to one if the exposure of
ns_entries is ok.


Note: This set does not try to solve the non-init namespace audit messages and
auditd problem yet.  That will come later, likely with additional auditd
instances running in another namespace with a limited ability to influence the
master auditd.  I echo Eric B's idea that messages destined for different
namespaces would have to be tailored for that namespace with references that
make sense (such as the right pid number reported to that pid namespace, and
not leaking info about parents or peers).

v1 -> v2:
	Avoid rollover by switching from an int to a long long.
	Change rollover behaviour from simply avoiding zero to raising a BUG.
	Expose serial numbers in /proc/<pid>/ns/*_snum.
	Expose ns_entries and use it in audit.

Richard Guy Briggs (6):
  namespaces: assign each namespace instance a serial number
  audit: log namespace serial numbers
  namespaces: expose namespace instance serial number in
    proc_ns_operations
  namespaces: expose ns instance serial numbers in proc
  namespaces: expose ns_entries
  audit: convert namespace serial number logging to use proc ns_entries

 fs/mount.h                     |    1 +
 fs/namespace.c                 |    8 ++
 fs/proc/namespaces.c           |  152 ++++++++++++++++++++++++++++++++++++----
 include/linux/audit.h          |    7 ++
 include/linux/ipc_namespace.h  |    1 +
 include/linux/nsproxy.h        |    8 ++
 include/linux/pid_namespace.h  |    1 +
 include/linux/proc_ns.h        |    2 +
 include/linux/user_namespace.h |    1 +
 include/linux/utsname.h        |    1 +
 include/net/net_namespace.h    |    1 +
 init/version.c                 |    1 +
 ipc/msgutil.c                  |    1 +
 ipc/namespace.c                |   10 +++
 kernel/audit.c                 |   21 +++++-
 kernel/nsproxy.c               |   20 +++++
 kernel/pid.c                   |    1 +
 kernel/pid_namespace.c         |    9 +++
 kernel/user.c                  |    1 +
 kernel/user_namespace.c        |    9 +++
 kernel/utsname.c               |   10 +++
 net/core/net_namespace.c       |   11 +++-
 22 files changed, 262 insertions(+), 15 deletions(-)
