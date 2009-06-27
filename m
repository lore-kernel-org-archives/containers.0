From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][GIT]linux-cr branch, ckpt-v16-dev,
	updated. v2.6.27-rc5-36014-g8a031aa
Date: Sat, 27 Jun 2009 15:20:33 -0400
Message-ID: <200906271920.n5RJKXZX003236@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v16-dev has been updated
       via  8a031aa88271ac44e5574c15d82c21af98855876 (commit)
       via  27099c13bee4a24d4f79f8911d71bc99ddde95d3 (commit)
       via  fcb7a17df8c1b42346aab9fd5dd1af27beee2b39 (commit)
      from  c147a0c72dd40c5a0dba96602da3c8b1559cff1d (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 8a031aa88271ac44e5574c15d82c21af98855876
Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Thu Jun 25 12:51:25 2009 -0700

    c/r: better file error debugging
    
    This should give a nice message with symbol names for when we have an
    open file that doesn't have an f_op->checkpoint.
    
    Something along the lines of:
    
    [1133:c/r:checkpoint_file] file operations have no checkpoint handler:tty_open+0x0/0x24
    
    Also add a debug message when hitting an unlinked file.
    
    Based on a patch by Dave Hansen.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 27099c13bee4a24d4f79f8911d71bc99ddde95d3
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jun 26 15:06:43 2009 -0400

    cr: define CKPT_ARCH_NSIG for s390
    
    Also add a check for x86 and s390 in the hopes of catching any
    changes to NSIG which don't update CKPT_ARCH_NSIG.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit fcb7a17df8c1b42346aab9fd5dd1af27beee2b39
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Thu Jun 25 05:06:06 2009 -0400

    c/r: tighten ptrace checking for checkpoint to PTRACE_MODE_ATTACH
    
    Security modules distinguish reading of process state (via proc) from
    full ptrace access using the access mode: PTRACE_MODE_{READ,ATTACH}.
    
    Read access to /proc/pid/mem requires a full ptrace attach (for more
    details, see: http://lwn.net/Articles/282930/).
    
    Checkpoint needs access to full process state, including memory, so
    we require PTRACE_MODE_ATTACH.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/s390/include/asm/checkpoint_hdr.h |    8 ++++++++
 arch/x86/include/asm/checkpoint_hdr.h  |    6 ++++++
 checkpoint/checkpoint.c                |    2 +-
 checkpoint/files.c                     |    8 ++++++--
 4 files changed, 21 insertions(+), 3 deletions(-)


hooks/post-receive
--
linux-cr
