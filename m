From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46167-g45c1135
Date: Wed, 22 Jul 2009 23:45:38 -0400
Message-ID: <200907230345.n6N3jcAH029042@gorgona.ncl.cs.columbia.edu>
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
       via  45c11355ac16ceec2d8067ff1b3e3486fbfbce0a (commit)
       via  f8b21d1fb5a162ae4ae8460dbde1981cf5df36a0 (commit)
       via  9efd630c26be10aee66a7d124f57b6227257a47e (commit)
      from  cb4f8e444888f12d994fb914adb23d3742fd6cb1 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 45c11355ac16ceec2d8067ff1b3e3486fbfbce0a
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 22 23:42:08 2009 -0400

    c/r: test for kmalloc failure in restore_sem_array()
    
    Pointed out by Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

commit f8b21d1fb5a162ae4ae8460dbde1981cf5df36a0
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 22 23:06:35 2009 -0400

    c/r: add pre-header to pipe buffer to standard object format
    
    Change format of pipe state (buffer) dump according to rules:
    
    "The checkpoint image format is built of records that consist of a
    pre-header identifying its contents, followed by a payload. This
    format allow userspace tools to easily parse and skip through the
    image without requiring intimate knowledge of the data."
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 9efd630c26be10aee66a7d124f57b6227257a47e
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Wed Jul 22 22:57:52 2009 -0400

    c/r: _ckpt_read_obj_type() to read in only header if @ptr==NULL
    
    Give a way to read an object header without the payload, such that
    actual payload can be read later directly into destination buffer.
    
    _ckpt_read_obj_type() won't read in payload if @ptr==NULL, will not
    enforce object length if @len==0, and returns actual _payload_ length
    (not total length!) to caller.
    
    While at it, also a few cleanups - remove unused _ckpt_read_nbuffer(),
    documentation, and fix compiler warning on debug printk.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 checkpoint/restart.c           |   48 ++++++++++-----------------------------
 fs/pipe.c                      |   19 ++-------------
 include/linux/checkpoint_hdr.h |    7 +-----
 ipc/checkpoint_sem.c           |    2 +
 4 files changed, 19 insertions(+), 57 deletions(-)


hooks/post-receive
--
linux-cr
