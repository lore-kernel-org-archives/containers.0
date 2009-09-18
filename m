From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-rc1, updated. v2.6.31-85-gc0bd3fc
Date: Fri, 18 Sep 2009 13:21:13 -0400
Message-ID: <200909181721.n8IHLDvf031008@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v18-rc1 has been updated
       via  c0bd3fcdeec3ab8af8d16ec1eea796857c874111 (commit)
       via  f0cdd7e26c58993b41b86d8a390b63caefc70faa (commit)
       via  3e13a64a43191ce05bb26cab478a51832318e412 (commit)
       via  68ff00ebcd9aabb3f2b9b49d1b8358b00dc1f7c1 (commit)
       via  e9d859fb10fe18194bf5e8c8bf670f75968f2dd0 (commit)
      from  9b540da2481953d874f013ad63638b72eda01ff7 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit c0bd3fcdeec3ab8af8d16ec1eea796857c874111
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Sep 18 13:19:49 2009 -0400

    pty: set tty on error
    
    we always return tty expecting it to hold the error code.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] fix format for ckpt_write_err()

commit f0cdd7e26c58993b41b86d8a390b63caefc70faa
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Sep 18 13:19:43 2009 -0400

    Fix ckpt_obj_lookup_add() leak detection logic
    
    Since first is a pointer, it's never NULL and thus leak detection will
    always be performed (of CHECKPOINT_SUBTREE is set).  This fatally breaks
    the checkpoint process when that flag is enabled because any object (with
    a ref_users operation) that is added to the hash twice will be reported as
    a reverse leak.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3e13a64a43191ce05bb26cab478a51832318e412
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Sep 18 13:19:38 2009 -0400

    c/r: fix leak of ckpt_ctx in restart of zombie and ghost tasks
    
    This fixes the leaks reported by Serge Hallyn and Dan Smith.
    
    Signed-of-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 68ff00ebcd9aabb3f2b9b49d1b8358b00dc1f7c1
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Sep 18 13:19:33 2009 -0400

    c/r: trivial fix in error path in restore_coord()
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e9d859fb10fe18194bf5e8c8bf670f75968f2dd0
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Sep 18 13:19:27 2009 -0400

    c/r: fix dubious warning over format in ckpt_write_err()
    
    Also document how the @prefmt in ckpt_write_err, _ckpt_write_err
    works.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/checkpoint.c |   73 ++++++++++++++++++++++++++++++++++------------
 checkpoint/objhash.c    |    2 +-
 checkpoint/restart.c    |   10 ++++--
 drivers/char/tty_io.c   |    5 ++-
 4 files changed, 66 insertions(+), 24 deletions(-)


hooks/post-receive
--
linux-cr
