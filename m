From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace changes for 4.17-rc1
Date: Tue, 03 Apr 2018 14:16:04 -0500
Message-ID: <87k1tonlsb.fsf__23284.9379921847$1522782925$gmane$org@xmission.com>
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
Cc: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>, Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>, James Morris <james.morris-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the userns-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-linus

   HEAD: 2236d4d39035b9839944603ec4b65ce71180a9ea ipc/shm: Fix pid freeing.

There was a lot of work this cycle fixing bugs that were discovered after
the merge window and getting everything ready where we can reasonably
support fully unprivileged fuse.   The bug fixes you already have and
much of the unprivileged fuse work is coming in via other trees.

Still left for fully unprivileged fuse is figuring out how to cleanly
handle .set_acl and .get_acl in the legacy case, and properly handling
of evm xattrs on unprivileged mounts.

Included in the tree is a cleanup from Alexely that replaced a linked
list with a statically allocated fix sized array for the pid caches,
which simplifies and speeds things up.

Then there is are some cleanups and fixes for the ipc namespace.  The
motivation was that in reviewing other code it was discovered that
access ipc objects from different pid namespaces recorded pids in such a
way that when asked the wrong pids were returned.  In the worst case
there has been a mearsured 30% performance impact for sysvipc
semaphores.  Other test cases showed no measurable performance impact.
Manfred Spraul and Davidlohr Bueso who tend to work on sysvipc
performance both gave the nod that this is good enough.

Casey Schaufler and James Morris have given their approval to the LSM
side of the changes.

I simplified the types and the code dealing with sysvipc to pass just
kern_ipc_perm for all three types of ipc.  Which reduced the header
dependencies throughout the kernel and simplified the lsm code.

Which let me work on the pid fixes without having to worry about trivial
changes causing complete kernel recompiles.

When merging you may see a trivial conflict with the syscalls tree
where adjacent lines in the sysvipc code were touched.

Alexey Dobriyan (1):
      pidns: simpler allocation of pid_* caches

Eric W. Biederman (14):
      sem/security: Pass kern_ipc_perm not sem_array into the sem security hooks
      shm/security: Pass kern_ipc_perm not shmid_kernel into the shm security hooks
      msg/security: Pass kern_ipc_perm not msg_queue into the msg_queue security hooks
      sem: Move struct sem and struct sem_array into ipc/sem.c
      shm: Move struct shmid_kernel into ipc/shm.c
      msg: Move struct msg_queue into ipc/msg.c
      ipc: Move IPCMNI from include/ipc.h into ipc/util.h
      ipc/util: Helpers for making the sysvipc operations pid namespace aware
      ipc/shm: Fix shmctl(..., IPC_STAT, ...) between pid namespaces.
      ipc/msg: Fix msgctl(..., IPC_STAT, ...) between pid namespaces
      ipc/sem: Fix semctl(..., GETPID, ...) between pid namespaces
      ipc: Directly call the security hook in ipc_ops.associate
      ipc/smack: Tidy up from the change in type of the ipc security hooks
      ipc/shm: Fix pid freeing.

Stephen Rothwell (1):
      ipc/shm: fix up for struct file no longer being available in shm.h

 include/linux/ipc.h        |   2 -
 include/linux/lsm_hooks.h  |  32 ++++----
 include/linux/msg.h        |  18 -----
 include/linux/security.h   |  67 ++++++++-------
 include/linux/sem.h        |  40 +--------
 include/linux/shm.h        |  22 +----
 ipc/msg.c                  |  62 ++++++++------
 ipc/sem.c                  |  81 ++++++++++++-------
 ipc/shm.c                  |  68 ++++++++++------
 ipc/util.c                 |   9 +++
 ipc/util.h                 |  12 +++
 kernel/pid_namespace.c     |  67 ++++++---------
 security/security.c        |  32 ++++----
 security/selinux/hooks.c   |  92 ++++++++++-----------
 security/smack/smack_lsm.c | 197 +++++++++++++--------------------------------
 15 files changed, 346 insertions(+), 455 deletions(-)
