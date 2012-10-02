From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] user namespace changes for v3.7
Date: Mon, 01 Oct 2012 21:21:41 -0700
Message-ID: <87vcet7bca.fsf@xmission.com>
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 72235465864d84cedb2d9f26f8e1de824ee20339 userns: Convert the ufs filesystem to use kuid/kgid where appropriate

   The tree is against v3.6-rc1

This is a mostly modest set of changes to enable basic user namespace
support.  This allows the code to code to compile with user namespaces
enabled and removes the assumption there is only the initial user
namespace.  Everything is converted except for the most complex of the
filesystems: autofs4, 9p, afs, ceph, cifs, coda, fuse, gfs2, ncpfs, nfs,
ocfs2 and xfs as those patches need a bit more review.

The strategy is to push kuid_t and kgid_t values are far down into
subsystems and filesystems as reasonable.  Leaving the make_kuid and
from_kuid operations to happen at the edge of userspace, as the
values come off the disk, and as the values come in from the network.
Letting compile type incompatible compile errors (present when user
namespaces are enabled) guide me to find the issues.

The most tricky areas have been the places where we had an implicit
union of uid and gid values and were storing them in an unsigned int.
Those places were converted into explicit unions.   I made certain
to handle those places with simple trivial patches.

Out of that work I discovered we have generic interfaces for storing
quota by projid.  I had never heard of the project identifiers before.
Adding full user namespace support for project identifiers accounts
for most of the code size growth in my git tree.

Ultimately there will be work to relax privlige checks from
"capable(FOO)" to "ns_capable(user_ns, FOO)" where it is safe
allowing root in a user names to do those things that today we only
forbid to non-root users because it will confuse suid root applications.

While I was pushing kuid_t and kgid_t changes deep into the audit code I
made a few other cleanups. I capitalized on the fact we process netlink
messages in the context of the message sender.  I removed usage of
NETLINK_CRED, and started directly using current->tty.

Some of these patches have also made it into maintainer trees, with no
problems from identical code from different trees showing up in
linux-next.

After reading through all of this code I feel like I might be able
to win a game of kernel trivial pursuit.

Eric


Dan Carpenter (1):
      ipv6: move dereference after check in fl_free()

Eric W. Biederman (106):
      userns: Allow the usernamespace support to build after the removal of usbfs
      userns:  Fix link restrictions to use uid_eq
      userns: Convert net/core/scm.c to use kuids and kgids
      userns: Convert __dev_set_promiscuity to use kuids in audit logs
      userns: Convert sock_i_uid to return a kuid_t
      userns: Allow USER_NS and NET simultaneously in Kconfig
      userns: Make seq_file's user namespace accessible
      userns: Print out socket uids in a user namespace aware fashion.
      userns: Use kgids for sysctl_ping_group_range
      net ip6 flowlabel: Make owner a union of struct pid * and kuid_t
      pidns: Export free_pid_ns
      userns: Convert net/ax25 to use kuid_t where appropriate
      netlink: Make the sending netlink socket availabe in NETLINK_CB
      userns: Implement sk_user_ns
      userns: Teach inet_diag to work with user namespaces
      userns: nfnetlink_log: Report socket uids in the log sockets user namespace
      net sched: Pass the skb into change so it can access NETLINK_CB
      userns: Convert cls_flow to work with user namespaces enabled
      userns: Convert xt_LOG to print socket kuids and kgids as uids and gids
      userns xt_recent: Specify the owner/group of ip_list_perms in the initial user namespace
      userns: xt_owner: Add basic user namespace support.
      userns: Make the airo wireless driver use kuids for proc uids and gids
      userns: Convert tun/tap to use kuid and kgid where appropriate
      userns: Enable building of pf_key sockets when user namespace support is enabled.
      userns: Make credential debugging user namespace safe.
      userns: Convert debugfs to use kuid/kgid where appropriate.
      userns: Convert process event connector to handle kuids and kgids
      userns: Convert ipc to use kuid and kgid where appropriate
      userns: Convert drm to use kuid and kgid and struct pid where appropriate
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
      userns: Convert quota netlink aka quota_send_warning
      userns: Modify dqget to take struct kqid
      userns: Convert struct dquot dq_id to be a struct kqid
      userns: Convert struct dquot_warn
      userns: Convert quota
      userns: Convert fat to use kuid/kgid where appropriate
      userns: Convert gadgetfs to use kuid and kgid where appropriate
      userns: Convert usb functionfs to use kuid/kgid where appropriate
      userns: Convert devtmpfs to use GLOBAL_ROOT_UID and GLOBAL_ROOT_GID
      userns: Convert hugetlbfs to use kuid/kgid where appropriate
      userns: Convert xenfs to use kuid and kgid where appropriate
      userns: Convert adfs to use kuid and kgid where appropriate
      userns: Convert befs to use kuid/kgid where appropriate
      userns: Convert cramfs to use kuid/kgid where appropriate
      userns: Convert ecryptfs to use kuid/kgid where appropriate
      userns: Convert efs to use kuid/kgid where appropriate
      userns: Convert exofs to use kuid/kgid where appropriate
      userns: Convert hfs to use kuid and kgid where appropriate
      userns: Convert hfsplus to use kuid and kgid where appropriate
      userns: Convert isofs to use kuid/kgid where appropriate
      userns: Convert logfs to use kuid/kgid where appropriate
      userns: Convert minix to use kuid/kgid where appropriate
      userns: Convert nillfs2 to use kuid/kgid where appropriate
      userns: Convert ntfs to use kuid and kgid where appropriate
      userns: Convert omfs to use kuid and kgid where appropriate
      userns: Convert the qnx4 filesystem to use kuid/kgid where appropriate
      userns: Convert the qnx6 filesystem to use kuid/kgid where appropriate
      userns: Convert the sysv filesystem to use kuid/kgid where appropriate
      userns: Convert freevxfs to use kuid/kgid where appropriate
      userns: Convert ipathfs to use GLOBAL_ROOT_UID and GLOBAL_ROOT_GID
      userns: Convert loop to use kuid_t instead of uid_t
      userns: Convert apparmor to use kuid and kgid where appropriate
      userns: Convert tomoyo to use kuid and kgid where appropriate
      userns: Convert selinux to use kuid and kgid where appropriate
      userns: Convert hostfs to use kuid and kgid where appropriate
      userns: Convert EVM to deal with kuids and kgids in it's hmac computation
      userns: Add user namespace support to IMA
      userns: Teach security_path_chown to take kuids and kgids
      userns: Convert binder ipc to use kuids
      userns: Convert s390 hypfs to use kuid and kgid where appropriate
      userns: Convert s390 getting uid and gid system calls to use kuid and kgid
      userns: On ppc convert current_uid from a kuid before printing.
      userns: On ia64 deal with current_uid and current_gid being kuid and kgid
      userns: On alpha modify linux_to_osf_stat to use convert from kuids and kgids
      userns: Convert affs to use kuid/kgid wherwe appropriate
      userns: Convert bfs to use kuid/kgid where appropriate
      userns: Convert btrfs to use kuid/kgid where appropriate
      userns: Convert hpfs to use kuid and kgid where appropriate
      userns: Convert jffs2 to use kuid and kgid where appropriate
      userns: Convert jfs to use kuid/kgid where appropriate
      userns: Convert reiserfs to use kuid and kgid where appropriate
      userns: Convert squashfs to use kuid/kgid where appropriate
      userns: Convert ubifs to use kuid/kgid
      userns: Convert the udf filesystem to use kuid/kgid where appropriate
      userns: Convert the ufs filesystem to use kuid/kgid where appropriate
---

 arch/alpha/kernel/osf_sys.c         |    4 +-
 arch/ia64/kernel/mca_drv.c          |    3 +-
 arch/ia64/kernel/perfmon.c          |   32 +++---
 arch/ia64/kernel/signal.c           |    4 +-
 arch/powerpc/mm/fault.c             |    2 +-
 arch/s390/hypfs/inode.c             |   20 +++-
 arch/s390/kernel/compat_linux.c     |   36 ++++--
 drivers/base/devtmpfs.c             |    4 +-
 drivers/block/loop.c                |    4 +-
 drivers/connector/cn_proc.c         |   18 +++-
 drivers/gpu/drm/drm_fops.c          |    3 +-
 drivers/gpu/drm/drm_info.c          |    5 +-
 drivers/gpu/drm/drm_ioctl.c         |    4 +-
 drivers/infiniband/hw/qib/qib_fs.c  |    4 +-
 drivers/net/tun.c                   |   46 +++++---
 drivers/net/wireless/airo.c         |   48 +++++---
 drivers/staging/android/binder.c    |   14 +-
 drivers/tty/tty_audit.c             |   17 ++-
 drivers/usb/gadget/f_fs.c           |   23 +++-
 drivers/usb/gadget/inode.c          |    4 +-
 drivers/xen/xenfs/super.c           |    3 +-
 fs/9p/acl.c                         |    8 +-
 fs/adfs/adfs.h                      |    4 +-
 fs/adfs/inode.c                     |    4 +-
 fs/adfs/super.c                     |   21 ++--
 fs/affs/affs.h                      |    4 +-
 fs/affs/inode.c                     |   20 ++--
 fs/affs/super.c                     |   18 ++-
 fs/befs/befs.h                      |    4 +-
 fs/befs/linuxvfs.c                  |   27 +++--
 fs/bfs/inode.c                      |    8 +-
 fs/btrfs/acl.c                      |    8 +-
 fs/btrfs/delayed-inode.c            |    8 +-
 fs/btrfs/inode.c                    |    8 +-
 fs/btrfs/ioctl.c                    |    6 +-
 fs/configfs/inode.c                 |    4 +-
 fs/cramfs/inode.c                   |    4 +-
 fs/debugfs/inode.c                  |   26 +++--
 fs/ecryptfs/main.c                  |    5 +-
 fs/ecryptfs/messaging.c             |    5 +-
 fs/efs/inode.c                      |    4 +-
 fs/exofs/inode.c                    |    8 +-
 fs/ext2/acl.c                       |   32 ++++--
 fs/ext3/acl.c                       |   32 ++++--
 fs/ext3/super.c                     |    2 +-
 fs/ext4/acl.c                       |   31 ++++--
 fs/ext4/super.c                     |    2 +-
 fs/fat/fat.h                        |    4 +-
 fs/fat/file.c                       |    6 +-
 fs/fat/inode.c                      |   18 ++-
 fs/freevxfs/vxfs_inode.c            |    4 +-
 fs/generic_acl.c                    |    4 +-
 fs/gfs2/acl.c                       |   14 +-
 fs/gfs2/quota.c                     |   32 +++--
 fs/hfs/hfs_fs.h                     |    4 +-
 fs/hfs/inode.c                      |    4 +-
 fs/hfs/super.c                      |   16 ++-
 fs/hfsplus/catalog.c                |    4 +-
 fs/hfsplus/hfsplus_fs.h             |    4 +-
 fs/hfsplus/inode.c                  |    8 +-
 fs/hfsplus/options.c                |   15 ++-
 fs/hostfs/hostfs_kern.c             |    8 +-
 fs/hpfs/hpfs_fn.h                   |    4 +-
 fs/hpfs/inode.c                     |   19 ++--
 fs/hpfs/namei.c                     |    8 +-
 fs/hpfs/super.c                     |   18 ++-
 fs/hugetlbfs/inode.c                |   16 ++-
 fs/isofs/inode.c                    |   17 ++-
 fs/isofs/isofs.h                    |    4 +-
 fs/isofs/rock.c                     |    4 +-
 fs/jffs2/acl.c                      |   30 ++++--
 fs/jffs2/file.c                     |    8 +-
 fs/jffs2/fs.c                       |   24 ++--
 fs/jffs2/os-linux.h                 |    4 +-
 fs/jfs/acl.c                        |    4 +-
 fs/jfs/file.c                       |    4 +-
 fs/jfs/jfs_imap.c                   |   22 ++--
 fs/jfs/jfs_incore.h                 |    8 +-
 fs/jfs/super.c                      |   22 +++-
 fs/jfs/xattr.c                      |    4 +-
 fs/logfs/inode.c                    |    4 +-
 fs/logfs/readwrite.c                |    8 +-
 fs/minix/inode.c                    |   16 ++--
 fs/namei.c                          |    6 +-
 fs/nfs/nfs3acl.c                    |    4 +-
 fs/nfsd/vfs.c                       |    8 +-
 fs/nilfs2/inode.c                   |    8 +-
 fs/ntfs/inode.c                     |    7 +-
 fs/ntfs/super.c                     |   39 +++++-
 fs/ntfs/volume.h                    |    5 +-
 fs/ocfs2/acl.c                      |    4 +-
 fs/ocfs2/file.c                     |    6 +-
 fs/ocfs2/quota_global.c             |   43 ++++---
 fs/ocfs2/quota_local.c              |   15 ++-
 fs/omfs/inode.c                     |    8 +-
 fs/omfs/omfs.h                      |    4 +-
 fs/open.c                           |    2 +-
 fs/posix_acl.c                      |   30 +++---
 fs/proc/base.c                      |   27 ++++-
 fs/qnx4/inode.c                     |    4 +-
 fs/qnx6/inode.c                     |    4 +-
 fs/quota/Makefile                   |    2 +-
 fs/quota/dquot.c                    |  114 +++++++++---------
 fs/quota/kqid.c                     |  132 +++++++++++++++++++++
 fs/quota/netlink.c                  |   10 +-
 fs/quota/quota.c                    |   28 ++++-
 fs/quota/quota_tree.c               |   22 ++--
 fs/quota/quota_v1.c                 |   12 +-
 fs/quota/quota_v2.c                 |   26 +++--
 fs/reiserfs/inode.c                 |   26 ++--
 fs/reiserfs/xattr_acl.c             |   24 +++-
 fs/seq_file.c                       |    4 +
 fs/squashfs/inode.c                 |    8 +-
 fs/sysv/inode.c                     |    8 +-
 fs/ubifs/budget.c                   |    4 +-
 fs/ubifs/debug.c                    |    4 +-
 fs/ubifs/journal.c                  |    4 +-
 fs/ubifs/sb.c                       |    4 +-
 fs/ubifs/super.c                    |    4 +-
 fs/ubifs/ubifs.h                    |    4 +-
 fs/udf/inode.c                      |   12 +-
 fs/udf/super.c                      |   20 ++--
 fs/udf/udf_sb.h                     |    4 +-
 fs/ufs/inode.c                      |   16 ++--
 fs/xattr.c                          |    7 +
 fs/xattr_acl.c                      |   96 ++++++++++++++-
 fs/xfs/xfs_acl.c                    |    4 +-
 fs/xfs/xfs_quotaops.c               |   12 +-
 fs/xfs/xfs_trans_dquot.c            |    8 +-
 include/drm/drmP.h                  |    4 +-
 include/linux/audit.h               |   12 +-
 include/linux/inet_diag.h           |    1 +
 include/linux/init_task.h           |    2 +-
 include/linux/ipc.h                 |    9 +-
 include/linux/key.h                 |    9 +-
 include/linux/loop.h                |    2 +-
 include/linux/netlink.h             |    1 +
 include/linux/posix_acl.h           |    8 +-
 include/linux/posix_acl_xattr.h     |   18 +++-
 include/linux/projid.h              |  104 +++++++++++++++++
 include/linux/quota.h               |  136 +++++++++++++++++++++-
 include/linux/quotaops.h            |    6 +-
 include/linux/sched.h               |    2 +-
 include/linux/security.h            |    6 +-
 include/linux/seq_file.h            |   14 +++
 include/linux/tsacct_kern.h         |    8 +-
 include/linux/tty.h                 |    4 +-
 include/linux/user_namespace.h      |    3 +
 include/net/ax25.h                  |    4 +-
 include/net/ipv6.h                  |    5 +-
 include/net/netlabel.h              |    2 +-
 include/net/netns/ipv4.h            |    3 +-
 include/net/sch_generic.h           |    3 +-
 include/net/sock.h                  |   11 ++-
 include/net/tcp.h                   |    3 +-
 include/net/xfrm.h                  |   23 ++--
 init/Kconfig                        |   89 --------------
 ipc/msg.c                           |   14 ++-
 ipc/sem.c                           |   13 ++-
 ipc/shm.c                           |   19 ++--
 ipc/util.c                          |   35 ++++---
 ipc/util.h                          |    2 +-
 kernel/acct.c                       |    4 +-
 kernel/audit.c                      |  121 ++++++++------------
 kernel/audit.h                      |    4 +-
 kernel/audit_watch.c                |    2 +-
 kernel/auditfilter.c                |  137 +++++++++++++++++++---
 kernel/auditsc.c                    |  219 ++++++++++++++++++-----------------
 kernel/cred.c                       |   10 ++-
 kernel/pid.c                        |    1 +
 kernel/pid_namespace.c              |    2 +
 kernel/taskstats.c                  |   23 +++-
 kernel/trace/trace.c                |    3 +-
 kernel/trace/trace.h                |    2 +-
 kernel/tsacct.c                     |   12 +-
 kernel/user.c                       |    8 ++
 kernel/user_namespace.c             |  128 ++++++++++++++++++++-
 net/appletalk/atalk_proc.c          |    3 +-
 net/ax25/ax25_uid.c                 |   21 +++-
 net/core/dev.c                      |    9 +-
 net/core/scm.c                      |   31 ++++--
 net/core/sock.c                     |   10 +-
 net/dns_resolver/dns_key.c          |    3 +-
 net/ipv4/inet_diag.c                |   21 +++-
 net/ipv4/ping.c                     |   22 ++--
 net/ipv4/raw.c                      |    4 +-
 net/ipv4/sysctl_net_ipv4.c          |   42 +++++---
 net/ipv4/tcp_ipv4.c                 |    6 +-
 net/ipv4/udp.c                      |    4 +-
 net/ipv4/udp_diag.c                 |    5 +-
 net/ipv6/ip6_flowlabel.c            |   47 +++++++-
 net/ipv6/raw.c                      |    3 +-
 net/ipv6/tcp_ipv6.c                 |    6 +-
 net/ipv6/udp.c                      |    3 +-
 net/ipx/ipx_proc.c                  |    3 +-
 net/key/af_key.c                    |    2 +-
 net/llc/llc_proc.c                  |    2 +-
 net/netfilter/nfnetlink_log.c       |   14 ++-
 net/netfilter/xt_LOG.c              |   16 ++-
 net/netfilter/xt_owner.c            |   30 ++++-
 net/netfilter/xt_recent.c           |   13 ++-
 net/netlabel/netlabel_unlabeled.c   |    2 +-
 net/netlabel/netlabel_user.c        |    2 +-
 net/netlink/af_netlink.c            |    6 +-
 net/packet/af_packet.c              |    2 +-
 net/phonet/socket.c                 |    6 +-
 net/rxrpc/ar-key.c                  |    6 +-
 net/sched/cls_api.c                 |    2 +-
 net/sched/cls_basic.c               |    3 +-
 net/sched/cls_cgroup.c              |    3 +-
 net/sched/cls_flow.c                |   19 +++-
 net/sched/cls_fw.c                  |    3 +-
 net/sched/cls_route.c               |    3 +-
 net/sched/cls_rsvp.h                |    3 +-
 net/sched/cls_tcindex.c             |    3 +-
 net/sched/cls_u32.c                 |    3 +-
 net/sctp/proc.c                     |    6 +-
 net/xfrm/xfrm_policy.c              |    8 +-
 net/xfrm/xfrm_state.c               |    6 +-
 net/xfrm/xfrm_user.c                |   12 +-
 security/apparmor/domain.c          |    4 +-
 security/apparmor/file.c            |   12 +-
 security/apparmor/include/audit.h   |    2 +-
 security/apparmor/include/file.h    |    4 +-
 security/apparmor/lsm.c             |    2 +-
 security/capability.c               |    2 +-
 security/integrity/evm/evm_crypto.c |    4 +-
 security/integrity/ima/ima_audit.c  |    5 +-
 security/integrity/ima/ima_policy.c |   14 +-
 security/keys/internal.h            |    6 +-
 security/keys/key.c                 |   23 ++---
 security/keys/keyctl.c              |   50 +++++---
 security/keys/keyring.c             |    4 +-
 security/keys/permission.c          |   14 +--
 security/keys/proc.c                |   44 ++++----
 security/keys/process_keys.c        |   15 ++-
 security/keys/request_key.c         |    6 +-
 security/security.c                 |    2 +-
 security/selinux/selinuxfs.c        |    6 +-
 security/selinux/ss/services.c      |    2 +-
 security/tomoyo/audit.c             |   23 +++-
 security/tomoyo/common.c            |    4 +-
 security/tomoyo/common.h            |    4 +-
 security/tomoyo/condition.c         |   20 ++--
 security/tomoyo/tomoyo.c            |   12 +-
 245 files changed, 2480 insertions(+), 1310 deletions(-)
