From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46200-g3c0a398
Date: Tue, 25 Aug 2009 01:54:13 -0400
Message-ID: <200908250554.n7P5sDc0000501@gorgona.ncl.cs.columbia.edu>
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
       via  3c0a39896d10b796a509095a0f4b5004a412d114 (commit)
       via  b705d06585590fd1f0518f4448a814d161316da8 (commit)
       via  9e3b35a9e0313ef72f996e13cbd7b97928e5e029 (commit)
       via  7c15ed72d7909ee8d0520dfdf9600415cf790a36 (commit)
       via  00fee04912743c83e256dd6feb49ce23d13023fd (commit)
       via  a463c9883362f9bcde298a24f13e271313fc5f8b (commit)
      from  1344cd02706d6730ea7168c2f5f5681026e86213 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 3c0a39896d10b796a509095a0f4b5004a412d114
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 24 10:11:56 2009 -0700

    Set the CHECKPOINTED flag on objects before calling checkpoint
    
    This helps prevent infinite recursion where the checkpoint() operation on an
    object could potentially result in another checkpoint() of itself.
    
    UNIX sockets would easily encounter this when we call checkpoint on all
    related sockets, which would in turn try to checkpoint us again.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit b705d06585590fd1f0518f4448a814d161316da8
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 24 11:19:54 2009 -0700

    Remove struct timeval from socket header
    
    This patch removes the 'struct timeval' from the socket header and replaces
    it with a fixed-size type as suggested by Oren.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 9e3b35a9e0313ef72f996e13cbd7b97928e5e029
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 24 10:28:04 2009 -0700

    Save and restore UNIX socket peer credentials (v2)
    
    This saves the uid/gid of the sk_peercred structure in the checkpoint
    stream.  On restart, it uses may_setuid() and may_setgid() to determine
    if the uid/gid from the checkpoint stream may be used.
    
    Changes in v3:
     - Fix error path when may_setuid() or may_setgid() fail
    
    Changes in v2:
     - Adjust for may_setgid() change
    
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 7c15ed72d7909ee8d0520dfdf9600415cf790a36
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 24 10:28:03 2009 -0700

    Expose may_setuid() in user.h and add may_setgid() (v2)
    
    Make these helpers available to others.
    
    Changes in v2:
     - Avoid checking the groupinfo in ctx->realcred against the current in
       may_setgid()
    
    Cc: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 00fee04912743c83e256dd6feb49ce23d13023fd
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 24 11:54:07 2009 -0700

    Set socket flags on restore using sock_setsockopt() where possible (v3)
    
    Fail on the TIMESTAMPING_* flags for the moment, with a TODO in place to
    handle them later.
    
    Also remove other explicit flag checks because they're no longer copied
    blindly into the socket object, so existing checks will be sufficient.
    
    Changes in v3:
     - Move socket flag restore procedures into some common functions and a
       mapping list.  While definitely nicer to look at, my diffstat shows it
       as only saving a single line of code over the previous, while dropping
       the ability to print symbolic flag names in the error messages.
    
    Changes in v2:
     - Avoid removing the sock->sk_socket check before sync'ing the socket.flags
     - Rename sock_rst_flags() to sock_restore_flags()
     - Rebase on top of Oren's cleanup patch
    
    Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit a463c9883362f9bcde298a24f13e271313fc5f8b
Author: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date:   Wed Aug 19 12:46:54 2009 -0700

    c/r: alloc_pid() should return -ENOMEM on failure
    
    The clone_with_pids() patchset changed alloc_pid() to return an error
    code in the pointer. alloc_pid() should then return -ENOMEM rather than
    NULL when memory allocations fails.
    
    Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/objhash.c           |    3 +-
 include/linux/checkpoint_hdr.h |    7 ++-
 include/linux/user.h           |    9 +++
 kernel/pid.c                   |    4 +-
 kernel/user.c                  |   13 ++++-
 net/checkpoint.c               |  134 ++++++++++++++++++++++++++++++++++++----
 net/unix/checkpoint.c          |   30 +++++----
 7 files changed, 168 insertions(+), 32 deletions(-)


hooks/post-receive
--
linux-cr
