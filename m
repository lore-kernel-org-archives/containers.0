From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-121-g066f73a
Date: Mon, 26 Oct 2009 20:33:16 -0400
Message-ID: <200910270033.n9R0XGbT001216@gorgona.ncl.cs.columbia.edu>
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
       via  066f73af9c55d4fa285f3065a9403a81d52228c8 (commit)
       via  ddc2e0182fd6a0a3c472511d70bf7ad53adc36bd (commit)
       via  27c330128468149a9cf72bd2c357c64f10f3b708 (commit)
       via  90c3bb2299d31ec2674ebc8b395b7e8e316f26e5 (commit)
       via  782b028736703077eb5eb49275814ceb7ba8c207 (commit)
       via  0b793d1e4e3cb68ef0640ab59db9b71dde5a9ac6 (commit)
       via  e57f0b4bb8daf82c15a99095ecf38cb7383fae08 (commit)
       via  cdcf6fb28deb49c1c6894ffcc69f3d6ba7143c45 (commit)
       via  3e2a0222bd4fb4e2ec1832067fa0b0a34fee2508 (commit)
       via  eb0d0fcb9773e39196279d70aa6cd33175f6490d (commit)
       via  0281537867abbff0b2fddd62945dd66df0a509ab (commit)
       via  c98f0ecec7bb88c6ead0a7ac6792c8c87ea9a015 (commit)
       via  de65dad23dd4f32df9c073c8261000e1c515b999 (commit)
       via  8510e48fda09b2246f1dc028cf887a36be20db81 (commit)
       via  47cd8119e3d861be46eb029d1c9b81c7684a2030 (commit)
      from  c61e759d910952d9457ccb109bf4e91514af087f (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 066f73af9c55d4fa285f3065a9403a81d52228c8
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Mon Oct 26 20:31:14 2009 -0400

    [RFC] Checkpoint/restart eventfd
    
    Save/restore eventfd files. These are anon_inodes just like epoll
    but instead of a set of files to poll they are a 64-bit counter
    and a flag value. Used for AIO.
    
    [Oren Laadan] Added #ifdef's around checkpoint/restart to compile even
    without CONFIG_CHECKPOINT
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    
    NOTE: Marked [RFC] because it strangely does not pass my adapted LTP
    	test cases unless it's running from a checkpointed image.
    	Seems to be a mistake in the test case adaptation.

commit ddc2e0182fd6a0a3c472511d70bf7ad53adc36bd
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Oct 26 20:30:58 2009 -0400

    c/r: update documentation
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 27c330128468149a9cf72bd2c357c64f10f3b708
Author: Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Oct 26 17:10:33 2009 -0400

    Fix a typo in Documentation/checkpoint/readme.txt
    
    Fix a typo in Documentation/checkpoint/readme.txt
    
    Signed-off-by: Liu Aleaxander <Aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

commit 90c3bb2299d31ec2674ebc8b395b7e8e316f26e5
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Oct 26 17:10:32 2009 -0400

    c/r: coordinator to report correct error on restart failure
    
    If restart fails it is usually due to an error for a restoring task,
    which is place in ctx->errno. Then the coordinator wakes up and sees
    an -EINTR.
    
    This patch changes the coordinator's behavior to report the error
    value placed in ctx->errno (if an error occurred) rather than report
    a confusing -EINTR.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 782b028736703077eb5eb49275814ceb7ba8c207
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Mon Oct 26 17:10:32 2009 -0400

    c/r: do not hold mmap_sem while checkpointing vma's
    
    This patch modifies the memory checkpoint code to _not_ hold the
    mmap_sem while dumping out the vma's.
    
    The problem with holding the mmap_sem is that it first takes the
    mmap_sem and then takes the file's inode semaphore. This violates the
    normal locking order, e,g, when taking a page fault during a copyout,
    which is inode sem and then the mmap_sem.
    
    Normally this reverse locking order won't cause a lockup because a the
    output file for the checkpoint image isn't used by the checkpointee.
    However, there a couple of cases where it may be a problem, e.g. when
    some async-IO happens to complete and triggers a page fault at the
    wrong time.
    
    This fixes complaints from the lockdep about this reverse ordering.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 0b793d1e4e3cb68ef0640ab59db9b71dde5a9ac6
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Oct 25 18:28:04 2009 -0400

    c/r: ckpt_read_buf_type() to accept max payload (excludes ckpt_hdr)
    
    ckpt_read_buf_type() is usually used to read an object originally
    writeen using ckpt_write_obj_type() or derivatives. These accept a
    buffer size, and a record write size+sizeof(ckpt_hdr) long.
    
    This patch makes ckpt_read_buf_type() interpret the @max argument as
    the max payload size (ckpt_hdr excluded).
    
    Nice symmetry between checkpoint and restart - both use same size.
    (Previously, using the same size was a bug, and this occurs in two
    instances - reading a filename, and reading groupinfo).
    
    Original report and patch by Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit e57f0b4bb8daf82c15a99095ecf38cb7383fae08
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Sun Oct 25 18:28:03 2009 -0400

    c/r: ensure null-termination of file names read from image
    
    Don't rely on the checkpoint image to properly terminate the filename
    (similar to ckpt_read_string).
    
    Original report and patch by Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit cdcf6fb28deb49c1c6894ffcc69f3d6ba7143c45
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Sun Oct 25 18:28:03 2009 -0400

    epoll: Add support for restoring many epoll items
    
    This completes the work necessary to make checkpoint/restart of
    thousands of epoll items more reliable when higher order kmallocs
    would fail. We grab a piece of memory suitable to store a "chunk"
    of items for input. Read the input one chunk at a time and add
    epoll items for each item in the chunk.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3e2a0222bd4fb4e2ec1832067fa0b0a34fee2508
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 20:35:31 2009 -0400

    epoll: Add support for checkpointing large numbers of epoll items
    
    Currently we allocate memory to output all of the epoll items in one
    big chunk. At 20 bytes per item, and since epoll was designed to
    support on the order of 10,000 items, we may find ourselves kmalloc'ing
    200,000 bytes. That's an order 7 allocation whereas the heuristic for
    difficult allocations, PAGE_ALLOC_COST_ORDER, is 3.
    
    Instead, output the epoll header and items separately. Chunk the output
    much like the pid array gets chunked. This ensures that even sub-order 0
    allocations will enable checkpoint of large epoll sets. A subsequent
    patch will do something similar for the restore path.
    
    [Oren Laadan] Fix the chunk size instead of auto-tune
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit eb0d0fcb9773e39196279d70aa6cd33175f6490d
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 20:16:17 2009 -0400

    Checkpoint/restart epoll sets
    
    Save/restore epoll items during checkpoint/restart respectively.
    kmalloc failures should be dealt with more kindly than just error-out
    because epoll is made to poll many thousands of file descriptors.
    Subsequent patches will change epoll c/r to "chunk" its output/input
    respectively.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    
    Changelog:
    
    [Oren Laadan] Return -EBUSY (not BUG_ON) if fd is gone on restart
    
    v5:
    	Fix potential recursion during collect.
    	Replace call to ckpt_obj_collect() with ckpt_collect_file().
    		[Oren]
    	Fix checkpoint leak detection when there are more items than
    		expected.
    	Cleanup/simplify error write paths. (will complicate in a later
    		patch) [Oren]
    	Remove files_deferq bits. [Oren]
    	Remove extra newline. [Oren]
    	Remove aggregate check on number of watches added. [Oren]
    		This is OK since these will be done individually anyway.
    	Remove check for negative objrefs during restart. [Oren]
    	Fixup comment regarding race that indicates checkpoint leaks.
    		[Oren]
    	s/ckpt_read_obj/ckpt_read_buf_type/ [Oren]
    		Patch for lots of epoll items follows.
    	Moved sys_close(epfd) right under fget(). [Oren]
    	Use CKPT_HDR_BUFFER rather than custome ckpt_read/write_*
    		This makes it more similar to the pid array code. [Oren]
    		It also simplifies the error recovery paths.
    	Tested polling a pipe and 50,000 UNIX sockets.
    
    v4:	ckpt-v18
    	Use files_deferq as submitted by Dan Smith
    		Cleanup to only report >= 1 items when debugging.
    
    v3: [unposted]
    	Removed most of the TODOs -- the remainder will be removed by
    		subsequent patches.
    	Fixed missing ep_file_collect() [Serge]
    	Rather than include checkpoint_hdr.h declare (but do not define)
    		the two structs needed in eventpoll.h [Oren]
    	Complain with ckpt_write_err() when we detect checkpoint obj
    		leaks. [Oren]
    	Remove redundant is_epoll_file() check in collect. [Oren]
    	Move epfile_objref lookup to simplify error handling. [Oren]
    	Simplify error handling with early return in
    		ep_eventpoll_checkpoint(). [Oren]
    	Cleaned up a comment. [Oren]
    	Shorten CKPT_HDR_FILE_EPOLL_ITEMS (-FILE) [Oren]
    		Renumbered to indicate that it follows the file table.
    	Renamed the epoll struct in checkpoint_hdr.h [Oren]
    		Also renamed substruct.
    	Fixup return of empty ep_file_restore(). [Oren]
    	Changed some error returns. [Oren]
    	Changed some tests to BUG_ON(). [Oren]
    	Factored out watch insert with epoll_ctl() into do_epoll_ctl().
    		[Cedric, Oren]
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 0281537867abbff0b2fddd62945dd66df0a509ab
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 14:55:14 2009 -0400

    ipc_ind_to_str unused if !CONFIG_CHECKPOINT_DEBUG
    
    (compilation cleanup on top of
    	fix-compile-with-CONFIG_CHECKPOINT_DEBUG-n.patch
    )
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit c98f0ecec7bb88c6ead0a7ac6792c8c87ea9a015
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 14:54:09 2009 -0400

    fix compile with CONFIG_CHECKPOINT_DEBUG=n
    
    On the one hand, compiling without checkpoing debug saves a
    lot of kernel size:
    
    with debug:
    -rwxrwxr-x  1 hallyn hallyn  62391508 Oct 21 22:08 vmlinux
    without debug:
    -rwxrwxr-x  1 hallyn hallyn  62298077 Oct 21 22:33 vmlinux
    
    OTOH the need for this patch just proves my point that we don't
    want any more config options than we need (especially no
    CONFIG_CHECKPOINT_LOGGING in addition to _DEBUG).
    
    So that begs the question - is there something we can do to
    avoid having to recompile the kernel to turn on debugging,
    but not take up 100k of space in vmlinux?  Maybe get rid of
    the ckpt_debugs altogether and instead provide pre-written
    kprobe sets to turn on debugging at specific places?
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit de65dad23dd4f32df9c073c8261000e1c515b999
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 14:45:13 2009 -0400

    Fix total byte read/write count for large checkpoint images
    
    Though currently unused, total relies on checkpoint images being less
    than 2GB. Since we've had 64-bit archs and LARGEFILE support for some
    time it's not totally unreasonable to make this a 64-bit quantity.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 8510e48fda09b2246f1dc028cf887a36be20db81
Author: \"Serge E. Hallyn\ <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Oct 23 14:24:08 2009 -0400

    test_and_set_bit returns oldval
    
    ckpt_set_ctx_error() was not setting ctx->errno when it should - it
    apparently thought that test_and_set_bit(x,y) would return 1 if the
    set_bit succeeded?
    
    Fix ckpt_set_ctx_error() to set ctx->errno the first (and only the
    first) time that CKPT_CTX_ERROR gets set in ctx->kflags.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 47cd8119e3d861be46eb029d1c9b81c7684a2030
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Oct 20 16:46:10 2009 -0400

    Pass the stored sock->protocol into sock_create() on restore
    
    This should be fine because the protocol sanity-checks the number to
    make sure it's valid given the type specified.
    
    Cc: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 Documentation/checkpoint/checkpoint.c      |    9 +-
 Documentation/checkpoint/checkpoint_self.c |   57 -----
 Documentation/checkpoint/readme.txt        |    2 +-
 Documentation/checkpoint/restart_self.c    |   20 --
 Documentation/checkpoint/self_checkpoint.c |   69 ++++++
 Documentation/checkpoint/self_restart.c    |   40 ++++
 Documentation/checkpoint/test.c            |   48 ----
 Documentation/checkpoint/usage.txt         |    7 +-
 checkpoint/files.c                         |   27 ++-
 checkpoint/memory.c                        |  133 ++++++++----
 checkpoint/restart.c                       |   46 +++-
 fs/eventfd.c                               |   56 +++++
 fs/eventpoll.c                             |  336 +++++++++++++++++++++++++---
 include/linux/checkpoint_hdr.h             |   26 +++
 include/linux/checkpoint_types.h           |    2 +-
 include/linux/eventfd.h                    |   12 +
 include/linux/eventpoll.h                  |   17 ++-
 ipc/checkpoint.c                           |    2 +
 net/checkpoint.c                           |    3 +-
 19 files changed, 693 insertions(+), 219 deletions(-)
 delete mode 100644 Documentation/checkpoint/checkpoint_self.c
 delete mode 100644 Documentation/checkpoint/restart_self.c
 create mode 100644 Documentation/checkpoint/self_checkpoint.c
 create mode 100644 Documentation/checkpoint/self_restart.c
 delete mode 100644 Documentation/checkpoint/test.c


hooks/post-receive
--
linux-cr
