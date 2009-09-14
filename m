From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46209-g8c114fb
Date: Mon, 14 Sep 2009 15:43:15 -0400
Message-ID: <200909141943.n8EJhFkO027395@gorgona.ncl.cs.columbia.edu>
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
       via  8c114fb043a0ef395ca05d2e018df492e98a0362 (commit)
       via  897e53537e41264b48f21bebc6374553933fb855 (commit)
       via  b08c684ffddc0aed290a06a5a31ccebfeb328f0a (commit)
      from  a34b0e08104452ef2d3eff49d6530915701cdbc8 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 8c114fb043a0ef395ca05d2e018df492e98a0362
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Thu Sep 10 17:33:44 2009 -0500

    cr: add a few more ckpt_write_err()s
    
    The main point is for new-comers to the checkpoint/restart tree to
    be able to help us debug their otherwise mysterious checkpoint failures.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 897e53537e41264b48f21bebc6374553933fb855
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Sep 9 08:05:55 2009 -0700

    Add post-file deferqueue (v2)
    
    This is the deferq bit of Matt's patch, which is needed by the subsequent
    socket patch.
    
    Changes in v2:
     - Allocate and destroy the deferqueue at context alloc/free time
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit b08c684ffddc0aed290a06a5a31ccebfeb328f0a
Author: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date:   Tue Sep 8 16:37:52 2009 -0500

    checkpoint: discard const from struct cred * where appropriate
    
    Building the checkpoint tree results in enough build noise that
    it's getting easy to miss new warnings added during development:
    
    kernel/cred.c:737: warning: passing argument 2 of 'checkpoint_capabilities' discards qualifiers from pointer target type
    checkpoint/process.c:146: warning: assignment discards qualifiers from pointer target type
    checkpoint/process.c:147: warning: assignment discards qualifiers from pointer target type
    checkpoint/files.c:154: warning: passing argument 2 of 'checkpoint_obj' discards qualifiers from pointer target type
    
    The objhash code would require significant modification to properly
    handle const objects, and only struct cred * is causing this kind of
    warning, so just insert casts or drop const where it makes sense.
    
    Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/checkpoint.c          |   28 ++++++++++++++++---
 checkpoint/files.c               |   54 ++++++++++++++++++++++++++++++++-----
 checkpoint/memory.c              |   17 ++++++++++--
 checkpoint/process.c             |    4 +-
 checkpoint/sys.c                 |    7 +++++
 include/linux/checkpoint_types.h |    1 +
 kernel/cred.c                    |    2 +-
 7 files changed, 94 insertions(+), 19 deletions(-)


hooks/post-receive
--
linux-cr
