From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-106-gc61e759
Date: Sun, 18 Oct 2009 23:04:34 -0400
Message-ID: <200910190304.n9J34YKL021299@gorgona.ncl.cs.columbia.edu>
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
       via  c61e759d910952d9457ccb109bf4e91514af087f (commit)
       via  2654de0b63ea6250a155bc6abe4999bd6a60ae38 (commit)
      from  17c7c62ee3ac563a530b840328a31add6100dd87 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit c61e759d910952d9457ccb109bf4e91514af087f
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Sun Oct 18 22:56:54 2009 -0400

    test_and_set_bit returns oldval
    
    ckpt_set_ctx_error() was not setting ctx->errno when it should - it
    apparently thought that test_and_set_bit(x,y) would return 1 if the
    set_bit succeeded?
    
    Fix ckpt_set_ctx_error() to set ctx->errno the first (and only the
    first) time that CKPT_CTX_ERROR gets set in ctx->kflags.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 2654de0b63ea6250a155bc6abe4999bd6a60ae38
Author: \"Serge E. Hallyn\ <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 16 19:56:56 2009 -0400

    cr: add container configuration header
    
    Add a container configuration section to the checkpoint header.
    This will contain information such as the LSM name and policy
    identifier, potentially network interface and container-wide
    mounts.
    
    [ pulled out of the LSM c/r patchset ]
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 Documentation/checkpoint/readme.txt |   15 +++++++++++----
 checkpoint/checkpoint.c             |   18 ++++++++++++++++++
 checkpoint/restart.c                |   18 ++++++++++++++++++
 include/linux/checkpoint.h          |    4 ++--
 include/linux/checkpoint_hdr.h      |    7 +++++++
 5 files changed, 56 insertions(+), 6 deletions(-)


hooks/post-receive
--
linux-cr
