From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v17-dev,
	updated. v2.6.27-rc5-46174-g44430da
Date: Tue, 4 Aug 2009 04:19:39 -0400
Message-ID: <200908040819.n748JdW9019915@gorgona.ncl.cs.columbia.edu>
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
       via  44430daae5d6be37c9e225206d9713aed0163468 (commit)
       via  0cb308dd6e2fceda822b8e5b3d4e8e120b6e7801 (commit)
       via  d8d04307254687455d2143aa08211b0b7561792b (commit)
       via  745c1777d918d1b5122eea45080bdaa10cd76bbe (commit)
       via  a9195b06019720df97239d6d5b4743cc0dc97bae (commit)
       via  242cd86adb1ad768566201bac8064ca07e2e1c47 (commit)
       via  1d00ba8cd00591f0f9b1b6f27fce6d5e0dc9f30e (commit)
      from  ad692e8eeadca96a94655d4256d1d93be92ecd40 (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 44430daae5d6be37c9e225206d9713aed0163468
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 4 04:06:24 2009 -0400

    c/r: checkpoint and restore FIFOs
    
    FIFOs are almost like pipes.
    
    Checkpoints adds the FIFO pathname. The first time the FIFO is found
    it also assigns an @objref and dumps the contents in the buffers.
    
    To restore, use the @objref only to determine whether a particular
    FIFO has already been restored earlier. Note that it ignores the file
    pointer that matches that @objref (unlike with pipes, where that file
    corresponds to the other end of the pipe). Instead, it creates a new
    FIFO using the saved pathname.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 0cb308dd6e2fceda822b8e5b3d4e8e120b6e7801
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 4 04:05:11 2009 -0400

    c/r: [leaks 3/3]: collect files references by shared memory
    
    We only checkpoint the vma->vm_file of mapped shared memory, but
    not anonymous shared memory and sysvipc shm. Therefore, we need
    to call ckpt_obj_visit() to mark them as visited to prevent leak
    detection from noticing a reverse-leak.
    
    Also, sysvipc objects point to the respective file (of shmem). The
    patch ensures that it is collected and that it is later visited.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit d8d04307254687455d2143aa08211b0b7561792b
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 4 03:57:24 2009 -0400

    c/r: leaks[2/3]: introduce '->collect()' in 'struct file_operations'
    
    Leak detection for full-container checkpoint ensures that shared
    objects used in it are not referenced outside it. It is performed by
    'collecting' all references to shared objects in the container, and
    comparing the counts to the objects' reference counts.
    
    For some file types, a file pointer may hold references other shared
    objects, e.g. a pty file points to the master and slave ttys, and a
    event-poll file points to the files that it monitors. For these, the
    collect operation should account for the referenced objets objects
    too.
    
    This patch adds a new 'file_operations' function to collect files, but
    only when it collected for the first time.  All but a few file types
    need to implement this method.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 745c1777d918d1b5122eea45080bdaa10cd76bbe
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 4 03:57:06 2009 -0400

    c/r: leaks [1/3]: simplify collect of file_table and memory
    
    Shared objects like mm and file-table are "nested" in the sense that
    they themselves point to shared objects (files, in this case). When
    collecting them for the first time, the objects to which they refer
    need to be collected, too (otherwise, not).
    
    This patch simplifies logic of collect_file_table() and collect_mm()
    by changing ckpt_obj_collect() to return the objref on the first time,
    and 0 otherwise.
    
    This rids the need to explicitly call ckpt_obj_lookup() to figure out
    if an object is encountered for the first time.
    
    Also, if checkpoint is parallelized in the future, this prevents a
    race between the call to ckpt_obj_lookup() to ckpt_obj_collect(). In
    contrast, ckpt_obj_collect() can easily be made atomic.
    
    The patch also introduces a new object flag CKPT_OBJ_VISITED that is
    used in the reverse leaks test instead of CKPT_OBJ_CHECKPOINTED.
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit a9195b06019720df97239d6d5b4743cc0dc97bae
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Aug 4 02:01:19 2009 -0400

    c/r: remove unneeded {checkpoint,restore}_bad()
    
    Neither checkpoint_bad() nor restore_bad() are needed:
    
    - It's a kernel bug to call checkpoint_obj() on an object without a
    valid checkpoint() method.
    
    - Input (checkpoint image) that triggers restore_obj() and indicates
    an object type which does not have a valid restore() method, is an
    invalid input.
    
    Handle these directly in checkpoint_obj() and restore_obj().
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

commit 242cd86adb1ad768566201bac8064ca07e2e1c47
Author: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Tue Aug 4 02:01:18 2009 -0400

    c/r: Fix no-dot-config-targets pattern in linux/Makefile
    
    Kernel builds that specify targets in the checkpoint/ directory will
    fail or be incorrect because the autoconfig files were not included.
    One way to reproduce the problem is:
    
    	make checkpoint/sys.s
    
    The problem is that this pattern in linux/Makefile matches files in the
    checkpoint/ directory:
    
    no-dot-config-targets := clean mrproper distclean \
                             cscope TAGS tags help %docs check% \
                             include/linux/version.h headers_% \
                             kernelrelease kernelversion
    
    Make the pattern more exact, per the current set of linux build targets.
    
    Signed-off-by: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

commit 1d00ba8cd00591f0f9b1b6f27fce6d5e0dc9f30e
Author: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Aug 4 01:54:22 2009 -0400

    cr: s390: set return value for self-checkpoint
    
    If doing a self-checkpoint, then optimistically store 0 as the
    syscall return value to indicate success.
    
    This was being done for x86, but not yet being done for s390.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 Makefile                       |    2 +-
 arch/s390/mm/checkpoint.c      |   11 ++++
 checkpoint/checkpoint.c        |    4 +-
 checkpoint/files.c             |   31 +++++++++---
 checkpoint/memory.c            |   12 ++---
 checkpoint/objhash.c           |  108 ++++++++++++++++++++++++++-------------
 fs/pipe.c                      |   82 +++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |   16 +++++-
 include/linux/checkpoint_hdr.h |    1 +
 include/linux/fs.h             |    1 +
 include/linux/pipe_fs_i.h      |    2 +
 ipc/checkpoint.c               |   21 ++++++++
 ipc/checkpoint_shm.c           |   23 +++++++-
 ipc/util.h                     |    1 +
 kernel/nsproxy.c               |    8 +++
 mm/shmem.c                     |    7 ++-
 16 files changed, 268 insertions(+), 62 deletions(-)


hooks/post-receive
--
linux-cr
