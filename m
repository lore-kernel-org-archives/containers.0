From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46181-ga101d30
Date: Wed, 12 Aug 2009 02:11:45 -0400
Message-ID: <200908120611.n7C6BjA6004984@gorgona.ncl.cs.columbia.edu>
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
       via  a101d30a3bfee4bc38fb646e44c20929f699699b (commit)
       via  5c578335981c7646aa8ef9670360835da651923b (commit)
       via  71c65cbca9b7818794f0729897adf55bd4fe4cf7 (commit)
       via  76771b2c0dd2e5d5865dc39723b2fe241ed4510c (commit)
       via  4b5ec1174fdf253e228bf7e2ac1b03fd14f07fe3 (commit)
       via  5ba97282f91791338a4ecbb847a5eacc99685c7f (commit)
      from  220b6605740c677c252a5f43d9add9584b855eda (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit a101d30a3bfee4bc38fb646e44c20929f699699b
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 10 08:32:58 2009 -0700

    Export fill_fname() as ckpt_fill_fname()
    
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 5c578335981c7646aa8ef9670360835da651923b
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 10 08:32:57 2009 -0700

    Add common socket helpers to unify the security hooks
    
    This moves the meat out of the bind(), getsockname(), and getpeername() syscalls
    into helper functions that performs security_socket_bind() and then the
    sock->ops->call().  This allows a unification of this behavior between the
    syscalls and the pending socket restart logic.
    
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

commit 71c65cbca9b7818794f0729897adf55bd4fe4cf7
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Aug 10 08:32:55 2009 -0700

    Add an errno validation function (v2)
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    
    Changes in v2:
      - Compare against MAX_ERRNO instead of more stringent but obscure
        constant

commit 76771b2c0dd2e5d5865dc39723b2fe241ed4510c
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 11 23:53:50 2009 -0400

    c/r: add ckpt_read_payload() and ckpt_read_string()
    
    ckpt_read_payload() allows caller to read a variable-length object. It
    allocated memory and reads only the payload (without header).
    
    ckpt_read_string() uses is similar, but used to read strings - so it
    also verifies that the string is null terminated.
    
    Originally suggested and coded by Dan Smith.
    
    Signed-off-by: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>

commit 4b5ec1174fdf253e228bf7e2ac1b03fd14f07fe3
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Thu Aug 6 21:00:52 2009 -0500

    objhash: fix syntax error
    
    first two args to ckpt_write_err() were switched
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 5ba97282f91791338a4ecbb847a5eacc99685c7f
Author: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date:   Tue Aug 4 15:58:12 2009 -0500

    powerpc: vdso build fix (ckpt-v17)
    
    arch/powerpc/kernel/vdso.c: In function 'arch_setup_additional_pages':
    arch/powerpc/kernel/vdso.c:244: error: 'ret' undeclared (first use in this function)
    arch/powerpc/kernel/vdso.c:244: error: (Each undeclared identifier is reported only once
    arch/powerpc/kernel/vdso.c:244: error: for each function it appears in.)
    
    Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/powerpc/kernel/vdso.c |    2 +-
 checkpoint/files.c         |    8 +++---
 checkpoint/objhash.c       |    4 +-
 checkpoint/restart.c       |   54 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |   12 +++++++++-
 include/net/sock.h         |   48 +++++++++++++++++++++++++++++++++++++++
 net/socket.c               |   29 +++++------------------
 7 files changed, 126 insertions(+), 31 deletions(-)


hooks/post-receive
--
linux-cr
