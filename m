From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Wed, 29 Apr 2009 10:18:17 +0200
Message-ID: <20090429081815.GA1813@hawkmoon.kerlabs.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6415537879588039526=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6415537879588039526==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-26938-1240993084-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-26938-1240993084-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On 28/04/09 19:23 -0400, Oren Laadan wrote:
> Here is the latest and greatest of checkpoint/restart (c/r) patchset.
> The logic and image format reworked and simplified, code refactored,
> support for PPC, s390, sysvipc, shared memory of all sorts, namespaces
> (uts and ipc).

I should have asked before, but what are the reasons to checkpoint SYSV IPCs
in the same file/stream as tasks? Would it be better to checkpoint them
independently, like the file system state?

In Kerrighed we chose to checkpoint SYSV IPCs independently, a bit like the=
 file
system state, because SYSV IPCs objects' lifetime do not depend on tasks
lifetime, and we can gain more flexibility this way. In particular we envis=
ion
cases in which two applications share a state in a SYSV SHM (something like=
 a
producer-consumer scheme), but do not need to be checkpointed together. In =
such
a case the SYSV SHM itself could even need more high-availability (using
active replication) than a checkpoint/restart facility.

Louis


> The userspace tool 'mktree' was extended to handle more complicated
> process tree and correctly account for process relationships and=20
> session ID (sid). Should correctly handle threads.
> Hey, it even went through some massive renaming of files and functions...
>=20
> Signals and timers are not supported yet, so programs that rely on
> their behavior may fail to oeprate correctly after a restart (e.g.
> may lose signals pending at time of checkpoint, and so on).
>=20
> However, this one can actually be used for simple batch jobs (pipes,
> too), a whole container or just a subtree of tasks. Try it:
>=20
> create the freezer cgroup:
>   $ mount -t cgroup -ofreezer freezer /freezer
>   $ mkdir /freezer/0
>=20
> run the test, freeze it: =20
>   $ test/multitask &
>   [1] 2754
>   $ for i in `pidof multitask`; do echo $i > /freezer/0/tasks; done
>   $ echo FROZEN > /freezer/0/freezer.state
>=20
> checkpoint:
>   $ ./ckpt 2754 > ckpt.out
>=20
> restart:
>   $ ./mktree < ckpt.out
>=20
> voila :)
>=20
> To do all this, you'll need:
>=20
> The git tree tracking v14, branch 'ckpt-v14' (and past versions):
> 	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
>=20
> Restarting multiple processes requires 'mktree' userspace tool with
> the matching branch (v14):
> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
>=20
>=20
> Oren.
>=20
>=20
> Changelog:
>=20
> [2009-Apr-28] v14
>   - Tested against kernel v2.6.30-rc3 on x86_32.
>   - Refactor files chekpoint to use f_ops (file operations)
>   - Refactor mm/vma to use vma_ops
>   - Explicitly handle VDSO vma (and require compat mode)
>   - Added code to c/r restat-blocks (restart timeout related syscalls)
>   - Added code to c/r namespaces: uts, ipc (with Dan Smith)
>   - Added code to c/r sysvipc (shm, msg, sem)
>   - Support for VM_CLONE shared memory
>   - Added resource leak detection for whole-container checkpoint
>   - Added sysctl gauge to allow unprivileged restart/checkpoint
>   - Improve and simplify the code and logic of shared objects
>   - Rework image format: shared objects appear prior to their use
>   - Merge checkpoint and restart functionality into same files
>   - Massive renaming of functions: prefix "ckpt_" for generics,
>     "checkpoint_" for checkpoint, and "restore_" for restart.
>   - Report checkpoint errors as a valid (string record) in the output
>   - Merged PPC architecture (by Nathan Lunch),
>   - Requires updates to userspace tools too.
>   - Misc nits and bug fixes
>=20
> [2009-Mar-31] v14-rc2
>   - Change along Dave's suggestion to use f_ops->checkpoint() for files
>   - Merge patch simplifying Kconfig, with CONFIG_CHECKPOINT_SUPPORT
>   - Merge support for PPC arch (Nathan Lynch)
>   - Misc cleanups and fixes in response to comments
>=20
> [2009-Mar-20] v14-rc1:
>   - The 'h.parent' field of 'struct cr_hdr' isn't used - discard
>   - Check whether calls to cr_hbuf_get() succeed or fail.
>   - Fixed of pipe c/r code
>   - Prevent deadlock by refusing c/r when a pipe inode =3D=3D ctx->file i=
node
>   - Refuse non-self checkpoint if a task isn't frozen
>   - Use unsigned fields in checkpoint headers unless otherwise required
>   - Rename functions in files c/r to better reflect their role
>   - Add support for anonymous shared memory
>   - Merge support for s390 arch (Dan Smith, Serge Hallyn)
>    =20
> [2008-Dec-03] v13:
>   - Cleanups of 'struct cr_ctx' - remove unused fields
>   - Misc fixes for comments
>  =20
> [2008-Dec-17] v12:
>   - Fix re-alloc/reset of pgarr chain to correctly reuse buffers
>     (empty pgarr are saves in a separate pool chain)
>   - Add a couple of missed calls to cr_hbuf_put()
>   - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
>   - Split cr_write/cr_read() to two parts: _cr_write/read() helper
>   - Befriend with sparse: explicit conversion to 'void __user *'
>   - Redrefine 'pr_fmt' ind replace cr_debug() with pr_debug()
>=20
> [2008-Dec-05] v11:
>   - Use contents of 'init->fs->root' instead of pointing to it
>   - Ignore symlinks (there is no such thing as an open symlink)
>   - cr_scan_fds() retries from scratch if it hits size limits
>   - Add missing test for VM_MAYSHARE when dumping memory
>   - Improve documentation about: behavior when tasks aren't fronen,
>     life span of the object hash, references to objects in the hash
> =20
> [2008-Nov-26] v10:
>   - Grab vfs root of container init, rather than current process
>   - Acquire dcache_lock around call to __d_path() in cr_fill_name()
>   - Force end-of-string in cr_read_string() (fix possible DoS)
>   - Introduce cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()
>=20
> [2008-Nov-10] v9:
>   - Support multiple processes c/r
>   - Extend checkpoint header with archtiecture dependent header=20
>   - Misc bug fixes (see individual changelogs)
>   - Rebase to v2.6.28-rc3.
>=20
> [2008-Oct-29] v8:
>   - Support "external" checkpoint
>   - Include Dave Hansen's 'deny-checkpoint' patch
>   - Split docs in Documentation/checkpoint/..., and improve contents
>=20
> [2008-Oct-17] v7:
>   - Fix save/restore state of FPU
>   - Fix argument given to kunmap_atomic() in memory dump/restore
>=20
> [2008-Oct-07] v6:
>   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
>     (even though it's not really needed)
>   - Add assumptions and what's-missing to documentation
>   - Misc fixes and cleanups
>=20
> [2008-Sep-11] v5:
>   - Config is now 'def_bool n' by default
>   - Improve memory dump/restore code (following Dave Hansen's comments)
>   - Change dump format (and code) to allow chunks of <vaddrs, pages>
>     instead of one long list of each
>   - Fix use of follow_page() to avoid faulting in non-present pages
>   - Memory restore now maps user pages explicitly to copy data into them,
>     instead of reading directly to user space; got rid of mprotect_fixup()
>   - Remove preempt_disable() when restoring debug registers
>   - Rename headers files s/ckpt/checkpoint/
>   - Fix misc bugs in files dump/restore
>   - Fixes and cleanups on some error paths
>   - Fix misc coding style
>=20
> [2008-Sep-09] v4:
>   - Various fixes and clean-ups
>   - Fix calculation of hash table size
>   - Fix header structure alignment
>   - Use stand list_... for cr_pgarr
>=20
> [2008-Aug-29] v3:
>   - Various fixes and clean-ups
>   - Use standard hlist_... for hash table
>   - Better use of standard kmalloc/kfree
>=20
> [2008-Aug-20] v2:
>   - Added Dump and restore of open files (regular and directories)
>   - Added basic handling of shared objects, and improve handling of
>     'parent tag' concept
>   - Added documentation
>   - Improved ABI, 64bit padding for image data
>   - Improved locking when saving/restoring memory
>   - Added UTS information to header (release, version, machine)
>   - Cleanup extraction of filename from a file pointer
>   - Refactor to allow easier reviewing
>   - Remove requirement for CAPS_SYS_ADMIN until we come up with a
>     security policy (this means that file restore may fail)
>   - Other cleanup and response to comments for v1
>=20
> [2008-Jul-29] v1:
>   - Initial version: support a single task with address space of only
>     private anonymous or file-mapped VMAs; syscalls ignore pid/crid
>     argument and act on current process.
>=20
> --
> At the containers mini-conference before OLS, the consensus among
> all the stakeholders was that doing checkpoint/restart in the kernel
> as much as possible was the best approach.  With this approach, the
> kernel will export a relatively opaque 'blob' of data to userspace
> which can then be handed to the new kernel at restore time.
>=20
> This is different than what had been proposed before, which was
> that a userspace application would be responsible for collecting
> all of this data.  We were also planning on adding lots of new,
> little kernel interfaces for all of the things that needed
> checkpointing.  This unites those into a single, grand interface.
>=20
> The 'blob' will contain copies of select portions of kernel
> structures such as vmas and mm_structs.  It will also contain
> copies of the actual memory that the process uses.  Any changes
> in this blob's format between kernel revisions can be handled by
> an in-userspace conversion program.
>=20
> This is a similar approach to virtually all of the commercial
> checkpoint/restart products out there, as well as the research
> project Zap.
>=20
> These patches basically serialize internel kernel state and write
> it out to a file descriptor.  The checkpoint and restore are done
> with two new system calls: sys_checkpoint and sys_restart.
>=20
> In this incarnation, they can only work checkpoint and restore a
> single task. The task's address space may consist of only private,
> simple vma's - anonymous or file-mapped. The open files may consist
> of only simple files and directories.
> --
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-26938-1240993084-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJ+A1HVKcRuvQ9Q1QRAoTaAJ0cPVob1D3KKOROJJtRwXoRG5ya8ACfTb8p
35fno8/89gh444Q3U84QUaU=
=Sqpc
-----END PGP SIGNATURE-----

--=_bohort-26938-1240993084-0001-2--

--===============6415537879588039526==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6415537879588039526==--
