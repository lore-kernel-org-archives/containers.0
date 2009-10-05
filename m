From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-97-g62cb614
Date: Mon, 5 Oct 2009 11:49:00 -0400
Message-ID: <200910051549.n95Fn0rW015558@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v18-dev has been updated
       via  62cb61406362bdae647789f41156b9a8ad856fbb (commit)
       via  bb091acbf0a47bd61323322a4e0a784d1ee0c24f (commit)
      from  26656f4d3810a24fa51b57fc66906d241b583001 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 62cb61406362bdae647789f41156b9a8ad856fbb
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Oct 5 11:46:11 2009 -0400

    Fix in.h include in checkpoint_hdr.h
    
    sys/in.h doesn't exist, at least not in the glibc headers of my Fedora or
    Ubuntu systems. Use netinet/in.h which does.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org

commit bb091acbf0a47bd61323322a4e0a784d1ee0c24f
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sat Oct 3 18:52:29 2009 -0400

    c/r: threads sync on restart (fix regression from commit afbe522c...)
    
    Initialize the new member signal->restart_count in copy_signal().
    
    The lack of which in commit afbe522ccf6b1deb5edfc01a00becfe6ee325d0c,
    c/r: let entire thread group in sys_restart before restoring a thread,
    can cause run-pthreads1.sh test failure.
    
    In this patch are two other small cleanups:
    
    1) In post_restore_task() test if current->checkpoint_data is valid,
    and return immediately if not (meaning restart failed early).
    
    2) Replace two instances of DECLARE_WAIT_QUEUE_HEAD(waitq) with
    DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq), to please the lockdep checked.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/process.c           |    4 ++++
 checkpoint/restart.c           |    4 ++--
 include/linux/checkpoint_hdr.h |    2 +-
 kernel/fork.c                  |    4 ++++
 4 files changed, 11 insertions(+), 3 deletions(-)


hooks/post-receive
--
linux-cr
