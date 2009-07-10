From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-rc1,
	updated. v2.6.27-rc5-45617-g5a33cf3
Date: Fri, 10 Jul 2009 13:02:07 -0400
Message-ID: <200907101702.n6AH27ot008977@gorgona.ncl.cs.columbia.edu>
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
       via  5a33cf3bbc06f823f40bc4c3ffdf1d1325ff685e (commit)
      from  dd07449e47df4bc59968e82b3a0e60f103b804cd (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 5a33cf3bbc06f823f40bc4c3ffdf1d1325ff685e
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Fri Jul 10 12:14:46 2009 -0400

    c/r: restore_retval() only for restarting tasks (not coordinator)
    
    restore_retval() digs out the old restore value (from checkpoint time)
    to ensure that a restarting tasks gives the correct retval.
    
    The coordinator should not replace it's own retval, of course. This
    fixes weird -ENOSYS seen at times after a restart by mktree.
    
    One exception is when the coordinator is also a restarting task, as
    is the case with self-restart (RESTART_TASKSELF).
    
    Finally, if a restarting tasks fails to restart, it will send a
    SIGKILL to itself, because otherwise a partial restore usually leaves
    the process in an undefined state.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/restart.c |   28 +++++++++++++++++++++++++---
 checkpoint/sys.c     |    9 ---------
 2 files changed, 25 insertions(+), 12 deletions(-)


hooks/post-receive
--
linux-cr
