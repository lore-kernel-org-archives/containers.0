From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: userns subsystem conversions v2
Date: Wed, 19 Sep 2012 18:45:54 -0700
Message-ID: <871uhx1n71.fsf@xmission.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org


Witht the previous review comments it was clear that my previous
patchset was a little premature and the patches were a bit large, making
the changes less clear than they needed to be.  To that end To that end
I have revisited and split up my audit, posix acl, and, and quota
support so they are now a series of smaller patches.

In my respin I have made a few extra simplifications to the audit code
to take advantage of the fact that netlink messages are processed in
the context of the sending userspace process, which allows for a lot
of simplifications.

This patchset updates all of the major linux subsystems that use uids
and gids to store them in kuid_t and kgid_t types.

This update allows some of the subsystems to work in all user namespaces
while other subsystems were updated to only work in the initial user
namespace.

kuid_t and kgid_t values have been pushed as deeply into the code as
possible to allow type checking to find as many places where I need
conversion to and from the kernel internal representation as possible.
In a couple of cases this involved taking an implicit union stored in an
unsigned int and making it an explicit union.

This patchset is based on 3.6-rc1 and strictly against:
git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

My intention after these patches have been reviewed is to add them to my
non-rebasing for-next branch of my user namespace tree and to merge
these changes into 3.7.

I had hoped when I converted the core kernel that I would have removed
the interactions between subsystems and would be able to merge these
changes independently through maintainer trees in a timely fashion, but
there are just enough dependencies and interactions that the changes
really all need to be in one tree to make these changes testable/usable.

Once these changes hit my for-next branch I won't be rebasing them so if
a maintainer wants to merge them to avoid conflicts feel free.

The biggest cross subystem change this round is probably the change to
have audit_get_loginuid return a kuid_t, but it certainly isn't the only
cross subsystem change.

The biggest clarification of the core kernel code is to bring the quota
projid concept out of hiding and into the open.

Eric W. Biederman (27):
      userns: Convert security/keys to the new userns infrastructure
      userns: net: Call key_alloc with GLOBAL_ROOT_UID, GLOBAL_ROOT_GID instead of 0, 0
      audit: Limit audit requests to processes in the initial pid and user namespaces.
      audit: Use current instead of NETLINK_CREDS() in audit_filter
      audit: kill audit_prepare_user_tty
      audit: Simply AUDIT_TTY_SET and AUDIT_TTY_GET
      audit: Properly set the origin port id of audit messages.
      audit: Remove the unused uid parameter from audit_receive_filter
      audit: Don't pass pid or uid to audit_log_common_recv_msg
      audit: Add typespecific uid and gid comparators
      userns: Convert the audit loginuid  to be a kuid
      userns: Convert audit to work with user namespaces enabled
      userns: Convert taskstats to handle the user and pid namespaces.
      userns: Convert bsd process accounting to use kuid and kgid where appropriate
      userns: Teach trace to use from_kuid
      userns: Convert vfs posix_acl support to use kuids and kgids
      userns: Pass a userns parameter into posix_acl_to_xattr and posix_acl_from_xattr
      userns: Convert extN to support kuids and kgids in posix acls
      userns: Convert configfs to use kuid and kgid where appropriate
      userns: Add kprojid_t and associated infrastructure in projid.h
      userns: Implement struct kqid
      userns: Convert qutoactl
      userns: Modify dqget to take struct kqid
      userns: Convert quota netlink aka quota_send_warning
      userns: Convert struct dquot dq_id to be a struct kqid
      userns: Convert struct dquot_warn
      userns: Convert quota

 drivers/tty/tty_audit.c           |   17 ++-
 fs/9p/acl.c                       |    8 +-
 fs/btrfs/acl.c                    |    8 +-
 fs/configfs/inode.c               |    4 +-
 fs/ext2/acl.c                     |   32 ++++--
 fs/ext3/acl.c                     |   32 ++++--
 fs/ext4/acl.c                     |   31 ++++--
 fs/generic_acl.c                  |    4 +-
 fs/gfs2/acl.c                     |   14 +-
 fs/gfs2/quota.c                   |   32 +++--
 fs/jffs2/acl.c                    |    4 +-
 fs/jfs/acl.c                      |    4 +-
 fs/jfs/xattr.c                    |    4 +-
 fs/nfs/nfs3acl.c                  |    4 +-
 fs/nfsd/vfs.c                     |    8 +-
 fs/ocfs2/acl.c                    |    4 +-
 fs/posix_acl.c                    |   30 +++---
 fs/proc/base.c                    |   27 ++++-
 fs/quota/Makefile                 |    2 +-
 fs/quota/dquot.c                  |   10 +-
 fs/quota/kqid.c                   |  132 ++++++++++++++++++++++
 fs/quota/netlink.c                |   10 +-
 fs/quota/quota.c                  |   28 ++++-
 fs/reiserfs/xattr_acl.c           |    4 +-
 fs/xattr.c                        |    7 +
 fs/xattr_acl.c                    |   96 +++++++++++++++-
 fs/xfs/xfs_acl.c                  |    4 +-
 fs/xfs/xfs_quotaops.c             |   12 +-
 fs/xfs/xfs_trans_dquot.c          |    8 +-
 include/linux/audit.h             |   12 +-
 include/linux/init_task.h         |    2 +-
 include/linux/key.h               |    9 +-
 include/linux/posix_acl.h         |    8 +-
 include/linux/posix_acl_xattr.h   |   18 +++-
 include/linux/projid.h            |  104 ++++++++++++++++++
 include/linux/quota.h             |  133 ++++++++++++++++++++++-
 include/linux/quotaops.h          |    4 +-
 include/linux/sched.h             |    2 +-
 include/linux/tsacct_kern.h       |    8 +-
 include/linux/tty.h               |    4 +-
 include/linux/user_namespace.h    |    3 +
 include/net/netlabel.h            |    2 +-
 include/net/xfrm.h                |   23 ++--
 init/Kconfig                      |   11 --
 kernel/acct.c                     |    4 +-
 kernel/audit.c                    |  121 ++++++++------------
 kernel/audit.h                    |    4 +-
 kernel/audit_watch.c              |    2 +-
 kernel/auditfilter.c              |  137 ++++++++++++++++++++---
 kernel/auditsc.c                  |  219 +++++++++++++++++++------------------
 kernel/taskstats.c                |   23 +++-
 kernel/trace/trace.c              |    3 +-
 kernel/trace/trace.h              |    2 +-
 kernel/tsacct.c                   |   12 +-
 kernel/user.c                     |    8 ++
 kernel/user_namespace.c           |  128 +++++++++++++++++++++-
 net/core/dev.c                    |    2 +-
 net/dns_resolver/dns_key.c        |    3 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/netlabel/netlabel_user.c      |    2 +-
 net/rxrpc/ar-key.c                |    6 +-
 net/xfrm/xfrm_policy.c            |    8 +-
 net/xfrm/xfrm_state.c             |    6 +-
 net/xfrm/xfrm_user.c              |   12 +-
 security/keys/internal.h          |    6 +-
 security/keys/key.c               |   23 ++---
 security/keys/keyctl.c            |   50 +++++----
 security/keys/keyring.c           |    4 +-
 security/keys/permission.c        |   14 +--
 security/keys/proc.c              |   44 ++++----
 security/keys/process_keys.c      |   15 ++-
 security/keys/request_key.c       |    6 +-
 72 files changed, 1288 insertions(+), 501 deletions(-)
