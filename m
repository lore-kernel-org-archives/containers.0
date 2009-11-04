From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-139-g371f330
Date: Wed, 4 Nov 2009 13:00:27 -0500
Message-ID: <200911041800.nA4I0RRc013545@gorgona.ncl.cs.columbia.edu>
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
       via  371f33026ee110e6232f3160fd312f1fdbe4bd3b (commit)
       via  e124bb2fef7172526f66834f84db33cf63e2f1f2 (commit)
       via  30478e9427ec50428ab58877fc76147968445ca1 (commit)
       via  09a6bd88b4c84621ccefd446fcd2b0536268828c (commit)
       via  03521a11a9599061518ebee50315cac83928d3ce (commit)
       via  30a76affe75a99a12aa5f746aad309ca95f2eb79 (commit)
       via  b03424642f4c7d944ca0f636c0f6c9fd20401903 (commit)
       via  cb48d731108ac61f9381c1581449de78acfc4b36 (commit)
       via  518a37d1285da2595facc2586e32e4f9a309ef8e (commit)
       via  92c90a19579d4bf45a1017d6fbb1c4d269d3e789 (commit)
       via  901cea729d7e6df21fbf89ea596eacb918a9aea9 (commit)
       via  c7fbaefb08e672ececb8ac2a6fa862d8b5bf3ae7 (commit)
       via  4aab33cac4c6d82b396108004c36fdffad36c694 (commit)
      from  c1405acba1fe1450593da966a4a4c37ab049e785 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 371f33026ee110e6232f3160fd312f1fdbe4bd3b
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:47 2009 -0500

    add logfd to c/r api
    
    and write msgs to user-provided logfile if one exists.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit e124bb2fef7172526f66834f84db33cf63e2f1f2
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:45 2009 -0500

    remove ckpt_write_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 30478e9427ec50428ab58877fc76147968445ca1
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:44 2009 -0500

    net/{,unix}/checkpoint.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 09a6bd88b4c84621ccefd446fcd2b0536268828c
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:43 2009 -0500

    fs/eventpoll.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 03521a11a9599061518ebee50315cac83928d3ce
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:42 2009 -0500

    drivers/char/tty_io.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 30a76affe75a99a12aa5f746aad309ca95f2eb79
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:41 2009 -0500

    checkpoint/signal.c: use ckpt_err
    
    Also fix an instance of ckpt_write_err under spinlock
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit b03424642f4c7d944ca0f636c0f6c9fd20401903
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:40 2009 -0500

    checkpoint/process.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit cb48d731108ac61f9381c1581449de78acfc4b36
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:39 2009 -0500

    checkpoint/objhash.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 518a37d1285da2595facc2586e32e4f9a309ef8e
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:38 2009 -0500

    checkpoint/memory.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 92c90a19579d4bf45a1017d6fbb1c4d269d3e789
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:37 2009 -0500

    checkpoint/files.c: use ckpt_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 901cea729d7e6df21fbf89ea596eacb918a9aea9
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:36 2009 -0500

    checkpoint/checkpoint.c: use ckpt_err
    
    This also fixes a bug where ckpt_write_err was called under rwlock_t.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit c7fbaefb08e672ececb8ac2a6fa862d8b5bf3ae7
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Nov 4 12:08:34 2009 -0500

    arch/x86/mm/checkpoint.c: use ckp_err
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 4aab33cac4c6d82b396108004c36fdffad36c694
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Sun Nov 1 09:19:40 2009 -0500

    define a new set of functions for error and debug logging
    
    The checkpoint context now includes buffers for an expanded
    format and for messages to be written out.  A mutex protects
    these buffers as they are being built up and written out.
    ckpt_msg() will write general informative (debug) messages to
    syslog and an optional user-provided logfile.  ckpt_err() will
    write errors to the same places, and, if it is a checkpoint
    operation, also to the checkpoint image.
    
    (This is intended to implement Oren's suggestion verbatim)
    
    Changelog:
    	Nov 3: Several suggestions by Matt, including:
    		msg_complete return on empty msg; make _ckpt_generate_fmt
    		static; and dont put spaces between prefix tags.
    	Nov 3: Make sure ctx->fmt ends with \0!
    	Nov 3: pass errno to ckpt_err(), and have ckpt_msg_complete()
    		only write to checkpoint image if ctx->errno is set.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/x86/mm/checkpoint.c         |    5 +-
 checkpoint/checkpoint.c          |  217 ++++----------------------------------
 checkpoint/files.c               |   23 ++--
 checkpoint/memory.c              |   10 +-
 checkpoint/objhash.c             |   27 +++---
 checkpoint/process.c             |    8 +-
 checkpoint/signal.c              |   11 +-
 checkpoint/sys.c                 |  203 ++++++++++++++++++++++++++++++++++-
 drivers/char/tty_io.c            |   24 +++--
 fs/eventpoll.c                   |    2 +-
 include/linux/checkpoint.h       |   75 ++++++++++++--
 include/linux/checkpoint_types.h |    6 +
 include/linux/syscalls.h         |    5 +-
 net/checkpoint.c                 |   14 ++--
 net/unix/checkpoint.c            |    5 +-
 15 files changed, 363 insertions(+), 272 deletions(-)


hooks/post-receive
--
linux-cr
