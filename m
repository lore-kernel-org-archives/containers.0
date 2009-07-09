From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-rc1,
	updated. v2.6.27-rc5-45615-g3c60cd0
Date: Thu, 9 Jul 2009 08:27:35 -0400
Message-ID: <200907091227.n69CRZ1T030321@gorgona.ncl.cs.columbia.edu>
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
       via  3c60cd06509ae7b12db3176dabc5a8baff45341a (commit)
      from  9cfe3c478746960e25a9f3abaeeb9d8503e0f74d (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 3c60cd06509ae7b12db3176dabc5a8baff45341a
Author: Oren Laadan <orenl-yTy6EFHyJFUdnm+yROfE0A@public.gmane.org>
Date:   Thu Jul 9 08:20:52 2009 -0400

    c/r: do not modify restart(2) retval for restarting tasks
    
    Since Restart(2) isn't idempotent, the coordinator should return
    -EINTR if interrupted so it does not retry the syscall blindly.
    
    Restarting tasks on the other way should always report the return
    values saved from checkpoint. If the syscall is interrupted, then they
    don't care about return value, because they terminate in response to a
    failure.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/sys.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)


hooks/post-receive
--
linux-cr
