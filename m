From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 00/07] sysv SHM checkpoint/restart
Date: Tue, 31 Mar 2009 01:32:25 -0400
Message-ID: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This patchset adds support for IPC shared-memory. It applies on top
of c/r v14-rc2. Tested on x86_32 and verified with the test provided
in the userspace tools. 

Oren Laadan (7):
      ipc: allow allocation of an ipc object with desired identifier
      ipc: helpers to save and restore kern_ipc_perm structures
      sysvipc-shm: checkpoint
      sysvipc-shm: restart
      Infrastructure for work postponed to the end of checkpoint/restart
      sysvipc-shm: export interface from ipc/shm.c to delete ipc shm
      sysvipc-shm: correctly handle deleted (active) ipc shared memory

 checkpoint/Makefile            |    6 +-
 checkpoint/checkpoint.c        |    7 +
 checkpoint/ckpt_mem.c          |    9 +
 checkpoint/restart.c           |    6 +
 checkpoint/rstr_mem.c          |   23 +++
 checkpoint/sys.c               |    7 +
 checkpoint/util_ipc.c          |   81 ++++++++++
 checkpoint/workqueue.c         |   62 ++++++++
 include/linux/checkpoint.h     |   25 +++
 include/linux/checkpoint_hdr.h |   47 ++++++
 include/linux/shm.h            |    4 +
 ipc/Makefile                   |    1 +
 ipc/ckpt_shm.c                 |  339 ++++++++++++++++++++++++++++++++++++++++
 ipc/msg.c                      |   17 ++-
 ipc/sem.c                      |   17 ++-
 ipc/shm.c                      |   34 +++-
 ipc/util.c                     |   42 ++++--
 ipc/util.h                     |   11 +-
 18 files changed, 702 insertions(+), 36 deletions(-)
