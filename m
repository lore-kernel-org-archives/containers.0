From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 00/10] sysv SHM checkpoint/restart
Date: Tue,  7 Apr 2009 08:31:33 -0400
Message-ID: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
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

This patchset adds support for IPC shared-memory and message queues.
It applies on top of c/r v14. Tested on x86_32 and verified with the 
tests provided in the userspace tools. 

Changelog:

  [2009-Apr-07] [v2]
  - Reorder paches
  - Rename 'cr_workqueue' -> 'cr_deferqueue'
  - Add c/r of sysvipc message queues
  - Integrate with recent naemspaces c/r (rebase on ckpt-v14)

Summary:

Oren Laadan (10):
      Infrastructure for work postponed to the end of checkpoint/restart
      ipc: allow allocation of an ipc object with desired identifier
      ipc: helpers to save and restore kern_ipc_perm structures
      sysvipc-shm: checkpoint
      sysvipc-shm: restart
      sysvipc-shm: export interface from ipc/shm.c to delete ipc shm
      sysvipc-shm: correctly handle deleted (active) ipc shared memory
      sysvipc-msg: make 'struct msg_msgseg' visible in ipc/util.h
      sysvipc-msq: checkpoint
      sysvipc-msq: restart

 checkpoint/Makefile            |    5 +-
 checkpoint/checkpoint.c        |    4 +
 checkpoint/ckpt_mem.c          |    9 +
 checkpoint/ckpt_task.c         |    2 +-
 checkpoint/deferqueue.c        |   62 ++++++
 checkpoint/restart.c           |    5 +
 checkpoint/rstr_file.c         |    1 -
 checkpoint/rstr_mem.c          |   23 +++
 checkpoint/rstr_task.c         |    2 +-
 checkpoint/sys.c               |    7 +
 checkpoint/util_ipc.c          |   95 +++++++++
 include/linux/checkpoint.h     |   28 +++
 include/linux/checkpoint_hdr.h |   65 +++++++
 include/linux/shm.h            |    4 +
 ipc/Makefile                   |    1 +
 ipc/ckpt_msg.c                 |  414 ++++++++++++++++++++++++++++++++++++++++
 ipc/ckpt_shm.c                 |  339 ++++++++++++++++++++++++++++++++
 ipc/msg.c                      |   20 ++-
 ipc/msgutil.c                  |    8 -
 ipc/sem.c                      |   17 ++-
 ipc/shm.c                      |   34 +++-
 ipc/util.c                     |   42 +++--
 ipc/util.h                     |   20 ++-
 23 files changed, 1158 insertions(+), 49 deletions(-)
 create mode 100644 checkpoint/deferqueue.c
 create mode 100644 checkpoint/util_ipc.c
 create mode 100644 ipc/ckpt_msg.c
 create mode 100644 ipc/ckpt_shm.c
