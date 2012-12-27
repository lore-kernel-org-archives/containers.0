From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace fixes for v3.8-rc2
Date: Wed, 26 Dec 2012 17:04:19 -0800
Message-ID: <87han82tm4.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus git tree from:

   git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 48c6d1217e3dc743e7d3ad9b9def8d4810d13a85 f2fs: Don't assign e_id in f2fs_acl_from_disk

   This tree is against v3.8-rc1

This tree includes two bug fixes for problems Oleg spotted on his review
of the recent pid namespace work.  A small fix to not enable bottom
halves with irqs disabled, and a trivial build fix for f2fs with user
namespaces enabled.

Eric W. Biederman (4):
      pidns: Outlaw thread creation after unshare(CLONE_NEWPID)
      pidns: Stop pid allocation when init dies
      proc: Allow proc_free_inum to be called from any context
      f2fs: Don't assign e_id in f2fs_acl_from_disk

 fs/f2fs/acl.c                 |    1 -
 fs/proc/generic.c             |   13 +++++++------
 include/linux/pid.h           |    1 +
 include/linux/pid_namespace.h |    4 +++-
 kernel/fork.c                 |    8 ++++++++
 kernel/pid.c                  |   15 ++++++++++++---
 kernel/pid_namespace.c        |    4 ++++
 7 files changed, 35 insertions(+), 11 deletions(-)
