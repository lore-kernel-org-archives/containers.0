From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/6] mount namespace container enhancements
Date: Mon, 19 Nov 2012 02:48:40 -0800
Message-ID: <87k3thc1h3.fsf@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


This patchset adds the ability for the root user in a user namespace to
call choort, to create new mount namespaces, and to manipulate mount
namespaces (mount/umount) that the userns root has created.

Additionally support is added namespace file descriptors and for setns
on the namespace file descriptors.

To keep total chaos from breaking out mount namespace file descriptors
are not allowed to be mounted into a child mount namespace, and shared
subtrees become slave subtrees when creating a new mount namespace in a
different user namespace than it's parent.

This series of changes is available in git from:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git mntns-v53

Baring problems I plan to merge these changes through my user namespace
tree for 3.8

Eric W. Biederman (5):
      vfs: Allow chroot if you have CAP_SYS_CHROOT in your user namespace
      vfs: Add setns support for the mount namespace
      vfs: Add a user namespace reference from struct mnt_namespace
      vfs: Only support slave subtrees across different user namespaces
      vfs: Allow unprivileged manipulation of the mount namespace.

Zhao Hongjiang (1):
      userns: fix return value on mntns_install() failure

 fs/mount.h                    |    2 +
 fs/namespace.c                |  197 +++++++++++++++++++++++++++++++++--------
 fs/open.c                     |    2 +-
 fs/pnode.h                    |    1 +
 fs/proc/namespaces.c          |    5 +
 include/linux/fs.h            |    2 +
 include/linux/mnt_namespace.h |    3 +-
 include/linux/proc_fs.h       |    7 ++
 kernel/nsproxy.c              |    2 +-
 9 files changed, 182 insertions(+), 39 deletions(-)
