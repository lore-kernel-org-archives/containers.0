From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] [RFC] Checkpoint/restart unlinked files
Date: Wed, 29 Sep 2010 18:17:11 -0700
Message-ID: <20100930011711.GT23839__6723.14403714171$1285809482$gmane$org@count0.beaverton.ibm.com>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
	<6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<d91e3660266d3a2956c4d1aebc9cb618081b21ef.1285278339.git.matthltc@us.ibm.com>
	<59e9d9fe9db11c6e06ef314541b1112f2b720a59.1285278339.git.matthltc@us.ibm.com>
	<9eade1f1ec10c23dae296feda8af9fe87085e843.1285278339.git.matthltc@us.ibm.com>
	<7da8a050193a91b69ecb3899ce2eda541ecd2473.1285278339.git.matthltc@us.ibm.com>
	<4CA3BC2D.8010001@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CA3BC2D.8010001-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Aneesh Kumar <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

[ Persistent readers may wish to grab some coffee because this is gonna be
  a long reply. ]

On Wed, Sep 29, 2010 at 06:22:37PM -0400, Oren Laadan wrote:
> 
> On 09/23/2010 05:53 PM, Matt Helsley wrote:
> >Implement checkpoint of unlinked files by relinking them into their
> >filesystem at lost+found/checkpoint/unlink-at-restart-<ktime>-<N>.
> >We can change the function to generate better paths -- I just need to
> >know what that path should be. For example, perhaps sys_checkpoint should
> >take a template string somewhat like mkstemp().
> 
> /lost+found/checkpoint/.... relative to what ?

The root of the mounted filesystem. Not the root of the mount namespace nor
The Root Filesystem. Using that "root" ensures that it stays in the
filesystem and we won't get EXDEV.

> security concerns ?

It occurs to me that the checkpointing user may not have permission to
add entries there so checkpoint may fail because of that. And if they do
have permission to create entries there then it could be a means to
hardlink files and pin quota (just like any time you can hardlink
visible files that other users own: http://pastebin.com/RybskyyY ). :(

> 
> >Relinking allows userspace to leverage the snapshotting capabilities
> >of various linux block devices and filesystems. sys_checkpoint relinks
> >the files and returns. Userspace then checkpoints the filesystem contents
> >using any backup-like method prior to thawing. That backup would then be
> >available for use during an optional migration followed by restore and
> >restart. In the case of network and cluster/distributed filesystems copying
> >the filesystem contents explicitly for migration may not be necessary at
> >all -- it would be part of normal file writes. For non-migration uses
> >of checkpoint/restart filesystems like btrfs a snapshot could simply be
> >taken during checkpoint and mounted during restart -- again without
> >requiring IO proportional to the aggregate size of filesystem contents
> >being checkpointed.
> >
> >In addition to the original path of the file we save the newly-linked
> >path. This newly-linked path is opened during restart instead of the
> >original path (which is only useful files that were linked at the time
> >of checkpoint). The newly-linked location is also useful in order to
> >identify which relinked files in lost+found/checkpoint were created by
> >this particular invokation of sys_checkpoint. This enables userspace
> 
> s/invokation/invocation/

Argh, yes. :)

> 
> >to cleanup after checkpoints which failed yet successfully relinked.
> >
> >Note that we'd still be restricted by the limitations of hardlinks.
> >Furthermore, as Aneesh Kumar mentioned in the LKML threads leading up to
> >the v19 file handle patches, this kind of linking seems to require
> >CAP_DAC_READ_SEARCH because the files to be linked lack a path to
> >search in the first place. Aneesh added the check in response to Al Viro's
> >point that being able to relink open files (passed via SCM_RIGHTS for
> >example) has non-trivial security ramifications.
> >
> >To understand why relinking is extremely useful for checkpoint/restart
> >consider this simple pseudocode program and a specific example checkpoint
> >of it:
> >
> >	a_fd = open("a"); /* example: size of the file at "a" is 1GB */
> >	link("a", "b");
> >	unlink("a");
> >	creat("a");
> >	<---- example: checkpoint happens here
> >	write(a_fd, "bar");
> >
> >The file "a" is unlinked and a different file has been placed at that
> >path. a_fd still refers to the inode shared with "b".
> >
> >Without relinking we would need to walk the entire filesystem to find out
> >that "b" is a path to the same inode (another variation on this case: "b"
> >would also have been unlinked). We'd need to do this for every
> >unlinked file that remains open in every task to checkpoint. Even then
> >there is no guarantee such a "b" exists for every unlinked file -- the
> >inodes could be "orphans" -- and we'd need to preserve their contents
> >some other way.
> >
> >I considered a couple alternatives to preserving unlinked file contents:
> >copying and file handles. Each has significant drawbacks.
> >
> >First I attempted to copy the file contents into the image and then
> >recreate and unlink the file during restart. Using a simple version of
> >that method the write above would not reach "b". One fix would be to search
> >the filesystem for a file with the same inode number (inode of "b") and
> >either open it or hardlink it to "a". Another would be to record the inode
> >number. This either shifts the search from checkpoint time to restart time
> >or has all the drawbacks of the second method I considered: file handles.
> 
> Maybe worth to explicitly mention the obvious, just in case:
> 
> Only re-create and unlink the file if at checkpoint time the
> link count was 0 (no other references existed); and do it under
> a temporary name, to not overwrite existing (newer) files.

Yup.
 
> If the link count was greater than 0, then the only correct
> solution is to somehow find the other pathname for the same

Nope. We don't need to find the other pathname so long as we have the
new link.

> inode, make a new temporary link, open the new link, and finally
> unlink the new link.

Yup. We make a new temporary link during checkpoint. That link becomes
part of the snapshot/backup saved for restart. During restart we re-open
the link and then unlink it. It should even work with multiple
struct file *'s referring to the same file.

> >
> >Instead of copying contents or recording inodes I also considered using
> >file handles. We'd need to ensure that the filehandles persist in storage,
> >can be snapshotted/backed up, and can be migrated. Can handlefs or any
> >generic file handle system do this? My _guess_ is "no" but folks are
> >welcome to tell me I'm wrong.
> >
> >In contrast, linking the file from a_fd back into its filesystem can avoid
> >these complexities. Relinking avoids the search for matching inodes and
> >copying large quantities of data from storage only to write it back (in
> >fact the data would be read-and-written twice -- once for checkpoint and
> >once for restart). Like file handles it does require changes to the
> >filesystem code. Unlike file handles, enabling relinking does not require
> >every filesystem to support a new kind of filesystem "object" -- only
> >an operation that is quite similar to one that already exists: link.
> >
> >Signed-off-by: Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >Cc: Eric Sandeen<sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >Cc: Theodore Ts'o<tytso-3s7WtUTddSA@public.gmane.org>
> >Cc: Andreas Dilger<adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
> >Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Cc: Jan Kara<jack-AlSwsSmVLrQ@public.gmane.org>
> >Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> >Cc: Oren Laadan<orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> >Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Cc: Al Viro<viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> >Cc: Christoph Hellwig<hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> >Cc: Jamie Lokier<jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
> >Cc: Amir Goldstein<amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
> >Cc: Aneesh Kumar<aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> >Cc: Miklos Szeredi<miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
> >---
> >  fs/checkpoint.c                  |   51 ++++++++++++++-----
> >  fs/namei.c                       |  102 ++++++++++++++++++++++++++++++++++++++
> >  fs/pipe.c                        |    2 +-
> >  include/linux/checkpoint.h       |    3 +-
> >  include/linux/checkpoint_hdr.h   |    3 +
> >  include/linux/checkpoint_types.h |    3 +
> >  6 files changed, 149 insertions(+), 15 deletions(-)
> >
> >diff --git a/fs/checkpoint.c b/fs/checkpoint.c
> >index 87d7c6e..9c7caec 100644
> >--- a/fs/checkpoint.c
> >+++ b/fs/checkpoint.c
> >@@ -16,6 +16,7 @@
> >  #include<linux/sched.h>
> >  #include<linux/file.h>
> >  #include<linux/namei.h>
> >+#include<linux/mount.h>
> >  #include<linux/fs_struct.h>
> >  #include<linux/fs.h>
> >  #include<linux/fdtable.h>
> >@@ -26,6 +27,7 @@
> >  #include<linux/checkpoint.h>
> >  #include<linux/eventpoll.h>
> >  #include<linux/eventfd.h>
> >+#include<linux/sys-wrapper.h>
> >  #include<net/sock.h>
> >
> >  /**************************************************************************
> >@@ -174,6 +176,9 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
> >  	h->f_pos = file->f_pos;
> >  	h->f_version = file->f_version;
> >
> >+	if (d_unlinked(file->f_dentry))
> >+		/* Perform post-checkpoint and post-restart unlink() */
> >+		h->f_restart_flags |= RESTART_FILE_F_UNLINK;
> 
> Follow the convention for these ?  s/RESTART_.../CKPT_.../

I'll prefix it with CKPT_RESTART_ since "RESTART_" is kind of essential for
conveying the purpose of the flag -- it indicates that we should unlink
the file at restart.

> 
> >  	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
> >  	if (h->f_credref<  0)
> >  		return h->f_credref;
> >@@ -197,16 +202,6 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> >  	struct ckpt_hdr_file_generic *h;
> >  	int ret;
> >
> >-	/*
> >-	 * FIXME: when we'll add support for unlinked files/dirs, we'll
> >-	 * need to distinguish between unlinked filed and unlinked dirs.
> >-	 */
> >-	if (d_unlinked(file->f_dentry)) {
> >-		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
> >-			 file);
> >-		return -EBADF;
> >-	}
> 
> We still need to handle unlinked directories separately (see
> below). And they are actually easier to handle. So you probably
> also need a flag to indicate that it is a directory.
> 
> Perhaps rename flag from above, e.g.:
>   CKPT_FILE_UNLINKED_FILE
>   CKPT_FILE_UNLINKED_DIR

I did't think we needed to. When I looked at the code I figured it should
handle them just fine. That said, I don't have a testcase for relinking
them.

They're relatively simple because unlinked directories must be empty. We're
essentially saving the filesystem permission, owner/group, acls, and xattrs
of the directory for use during restart by relinking it.

> >-
> >  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> >  	if (!h)
> >  		return -ENOMEM;
> >@@ -220,6 +215,9 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> >  	if (ret<  0)
> >  		goto out;
> >  	ret = checkpoint_fname(ctx,&file->f_path,&ctx->root_fs_path);
> >+	if (ret<  0)
> >+		goto out;
> >+	ret = checkpoint_file_links(ctx, file);
> >   out:
> >  	ckpt_hdr_put(ctx, h);
> >  	return ret;
> >@@ -570,9 +568,11 @@ static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
> >  /**
> >   * restore_open_fname - read a file name and open a file
> >   * @ctx: checkpoint context
> >+ * @restore_unlinked: unlink the opened file
> 
> nit: s/restore_unlinked/unlinked/   ?

I'd rather rename it do_unlink since that's the meaning the paremeter
is meant to convey. Though that name could easily shadow a future
syscall helper which may be useful...

> 
> >   * @flags: file flags
> >   */
> >-struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
> >+struct file *restore_open_fname(struct ckpt_ctx *ctx,
> >+				int restore_unlinked, int flags)
> >  {
> >  	struct file *file;
> >  	char *fname;
> >@@ -586,8 +586,33 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
> >  	if (len<  0)
> >  		return ERR_PTR(len);
> >  	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
> >-
> >+	if (restore_unlinked) {
> >+		kfree(fname);
> 
> This is too early to discard the original name (why would we
> have saved it in the first place anyway ?) because ...

Hmm.

> 
> >+		fname = NULL;
> >+		len = ckpt_read_payload(ctx, (void **)&fname, PATH_MAX,
> >+					CKPT_HDR_BUFFER);
> >+		if (len<  0)
> >+			return ERR_PTR(len);
> >+		fname[len] = '\0';
> >+	}
> 
> Uhm... for the following to work you need to explicitly handle
> the case of unlinked directory:
> 
> 	if (restore_unlinked & CKPT_FILE_UNLINKED_DIR)
> 		mkdir(...);

A simple mkdir is insufficient as I pointed out above. We need the
associated owner, group, permissions, xattrs, and acls to faithfully
re-create the directory. Again, I *think* the code as it is handles
all that properly and without extra fuss. I'll review the code to be
sure and write a new test to make extra sure.

> 
> >  	file = filp_open(fname, flags, 0);
> >+	if (IS_ERR(file)) {
> >+		ckpt_err(ctx, PTR_ERR(file), "Could not open file \"%s\"\n", fname);
> >+
> >+		goto out;
> >+	}
> >+	if (!restore_unlinked)
> >+		goto out;
> >+	if (S_ISDIR(file->f_mapping->host->i_mode))
> >+		len = kernel_sys_rmdir(fname);
> >+	else
> >+		len = kernel_sys_unlink(fname);
> 
> ... because now you need to manually modify the dentry to have
> the original name, so that doing 'ls -l /proc/PID/fd' will give
>   "NN -> original_name (deleted)"
> rather than
>   "NN -> relinked_obfuscated_name (deleted)"

A decent point. However the problem is worse than you describe since the
path with have changed too.

"manually modifying" the dentry name seems like a terrible hack as far
as organizing the kernel code goes. I'd like to spend some time trying
to think of alternative solutions unless VFS developers care to
weigh in on this with either "It's OK" or "Here's a way to avoid the
hack...".

> >+	if (len<  0) {
> >+		ckpt_err(ctx, len, "Could not unlink \"%s\"\n", fname);
> >+		fput(file);
> >+		file = ERR_PTR(len);
> >+	}
> >+out:
> >  	kfree(fname);
> >
> >  	return file;
> >@@ -692,7 +717,7 @@ static struct file *generic_file_restore(struct ckpt_ctx *ctx,
> >  	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
> >  		return ERR_PTR(-EINVAL);
> >
> >-	file = restore_open_fname(ctx, ptr->f_flags);
> >+	file = restore_open_fname(ctx, !!(ptr->f_restart_flags&  RESTART_FILE_F_UNLINK), ptr->f_flags);
> 
> Now f_restart_flags can have more than one flag, so remove the "!!"
> (and I would rename it to f_ckpt_flags)

That doesn't make sense. Yes, it could have more than one flag. But the
only flag restore_open_fname() is designed to take is the one indicating
that it should unlink the file. We don't know that any flags added in
the future will be relevant to restore_open_fname().

As to the field rename: I disagree. the flags are explicitly there to instruct
"restart" to unlink the file. They aren't "checkpointed file flags" but
"f_ckpt_flags" sounds like some file flags we're saving. The proposed name
also incorrectly implies a redundancy in the data structure. Finally, these
fields are already inside a ckpt_* struct _and_ only used in checkpoint/restart
code. So there's little chance we're going to forget that and need "_ckpt_"
in the field name.

> >  	if (IS_ERR(file))
> >  		return file;
> >
> >diff --git a/fs/namei.c b/fs/namei.c
> >index 8c9663d..69c4f4e 100644
> >--- a/fs/namei.c
> >+++ b/fs/namei.c
> >@@ -32,6 +32,9 @@
> >  #include<linux/fcntl.h>
> >  #include<linux/device_cgroup.h>
> >  #include<linux/fs_struct.h>
> >+#ifdef CONFIG_CHECKPOINT
> >+#include<linux/checkpoint.h>
> >+#endif
> >  #include<asm/uaccess.h>
> >
> >  #include "internal.h"
> >@@ -2543,6 +2546,105 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
> >  	return sys_linkat(AT_FDCWD, oldname, AT_FDCWD, newname, 0);
> >  }
> >
> >+#ifdef CONFIG_CHECKPOINT
> >+
> >+/* Path relative to the mounted filesystem's root -- not a "global" root or even a namespace root. The unique_name_count is unique for the entire checkpoint. */
> >+#define CKPT_RELINKAT_FMT "lost+found/checkpoint/unlink-at-restart-%08llx-%u"
> 
> A few existential questions:
> 
> * Do we want to hard-code to /lost+found/checkpoint/... or allow

(nit: sans the first / )

>  userspace to set it per checkpoint ?

Good question. I was hoping to get a discussion on this from
everyone. lost+found/checkpoint is a poor but simple solution
which we'll likely need to enhance or change. It highlights the
issues without requiring everyone to read alot of code.

> 
> * If we put it all in some place, could it cause some security
>  or privacy issues, if we hold data from multiple users on the
>  same filesystem ?
> 
> * This doesn't guarantee unique-ness among checkpoints. One option
>  is to add the ctx->crid to make it unique - but I'm unsure that
>  we'll keep it in the future.

Yes, the issue is multiple simultaneous checkpoints involving the
same filesystem but not the same processes. That's why I added the
checkpoint time in microseconds to the name. That doesn't eliminate
the possibility but it does make it very unlikely. In the very unlikely
event that two checkpoints try to make a hardlink with the same
name we'll get EEXIST and checkpoint will fail. That seems quite
acceptable to me given that it saves us from needing much more complex
naming schemes and kernel code to implement it. Of course there are other
issues related to the location we link to but I don't believe name
collisions are one of the real problems.

> 
> * For clean-up purposes, maybe get a subdir for each checkpoint ?

Except as you pointed out we may need a per-filesystem-per-user
directory for security/privacy.

> 
> * If checkpoint fails, who is responsible for the cleanup ?  I'd
>  prefer that sys_checkpoint() won't leave garbage behind (so using
>  the subdir approach above, we could just delete that dir ?)

Argh, you're right. I should probably add an "error cleanup" deferqueue
for that.

> 
> * If restart fails, e.g. because of lack of memory, then another
>  restart would fail because some (or all) relinked files will
>  have already been re-unlinked and gone.  Maybe defer all unlinks
>  to the end of the restart ?

Userspace had to restore the filesystem to the proper state before
restart anyway. Part of that restoration must be designed to ensure that
the originally preserved state will be preserved even well after a
_successful_ restart. Otherwise we could encounter an therwise-recoverable
hardware failure shortly after restart but prior to another checkpoint --
one that doesn't affect the system used to store the checkpoint -- and we'd
have no hope of using the previous checkpoint.

So the core point here is that restart ought to be non-destructive in
the sense that it does not destroy the state stored during checkpoint.
This is certainly true of the checkpoint image itself and yes, we should
try to make sure the same is true with respect to how we restore the
filesystem.

That said, I'm worried we'll find ourselves in a familiar pickle if
we start tacking on lists of things to do "at the end" that cannot fail.
Not only does thinking like that subtly change the definition of
"at the end" in subtly-broken ways but the "cannot fail" aspect of the
operations could easily be overlooked. And it might wind up making
promises we won't be able to deliver some day due to other code changes.

Perhaps we're better off saying that if restart fails the changes to
the filesystem are boundedly undefined. Bounded because we still obey
security policy (and it'd be a serious bug if we didn't!) and any of
the changes are "described" by a subset of what's in the checkpoint image.
Undefined because unlinked files may or may not have been deleted (in
this case). Userspace can take steps to save and then restore the filesystem
based on the contents of the checkpoint image. Indeed, that's a big part
of what userspace is supposed to do during checkpoint anyway. And this
supports my first point well.

So I'm fine with adding the deferqueue to cleanup the links on
the checkpoint side but I don't think we should defer the unlink
on the restart side.

>  (This is less of a problem when we had a filesystem snapshot,

Not just "less of a problem when..". It wouldn't be a problem with
snapshots. We'd just remount the snapshot and the relinked file will
still be there.

>  just go back to that snapshot. But when we, e.g. suspend a vnc
>  session to disk using checkpoint, and then try to resume - it
>  will be a problem).
> 
> * By using the unique counter, you assume that the sequence of
>  file-open's (or mkdir) will never change at restart. But if a
>  future user tool will alter the checkpoint image (assume it is
>  in a valid and desirable way) and drop one file, then we are
>  doomed ...  Instead, you should save the unique unlink id
>  explcitily in the ckpt_hdr_file.

I don't use the counter at all during restart. I use the
second path/fname stored specially in the checkpoint image for
unlinked files. That means we can change where we link without
changing the restart code :).

> 
> >+
> >+static int checkpoint_fill_relink_fname(struct ckpt_ctx *ctx,
> >+					struct file *for_file,
> >+					char relink_dir_pathname[PATH_MAX],
> >+					int *lenp)
> >+{
> >+	struct path relink_dir_path;
> >+	char *tmp;
> >+	int len;
> >+
> >+	/* Find path to mount */
> >+	relink_dir_path.mnt = for_file->f_path.mnt;
> >+	relink_dir_path.dentry = relink_dir_path.mnt->mnt_root;
> >+	tmp = d_path(&relink_dir_path, relink_dir_pathname, PATH_MAX);
> 
> This path is relative to whom ?

Relative to the root of the filesystem that stores the file.

> Don't we need similar precautions as in ckpt_fill_name(), in
> particular verify that that path is "reachable" from the
> checkpointer ?    Can it be made to reuse the code from there ?

That's not quite what I'm doing here. I'm making "from scratch" a
name that, if d_path succeeds, will be reachable.

> 
> >+	if (IS_ERR(tmp))
> >+		return PTR_ERR(tmp);
> >+
> >+	/* Append path to relinked file. */
> >+	len = strlen(tmp);
> >+	if (len<= 0)
> >+		return -ENOENT;
> >+	memmove(relink_dir_pathname, tmp, len);
> >+	tmp = relink_dir_pathname + len - 1;
> >+	/* Ensure we've got a single dir separator */
> >+	if (*tmp == '/')
> >+		tmp++;
> >+	else {
> >+		tmp++;
> >+		*tmp = '/';
> >+		tmp++;
> >+		len++;
> >+	}
> >+	len += snprintf(tmp, PATH_MAX - len, CKPT_RELINKAT_FMT,
> >+			ctx->ktime_begin.tv64,
> >+			 ++ctx->unique_name_count);
> 
> Should test for truncation, and bail...

Oops! You're quite correct!

> 
> >+	relink_dir_pathname[len] = '\0';
> >+	*lenp = len;
> >+	return 0;
> >+}
> >+
> >+static int checkpoint_file_relink(struct ckpt_ctx *ctx,
> >+				  struct file *file,
> >+				  char new_path[PATH_MAX])
> >+{
> >+	int ret, len;
> >+
> >+	/*
> >+	 * Relinking arbitrary files without searching a path
> >+	 * (which non-existent if the file is unlinked) requires
> >+	 * special privileges.
> >+	 */
> >+	if (!capable(CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH)) {
> >+		ckpt_err(ctx, -EPERM, "%(T)Relinking unlinked files requires CAP_DAC_{OVERRIDE,READ_SEARCH}\n");
> >+		return -EPERM;
> >+	}
> >+	ret = checkpoint_fill_relink_fname(ctx, file, new_path,&len);
> >+	if (ret)
> >+		return ret;
> >+	ret = do_kern_linkat(&file->f_path, file->f_dentry,
> >+			     AT_FDCWD, new_path, 0);
> >+	if (ret)
> >+		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to relink unlinked file.\n", file, file->f_op);
> >+	return ret;
> >+}
> >+
> >+int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file)
> >+{
> >+	char *new_link_path;
> >+	int ret, len;
> >+
> >+	if (!d_unlinked(file->f_dentry))
> >+		return 0;
> >+
> >+	/*
> >+	 * Unlinked files need at least one hardlink for the post-sys_checkpoint
> >+	 * filesystem backup/snapshot.
> >+	 */
> >+	new_link_path = kmalloc(PATH_MAX, GFP_KERNEL);
> >+	if (!new_link_path)
> >+		return -ENOMEM;
> >+	ret = checkpoint_file_relink(ctx, file, new_link_path);
> >+	if (ret<  0)
> >+		goto out_free;
> >+	len = strlen(new_link_path);
> >+	ret = ckpt_write_obj_type(ctx, NULL, len + 1, CKPT_HDR_BUFFER);
> 
> Do we need to save the entire pathname ?  Only the pathname to
> the relevant mount point suffices, no ?  (the timestamp and the
> unique id are available at restart).

No because, as you pointed out earlier, multiple checkpoints could
be in progress.

> 
> Also worth to think (and at least comment with a big TODO) that
> when we work on c/r support for mount points, we could just
> refer to a (shared object) mount point instead of carrying the
> path.

I haven't decided yet. :)

On the one hand, yes we could do that. It certainly would help us
handle the "overmount" case (I think that's what the openvz folks call
it) that we don't right now:

	mount /dev/foo /bar
	open /bar/baz
	mount /dev/qux /bar
	<checkpoint saves "/bar/baz" path>
	...
	<restart restores the mounts>
	filp_open("/bar/baz")

During restart we'll open the wrong "/bar/baz" if we've done a simple
restoration of the mount tree prior to re-opening. In fact we can't
cleanly divide mount tree restoration from re-opening files unless
we move away from using filp_open().

That said, full paths would be useful if we don't care about exactly
how the (file) namespace is constructed -- only that it's contents
are correct. For example, suppose we migrate the checkpoint image
from machine X to machine Y. X might have "/bar/baz" on the root
filesystem but Y might have it on a 'different' filesystem mounted
on "/bar". If we attempt to recreate the mount tree then restart
won't work.

So whether to use a full path or mount-relative path all depends on
what method the system administrator wants to use to enable
migration of checkpoint/restart while meeting performance requirements.

And that's why I say I haven't decided. To some extent this is one
area where we'd find ourselves inadvertently defining policy for
userspace which could be "harmful" to their use of c/r and thus
require future c/r interface changes. Ideally we'd find a way to
give userspace the ability to choose policy and avoid those interface
changes.

So I was thinking of using setns() to enable checkpoint and restart
of mount namespaces. Usespace will set up the mount namespaces prior
to calling sys_restart. Then we pass in references to the mount
namespaces in the form of file descriptors opened by user-cr's restart
binary. This way it's all shell-scriptable too.

Anyhow -- I can post those as an RFC patch and this all belongs in
a separate thread for those :).

> 
> >+	if (ret<  0)
> >+		goto out_free;
> >+	ret = ckpt_kwrite(ctx, new_link_path, len + 1);
> >+out_free:
> >+	kfree(new_link_path);
> >+
> >+	return ret;
> >+}
> >+#endif /* CONFIG_CHECKPOINT */
> >+
> >  /*
> >   * The worst of all namespace operations - renaming directory. "Perverted"
> >   * doesn't even start to describe it. Somebody in UCB had a heck of a trip...
> >diff --git a/fs/pipe.c b/fs/pipe.c
> >index 7f00e58..1325e84 100644
> >--- a/fs/pipe.c
> >+++ b/fs/pipe.c
> >@@ -1021,7 +1021,7 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
> >  	 * To avoid blocking, always open the fifo with O_RDWR;
> >  	 * then fix flags below.
> >  	 */
> >-	file = restore_open_fname(ctx, (ptr->f_flags&  ~O_ACCMODE) | O_RDWR);
> >+	file = restore_open_fname(ctx, 0, (ptr->f_flags&  ~O_ACCMODE) | O_RDWR);
> >  	if (IS_ERR(file))
> >  		return file;
> >
> >diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> >index 4e25042..6ca7b24 100644
> >--- a/include/linux/checkpoint.h
> >+++ b/include/linux/checkpoint.h
> >@@ -258,7 +258,8 @@ extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
> >  /* files */
> >  extern int checkpoint_fname(struct ckpt_ctx *ctx,
> >  			    struct path *path, struct path *root);
> >-extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags);
> >+extern int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file);
> >+extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int restore_unlinked, int flags);
> >
> >  extern int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file);
> >
> >diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> >index f4f9577..ea50e7d 100644
> >--- a/include/linux/checkpoint_hdr.h
> >+++ b/include/linux/checkpoint_hdr.h
> >@@ -575,6 +575,9 @@ struct ckpt_hdr_file {
> >  	__u64 f_pos;
> >  	__u64 f_version;
> >  	__s32 f_secref;
> >+
> >+	__u32 f_restart_flags;
> >+#define RESTART_FILE_F_UNLINK (1<<0)
> >  } __attribute__((aligned(8)));
> >
> >  struct ckpt_hdr_file_generic {
> >diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> >index 3ffe9bd..ceaa671 100644
> >--- a/include/linux/checkpoint_types.h
> >+++ b/include/linux/checkpoint_types.h
> >@@ -57,6 +57,9 @@ struct ckpt_ctx {
> >
> >  	struct path root_fs_path;     /* container root (FIXME) */
> >
> >+	/* relink unlinked files to<mnt_root>/<unique_name>  */
> >+	unsigned int unique_name_count;
> 
> [nit] why not straightforward "unique_relink_count" ?

Sure, that does look better.

> 
> >+
> >  	struct task_struct *tsk;/* checkpoint: current target task */
> >  	char err_string[256];	/* checkpoint: error string */
> >
> 
> Phew ... end of round one :)

If you read my long-winded responses above then you know that you spoke
too soon! ;)

Cheers,
	-Matt
