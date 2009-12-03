From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v19-rc2,
	updated. v2.6.31-11615-g0e77aa9
Date: Wed, 2 Dec 2009 19:18:00 -0500
Message-ID: <200912030018.nB30I0kR008802@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v19-rc2 has been updated
       via  0e77aa947548ab2a24022c5ef9d73c67428c0249 (commit)
       via  a2b2c6286791502456f4651745d71a2c4b394e4b (commit)
      from  c8b46a47f3627896e2f73c48137d6d8753574c10 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 0e77aa947548ab2a24022c5ef9d73c67428c0249
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Dec 2 19:17:35 2009 -0500

    shmem_restore needs to use ckpt_obj_try_fetch
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit a2b2c6286791502456f4651745d71a2c4b394e4b
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Dec 2 13:18:08 2009 -0500

    remove clone_with_pids remnants from s390
    
    and fix syscall numbers
    
    c/r still doesn't work with this patch, but that's a separate
    issue.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/s390/include/asm/unistd.h    |    6 +++---
 arch/s390/kernel/compat_linux.c   |   19 -------------------
 arch/s390/kernel/compat_wrapper.S |    1 +
 arch/s390/kernel/syscalls.S       |    1 -
 mm/shmem.c                        |    2 +-
 5 files changed, 5 insertions(+), 24 deletions(-)


hooks/post-receive
-- 
linux-cr
