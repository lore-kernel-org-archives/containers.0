From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 00/29] Kernel based checkpoint/restart
Date: Tue, 31 Mar 2009 01:28:40 -0400
Message-ID: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint-restart (c/r): two major changes are support for PPC arch
(by Nathan Lunch) and first part of refactoring file-checkpoint to use
f_ops (file operations). Tested against kernel v2.6.29-rc8 on x86_32.
Requires update of userspace tools too.

The git tree tracking v14-rc2, branch 'ckpt-v14-rc2' (and past versions):
	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

Restarting multiple processes requires 'mktree' userspace tool with
the matching branch (v14-rc2):
	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git

Oren.


Changelog:

[2009-Mar-31] v14-rc2
  - Change along Dave's suggestion to use f_ops->checkpoint() for files
  - Merge patch simplifying Kconfig, with CONFIG_CHECKPOINT_SUPPORT
  - Merge support for PPC arch (Nathan Lynch)
  - Misc cleanups and fixes in response to comments

[2009-Mar-20] v14-rc1:
  - The 'h.parent' field of 'struct cr_hdr' isn't used - discard
  - Check whether calls to cr_hbuf_get() succeed or fail.
  - Fixed of pipe c/r code
  - Prevent deadlock by refusing c/r when a pipe inode == ctx->file inode
  - Refuse non-self checkpoint if a task isn't frozen
  - Use unsigned fields in checkpoint headers unless otherwise required
  - Rename functions in files c/r to better reflect their role
  - Add support for anonymous shared memory
  - Merge support for s390 arch (Dan Smith, Serge Hallyn)
    
[2008-Dec-03] v13:
  - Cleanups of 'struct cr_ctx' - remove unused fields
  - Misc fixes for comments
  
[2008-Dec-17] v12:
  - Fix re-alloc/reset of pgarr chain to correctly reuse buffers
    (empty pgarr are saves in a separate pool chain)
  - Add a couple of missed calls to cr_hbuf_put()
  - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
  - Split cr_write/cr_read() to two parts: _cr_write/read() helper
  - Befriend with sparse: explicit conversion to 'void __user *'
  - Redrefine 'pr_fmt' ind replace cr_debug() with pr_debug()

[2008-Dec-05] v11:
  - Use contents of 'init->fs->root' instead of pointing to it
  - Ignore symlinks (there is no such thing as an open symlink)
  - cr_scan_fds() retries from scratch if it hits size limits
  - Add missing test for VM_MAYSHARE when dumping memory
  - Improve documentation about: behavior when tasks aren't fronen,
    life span of the object hash, references to objects in the hash
 
[2008-Nov-26] v10:
  - Grab vfs root of container init, rather than current process
  - Acquire dcache_lock around call to __d_path() in cr_fill_name()
  - Force end-of-string in cr_read_string() (fix possible DoS)
  - Introduce cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()

[2008-Nov-10] v9:
  - Support multiple processes c/r
  - Extend checkpoint header with archtiecture dependent header 
  - Misc bug fixes (see individual changelogs)
  - Rebase to v2.6.28-rc3.

[2008-Oct-29] v8:
  - Support "external" checkpoint
  - Include Dave Hansen's 'deny-checkpoint' patch
  - Split docs in Documentation/checkpoint/..., and improve contents

[2008-Oct-17] v7:
  - Fix save/restore state of FPU
  - Fix argument given to kunmap_atomic() in memory dump/restore

[2008-Oct-07] v6:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)
  - Add assumptions and what's-missing to documentation
  - Misc fixes and cleanups

[2008-Sep-11] v5:
  - Config is now 'def_bool n' by default
  - Improve memory dump/restore code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Fix use of follow_page() to avoid faulting in non-present pages
  - Memory restore now maps user pages explicitly to copy data into them,
    instead of reading directly to user space; got rid of mprotect_fixup()
  - Remove preempt_disable() when restoring debug registers
  - Rename headers files s/ckpt/checkpoint/
  - Fix misc bugs in files dump/restore
  - Fixes and cleanups on some error paths
  - Fix misc coding style

[2008-Sep-09] v4:
  - Various fixes and clean-ups
  - Fix calculation of hash table size
  - Fix header structure alignment
  - Use stand list_... for cr_pgarr

[2008-Aug-29] v3:
  - Various fixes and clean-ups
  - Use standard hlist_... for hash table
  - Better use of standard kmalloc/kfree

[2008-Aug-20] v2:
  - Added Dump and restore of open files (regular and directories)
  - Added basic handling of shared objects, and improve handling of
    'parent tag' concept
  - Added documentation
  - Improved ABI, 64bit padding for image data
  - Improved locking when saving/restoring memory
  - Added UTS information to header (release, version, machine)
  - Cleanup extraction of filename from a file pointer
  - Refactor to allow easier reviewing
  - Remove requirement for CAPS_SYS_ADMIN until we come up with a
    security policy (this means that file restore may fail)
  - Other cleanup and response to comments for v1

[2008-Jul-29] v1:
  - Initial version: support a single task with address space of only
    private anonymous or file-mapped VMAs; syscalls ignore pid/crid
    argument and act on current process.

--
At the containers mini-conference before OLS, the consensus among
all the stakeholders was that doing checkpoint/restart in the kernel
as much as possible was the best approach.  With this approach, the
kernel will export a relatively opaque 'blob' of data to userspace
which can then be handed to the new kernel at restore time.

This is different than what had been proposed before, which was
that a userspace application would be responsible for collecting
all of this data.  We were also planning on adding lots of new,
little kernel interfaces for all of the things that needed
checkpointing.  This unites those into a single, grand interface.

The 'blob' will contain copies of select portions of kernel
structures such as vmas and mm_structs.  It will also contain
copies of the actual memory that the process uses.  Any changes
in this blob's format between kernel revisions can be handled by
an in-userspace conversion program.

This is a similar approach to virtually all of the commercial
checkpoint/restart products out there, as well as the research
project Zap.

These patches basically serialize internel kernel state and write
it out to a file descriptor.  The checkpoint and restore are done
with two new system calls: sys_checkpoint and sys_restart.

In this incarnation, they can only work checkpoint and restore a
single task. The task's address space may consist of only private,
simple vma's - anonymous or file-mapped. The open files may consist
of only simple files and directories.
--
