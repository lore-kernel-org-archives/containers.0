From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46185-ge861b44
Date: Fri, 14 Aug 2009 16:21:36 -0400
Message-ID: <200908142021.n7EKLa1o012185@gorgona.ncl.cs.columbia.edu>
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
       via  e861b44b93a6e14571bcc2f9d68b46ca8c44a734 (commit)
       via  ab84defe5b093ecec3a4a1abf2bc32f768e3205e (commit)
      from  d8a68a4242a854ed585caa81d3aed61965c91e55 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit e861b44b93a6e14571bcc2f9d68b46ca8c44a734
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Fri Aug 14 16:14:18 2009 -0400

    Fix off-by-one buffer length passed to ckpt_write_string()
    
    Reading and writing of strings expect the buffer length to include
    the terminating NULL (reading will also enforce it). This patch
    fixes the call from sock_unix_write_cwd() to include it.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit ab84defe5b093ecec3a4a1abf2bc32f768e3205e
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Aug 14 08:35:53 2009 -0700

    Fix kfree() corruption in sock_read_buffer_sendmsg()
    
    The memcpy_from_iovec() function that the unix sendmsg functions use modifies
    the struct msghdr.  Since the current code uses the msg.iovec_base pointer
    in the msghdr for the kmalloc() and kfree(), we end up freeing the wrong
    pointer.  This patch stores the original address in a separate pointer and
    corrects the kfree() call to use it.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Tested-By: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 net/unix/checkpoint.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)


hooks/post-receive
--
linux-cr
