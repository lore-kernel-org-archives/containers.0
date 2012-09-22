From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 00/11] userns: Simple filesystems conversions
Date: Fri, 21 Sep 2012 18:31:50 -0700
Message-ID: <877grmj115.fsf@xmission.com>
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
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


This continus my conversion of filesystems to support running
when kernel user namespace supprot is enabled.  This time I have
targed the filesystems that I had to look twice at to verify
the changes were correct.

The strategy is to convert the structures in the kernel where we store
uid_t and gid_t to to kuid_t and kgid_t.  To assume all file systems are
encoded in the initial user namespace for purposes of conversions.
Mount options containing uids and gids along with other user space
interfaces are of assumed to be encoded in the current user namespace.

These patches are against:
git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

Eric W. Biederman (11):
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

 fs/affs/affs.h           |    4 ++--
 fs/affs/inode.c          |   20 ++++++++++----------
 fs/affs/super.c          |   18 +++++++++++-------
 fs/bfs/inode.c           |    8 ++++----
 fs/btrfs/delayed-inode.c |    8 ++++----
 fs/btrfs/inode.c         |    8 ++++----
 fs/btrfs/ioctl.c         |    6 +++---
 fs/hpfs/hpfs_fn.h        |    4 ++--
 fs/hpfs/inode.c          |   19 +++++++++++--------
 fs/hpfs/namei.c          |    8 ++++----
 fs/hpfs/super.c          |   18 +++++++++++-------
 fs/jffs2/acl.c           |   26 ++++++++++++++++++++------
 fs/jffs2/file.c          |    8 ++++----
 fs/jffs2/fs.c            |   24 +++++++++++++-----------
 fs/jffs2/os-linux.h      |    4 ++--
 fs/jfs/file.c            |    4 ++--
 fs/jfs/jfs_imap.c        |   22 ++++++++++++----------
 fs/jfs/jfs_incore.h      |    8 ++++----
 fs/jfs/super.c           |   22 +++++++++++++++-------
 fs/reiserfs/inode.c      |   26 +++++++++++++-------------
 fs/reiserfs/xattr_acl.c  |   20 +++++++++++++++++---
 fs/squashfs/inode.c      |    8 ++++++--
 fs/ubifs/budget.c        |    4 ++--
 fs/ubifs/debug.c         |    4 ++--
 fs/ubifs/journal.c       |    4 ++--
 fs/ubifs/sb.c            |    4 ++--
 fs/ubifs/super.c         |    4 ++--
 fs/ubifs/ubifs.h         |    4 ++--
 fs/udf/inode.c           |   12 ++++++------
 fs/udf/super.c           |   20 ++++++++++++--------
 fs/udf/udf_sb.h          |    4 ++--
 fs/ufs/inode.c           |   16 ++++++++--------
 init/Kconfig             |   11 -----------
 33 files changed, 214 insertions(+), 166 deletions(-)
