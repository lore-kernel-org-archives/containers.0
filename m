From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-rc1,
	updated. v2.6.27-rc5-45616-gdd07449
Date: Thu, 9 Jul 2009 16:03:26 -0400
Message-ID: <200907092003.n69K3QGY031957@gorgona.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v17-rc1 has been updated
       via  dd07449e47df4bc59968e82b3a0e60f103b804cd (commit)
      from  3c60cd06509ae7b12db3176dabc5a8baff45341a (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit dd07449e47df4bc59968e82b3a0e60f103b804cd
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 9 15:59:00 2009 -0400

    c/r: fix compilation for architectures that don't support checkpoint
    
    Everybody should include linux/checkpoint.h.
    
    linux/checkpoint.h is surrounded by CONFIG_CHECKPOINT, and also
    includes asm/checkpoint.h.
    
    include asm/checkpoint.h should not be included directly.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/s390/include/asm/checkpoint_hdr.h |    5 ++++-
 arch/x86/include/asm/checkpoint_hdr.h  |    4 ++++
 fs/pipe.c                              |    3 +--
 include/linux/checkpoint.h             |    2 ++
 ipc/shm.c                              |    1 -
 kernel/capability.c                    |    4 +++-
 mm/filemap.c                           |    4 +---
 mm/mmap.c                              |    5 +----
 mm/shmem.c                             |    3 ---
 9 files changed, 16 insertions(+), 15 deletions(-)


hooks/post-receive
--
linux-cr
