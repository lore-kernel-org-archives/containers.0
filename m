From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-rc1,
	updated. v2.6.27-rc5-45621-ge428694
Date: Mon, 13 Jul 2009 18:59:11 -0400
Message-ID: <200907132259.n6DMxBTu007678@gorgona.ncl.cs.columbia.edu>
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

The branch, ckpt-v17-rc1 has been updated
       via  e428694a8f6857a10afbd99660bc695c353aa74b (commit)
       via  135961c0bbe19ba9bf21c40d0b837630df2d2639 (commit)
      from  4cbbabe2c7c1ba884c685654cf52f9f1a79320a0 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit e428694a8f6857a10afbd99660bc695c353aa74b
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Jul 13 05:36:15 2009 -0700

    Save and restore the [compat_]robust_list member of the task struct.
    
    These lists record which futexes the task holds. To keep the overhead of
    robust futexes low the list is kept in userspace. When the task exits the
    kernel carefully walks these lists to recover held futexes that
    other tasks may be attempting to acquire with FUTEX_WAIT.
    
    Because they point to userspace memory that is saved/restored by
    checkpoint/restart saving the list pointers themselves is safe.
    
    While saving the pointers is safe during checkpoint, restart is tricky
    because the robust futex ABI contains provisions for changes based on
    checking the size of the list head. So we need to save the length of
    the list head too in order to make sure that the kernel used during
    restart is capable of handling that ABI. Since there is only one ABI
    supported at the moment taking the list head's size is simple. Should
    the ABI change we will need to use the same size as specified during
    sys_set_robust_list() and hence some new means of determining the length
    of this userspace structure in sys_checkpoint would be required.
    
    Rather than rewrite the logic that checks and handles the ABI we reuse
    sys_set_robust_list() by factoring out the body of the function and
    calling it during restart.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 135961c0bbe19ba9bf21c40d0b837630df2d2639
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Jul 13 18:56:50 2009 -0400

    c/r: export include/linux/checkpoint.h
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/process.c           |    2 +
 include/linux/Kbuild           |    1 +
 include/linux/checkpoint_hdr.h |    5 ++++
 include/linux/compat.h         |    3 +-
 include/linux/futex.h          |   46 ++++++++++++++++++++++++++++++++++++++++
 kernel/futex.c                 |   19 ++++++++++------
 kernel/futex_compat.c          |   13 ++++++++--
 7 files changed, 78 insertions(+), 11 deletions(-)


hooks/post-receive
--
linux-cr
