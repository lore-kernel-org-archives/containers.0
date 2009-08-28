From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46204-gec1611a
Date: Fri, 28 Aug 2009 10:22:18 -0400
Message-ID: <200908281422.n7SEMIoV032155@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v17-dev has been updated
       via  ec1611a161a6f51e693ec660afe8559b58d63241 (commit)
       via  a7bd29e7568341654a75878c99f7ab4a62b94f50 (commit)
       via  9ea72867c7b6c58e63d35012c18e8efe6cf7b9c4 (commit)
      from  ade9e4cfdd226a93145155d7a79d8ac5aea51c2b (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit ec1611a161a6f51e693ec660afe8559b58d63241
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Aug 27 19:21:42 2009 -0400

    c/r: disallow multiple objects with same objref in restart
    
    During restart objects join the objhash indexed by their @objref.
    They enter the objhash either via restore_obj() or ckpt_obj_insert().
    This patch ensure that the @objref of a new object does not already
    exist in the objhash.
    
    (The test in restore_obj() was done too early, and would have missed
    a recursive call to restore_obj() itself).
    
    Dan Smith pointed out the issue.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a7bd29e7568341654a75878c99f7ab4a62b94f50
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Thu Aug 27 13:49:34 2009 -0500

    signal c/r: don't play with zero timeouts
    
    If it_virt_expires or it_prof_expires is zero, then don't
    subtract {virt,prof}_ticks(t) from it.  This is the same
    thing do_getitimer() does, and it fixes my issues with
    the signals c/r patchset on s390.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 9ea72867c7b6c58e63d35012c18e8efe6cf7b9c4
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Aug 28 10:00:11 2009 -0400

    c/r: Fix compile error of af_unix without CONFIG_CHECKPOINT
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/objhash.c  |   10 ++++++----
 checkpoint/signal.c   |    8 ++++++--
 include/net/af_unix.h |    3 +++
 3 files changed, 15 insertions(+), 6 deletions(-)


hooks/post-receive
--
linux-cr
