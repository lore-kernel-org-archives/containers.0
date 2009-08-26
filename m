From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46201-gade9e4c
Date: Wed, 26 Aug 2009 09:36:42 -0400
Message-ID: <200908261336.n7QDagiY026211@gorgona.ncl.cs.columbia.edu>
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
       via  ade9e4cfdd226a93145155d7a79d8ac5aea51c2b (commit)
      from  3c0a39896d10b796a509095a0f4b5004a412d114 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit ade9e4cfdd226a93145155d7a79d8ac5aea51c2b
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Aug 26 04:55:29 2009 -0700

    Rename headerless struct ckpt_hdr_* to struct ckpt_*
    
    Rename headerless struct ckpt_hdr_* to struct ckpt_*
    
        These structures do not, in fact, contain a struct ckpt_hdr so they
        should not be named struct ckpt_hdr_* but struct ckpt_*.
    
        Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    --
    Coccinelle patch (doesn't fixup headers but..):
    
    @@
    @@
    -struct ckpt_hdr_const
    +struct ckpt_constants
    @@
    @@
    -struct ckpt_hdr_pids
    +struct ckpt_pids
    @@
    @@
    -struct ckpt_hdr_socket
    +struct ckpt_socket
    @@
    @@
    -struct ckpt_hdr_sigset
    +struct ckpt_sigset
    @@
    @@
    -struct ckpt_hdr_sigaction
    +struct ckpt_sigaction
    @@
    @@
    -struct ckpt_hdr_siginfo
    +struct ckpt_siginfo
    @@
    @@
    -struct ckpt_hdr_rlimit
    +struct ckpt_rlimit

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/checkpoint.c          |    4 ++--
 checkpoint/restart.c             |    2 +-
 checkpoint/signal.c              |   16 ++++++++--------
 include/linux/checkpoint_hdr.h   |   34 ++++++++++++++++++----------------
 include/linux/checkpoint_types.h |    2 +-
 include/linux/net.h              |    4 ++--
 include/net/af_unix.h            |    4 ++--
 net/checkpoint.c                 |   10 +++++-----
 net/unix/checkpoint.c            |    8 ++++----
 9 files changed, 43 insertions(+), 41 deletions(-)


hooks/post-receive
--
linux-cr
