From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/2] namespaces: log namespaces per task
Date: Tue, 22 Apr 2014 14:12:51 -0400
Message-ID: <cover.1398176489.git.rgb@redhat.com>
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
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

I saw no replies to my questions when I replied a year after Aris' posting, so
I don't know if it was ignored or got lost in stale threads:
        https://www.redhat.com/archives/linux-audit/2013-March/msg00020.html
        https://www.redhat.com/archives/linux-audit/2013-March/msg00033.html
	(https://lists.linux-foundation.org/pipermail/containers/2013-March/032063.html)
        https://www.redhat.com/archives/linux-audit/2014-January/msg00180.html

I've tried to answer a number of questions that were raised in that thread.

The goal is not quite identical to Aris' patchset.

The purpose is to track namespaces in use by logged processes from the
perspective of init_*_ns.  The first patch defines a function to list them.
The second patch provides an example of usage for audit_log_task_info() which
is used by syscall audits, among others.  audit_log_task() and
audit_common_recv_message() would be other potential use cases.

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
container to another kernel?  (I had a brief look at CRIU.)  Is there a unique
identifier for each running instance of a kernel?  Or at least some identifier
within the container migration realm?

What additional events should list this information?

Does this present any kind of information leak?  Only CAP_AUDIT_CONTROL (and
proposed CAP_AUDIT_READ) in init_user_ns can get to this information in the
init namespace at the moment.


Proposed output format:
This differs slightly from Aristeu's patch because of the label conflict with
"pid=" due to including it in existing records rather than it being a seperate
record:
        type=SYSCALL msg=audit(1398112249.996:65): arch=c000003e syscall=272 success=yes exit=0 a0=40000000 a1=ffffffffffffffff a2=0 a3=22 items=0 ppid=1 pid=566 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="(t-daemon)" exe="/usr/lib/systemd/systemd" mntns=5 netns=97 utsns=2 ipcns=1 pidns=4 userns=3 subj=system_u:system_r:init_t:s0 key=(null)


Note: This set does not try to solve the non-init namespace audit messages and
auditd problem yet.  That will come later, likely with additional auditd
instances running in another namespace with a limited ability to influence the
master auditd.  I echo Eric B's idea that messages destined for different
namespaces would have to be tailored for that namespace with references that
make sense (such as the right pid number reported to that pid namespace, and
not leaking info about parents or peers).


Richard Guy Briggs (2):
  namespaces: give each namespace a serial number
  audit: log namespace serial numbers

 fs/mount.h                     |    1 +
 fs/namespace.c                 |    1 +
 include/linux/audit.h          |    7 +++++++
 include/linux/ipc_namespace.h  |    1 +
 include/linux/nsproxy.h        |    8 ++++++++
 include/linux/pid_namespace.h  |    1 +
 include/linux/user_namespace.h |    1 +
 include/linux/utsname.h        |    1 +
 include/net/net_namespace.h    |    1 +
 init/version.c                 |    1 +
 ipc/msgutil.c                  |    1 +
 ipc/namespace.c                |    2 ++
 kernel/audit.c                 |   38 ++++++++++++++++++++++++++++++++++++++
 kernel/nsproxy.c               |   24 ++++++++++++++++++++++++
 kernel/pid.c                   |    1 +
 kernel/pid_namespace.c         |    2 ++
 kernel/user.c                  |    1 +
 kernel/user_namespace.c        |    2 ++
 kernel/utsname.c               |    2 ++
 net/core/net_namespace.c       |    4 +++-
 20 files changed, 99 insertions(+), 1 deletions(-)
