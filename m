From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace related fixes for 4.10-rc3
Date: Sat, 07 Jan 2017 18:30:05 +1300
Message-ID: <87d1fzzbc2.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: cd293bfacd57928627ef7da6194e0cbe24db3291 sysctl: Drop reference added by grab_header in proc_sys_readdir

This tree contains 5 fixes.

The first is a fix for a race that can causes oopses under the right
circumstances, and that someone just recently encountered.

The second is a fix that removes the possibility of creating unbounded
chains in the mount hash table.  After a lot of back and forth this fix
has finally matured into something mergeable.

Past that are several small trivial correct fixes.  A real issue that
was blocking development of an out of tree driver, but does not appear
to have caused any actual problems for in-tree code.  A potential
deadlock that was reported by lockdep.  And a deadlock people have
experienced and took the time to track down caused by a cleanup that
removed the code to drop a reference count.

Andrei Vagin (1):
      pid: fix lockdep deadlock warning due to ucount_lock

Eric W. Biederman (3):
      mnt: Protect the mountpoint hashtable with mount_lock
      mnt: Tuck mounts under others instead of creating shadow/side mounts.
      libfs: Modify mount_pseudo_xattr to be clear it is not a userspace mount

Zhou Chengming (1):
      sysctl: Drop reference added by grab_header in proc_sys_readdir

 fs/dcache.c            |   7 +-
 fs/libfs.c             |   3 +-
 fs/mount.h             |   1 -
 fs/namespace.c         | 174 +++++++++++++++++++++++++++++--------------------
 fs/pnode.c             |  27 ++++++--
 fs/pnode.h             |   2 +
 fs/proc/proc_sysctl.c  |   3 +-
 kernel/pid_namespace.c |  10 +--
 8 files changed, 142 insertions(+), 85 deletions(-)

Eric
