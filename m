From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 18:06:06 -0700
Message-ID: <20100322010606.GG2887__2649.73121597922$1269220032$gmane$org@count0.beaverton.ibm.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100321172703.GC4174-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Mar 21, 2010 at 05:27:03PM +0000, Jamie Lokier wrote:
> Matt Helsley wrote:
> > > That said, if the intent is to allow the restore to be done on
> > > another node with a "similar" filesystem (e.g. created by rsync/node
> > > image), instead of having a coherent distributed filesystem on all
> > > of the nodes then the filename makes sense.
> > 
> > Yes, this is the intent.
> 
> I would worry about programs which are using files which have been
> deleted, renamed, or (very common) renamed-over by another process
> after being opened, as there's a good chance they will successfully
> open the wrong file after c/r, and corrupt state from then on.

The code in the patches does check for unlinked files and refuses
to checkpoint if an unlinked file is open. Yes, this limits the usefulness
of the code somewhat but it's a problem we can solve and c/r is still quite
useful without the solution.

My favorite solution for unlinked files is keeping the contents of the file
in the checkpoint image. Another solution is relinking it to a new "safe"
location in the filesystem. Determining the "safe" location is not very clean
because we need one "safe" location per filesystem being backed-up. Hence I
tend to favor the first approach. Neither solution is implemented
and thoroughly tested yet though.

These solutions are needed because the data is not available via a normal
filesystem backup. Renames are dealt with by requiring userspace to freeze
and/or safely take a snapshot of the filesystem as with any backup.

> This can be avoided by ensuring every checkpointed application is
> specially "c/r aware", but that makes the feature a lot less
> attractive, as well as uncomfortably unsafe to use on arbitrary

We avoided using that solution for the very flaws you point out.
In fact, so far we've managed to avoid requiring cooperation with
the tasks being checkpointed.

> processes.  Ideally, c/r would fail on some types of process
> (e.g. using sockets), but at least fail in a safe way that does not
> lead to quiet data corruption.

We've done our best to try and reach that ideal. You're welcome to have a
look at the code to see if you can find any ways in which we haven't.
Here's the code that refuses to checkpoint unsupported files. I think
it's pretty easy to read:

int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
{
        struct file *file = (struct file *) ptr;
        int ret;

        if (!file->f_op || !file->f_op->checkpoint) {
                ckpt_err(ctx, -EBADF, "%(T)%(P)%(V)f_op lacks checkpoint\n",
                               file, file->f_op);
                return -EBADF;
        }

        if (is_dnotify_attached(file)) {
                ckpt_err(ctx, -EBADF, "%(T)%(P)dnotify unsupported\n", file);
                return -EBADF;
        }

        ret = file->f_op->checkpoint(ctx, file);
        if (ret < 0)
                ckpt_err(ctx, ret, "%(T)%(P)file checkpoint failed\n", file);
        return ret;
}

(As Serge noted, we don't support inotify. inotify and fanotify require
an fd to register the fsnotify marks and the struct file associated with
that fd lacks the f_ops->checkpoint operation, hence that will cause
checkpoint to fail too and, again, there will be no silent corruption)

Negative return values cause sys_checkpoint() to stop checkpointing and
return the given errno. The f_op->checkpoint is often a generic operation
which ensures that the file is not unlinked before it saves things like
the position of the file (checkpoint_file_common()) and the path to the file
(checkpoint_fname()):

int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
{
        struct ckpt_hdr_file_generic *h;
        int ret;

        /*
         * FIXME: when we'll add support for unlinked files/dirs, we'll
         * need to distinguish between unlinked filed and unlinked dirs.
         */
        if (d_unlinked(file->f_dentry)) {
                ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
                         file);
                return -EBADF;
        }

        h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
        if (!h)
                return -ENOMEM;

        h->common.f_type = CKPT_FILE_GENERIC;

        ret = checkpoint_file_common(ctx, file, &h->common);
        if (ret < 0)
                goto out;
        ret = ckpt_write_obj(ctx, &h->common.h);
        if (ret < 0)
                goto out;
        ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
 out:
        ckpt_hdr_put(ctx, h);
        return ret;
}
EXPORT_SYMBOL(generic_file_checkpoint);

I wrote a simple script to look for missing operations in things like
file_operations. It can output counts in directories/files or show the
spot in the files where the struct is defined and a little context.

I used that script to check which files and protocols aren't supported
(for 2.6.33-rc8), I placed a histogram of the output in the wiki, and I've
tried to keep it up-to-date.

https://ckpt.wiki.kernel.org/index.php/UncheckpointableFilesystems
https://ckpt.wiki.kernel.org/index.php/UncheckpointableProtocols

The script is also there for anyone who wants to use it on newer kernels.
Here's the output which is of interest to folks on linux-fsdevel for anyone
who doesn't wish to follow a link -- the number of file_operations
structures missing the .checkpoint operation:

    162 arch
      3 block
      1 crypto
      1 Documentation
    718 drivers
    178 fs
             3 9p
              8 afs
              1 autofs
              3 autofs4
              1 bad_inode.c
              3 binfmt_misc.c
              1 block_dev.c
              2 cachefiles
              1 char_dev.c
             15 cifs
              4 coda
              2 configfs
              3 debugfs
              8 dlm
              1 ext4
              1 fifo.c
              1 filesystems.c
              3 fscache
              9 fuse
              5 gfs2
              1 hugetlbfs
              1 jbd2
              6 jfs
              1 libfs.c
              1 locks.c
              2 ncpfs
              2 nfs
              5 nfsd
              1 no-block.c
              1 notify
              1 ntfs
             15 ocfs2
             55 proc
              1 reiserfs
              1 signalfd.c
              2 smbfs
              3 sysfs
              1 timerfd.c
              3 xfs
      1 include
      4 ipc
     88 kernel
      3 lib
     12 mm
    164 net
      1 samples
     35 security
     29 sound
      4 virt

  Notes:
   1. The missing checkpoint file operation in fs/fifo.c is only an artifact of
	the unusual way fifo file ops are assigned. FIFOs are supported.
   2. The ext4 missing file operation is for the multiblock groups file in /proc
	IMHO trying to checkpoint the contents of /proc files is usually a bad
	idea. Thankfuly, most programs don't hold these files open for very
	long.

Cheers,
	-Matt Helsley
