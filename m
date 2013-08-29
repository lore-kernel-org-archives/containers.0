From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/5] A couple of lingering namespace patches
Date: Thu, 29 Aug 2013 16:52:18 -0700
Message-ID: <87ob8gys0d.fsf@xmission.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


There are a couple of long overdue namespace patches, simple cleanups
and permision grants that have been sitting in my development tree
for far too long.  If anyone objects to these please let me know.

Eric W. Biederman (4):
      namespaces: Simplify copy_namespaces so it is clear what is going on.
      userns: Allow PR_CAPBSET_DROP in a user namespace.
      pidns: Don't have unshare(CLONE_NEWPID) imply CLONE_THREAD
      userns:  Kill nsown_capable it makes the wrong thing easy

Serge Hallyn (1):
      capabilities: allow nice if we are privileged

 fs/namespace.c             |    4 ++--
 fs/open.c                  |    2 +-
 include/linux/capability.h |    1 -
 ipc/namespace.c            |    2 +-
 kernel/capability.c        |   12 ------------
 kernel/fork.c              |    5 -----
 kernel/groups.c            |    2 +-
 kernel/nsproxy.c           |   35 +++++++++++------------------------
 kernel/pid_namespace.c     |    2 +-
 kernel/sys.c               |   20 ++++++++++----------
 kernel/uid16.c             |    2 +-
 kernel/utsname.c           |    2 +-
 net/core/net_namespace.c   |    2 +-
 net/core/scm.c             |    4 ++--
 security/commoncap.c       |   10 +++++-----
 15 files changed, 37 insertions(+), 68 deletions(-)

Eric
