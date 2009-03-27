From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: List of filesystems to use generic checkpoint fops
Date: Thu, 26 Mar 2009 21:05:34 -0700
Message-ID: <20090327040534.GB27803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

In case anyone's curious here is my list of filesystems which I think should
have generic_file_checkpoint fops (31):
	adfs
	affs
	befs
	bfs
	btrfs
	cramfs
	ecryptfs
	efs
	fat
	freevxfs
	hfs
	hfsplus
	hpfs
	hppfs
	isofs
	jffs2
	jfs
	minix
	ntfs
	omfs
	openpromfs
	qnx4
	ramfs
	reiserfs
	romfs
	squashfs
	sysv
	ubifs
	udf
	ufs
	xfs

I also added the checkpoint operation to generic_ro_fops since it's used
only in the set of filesystems listed above. For the curious:
	befs
	cramfs
	efs
	freevxfs
	isofs
	romfs
	squashfs

I've got the patches split out per-filesystem even though they are
incredibly tiny. I'll keep rebasing them on the latest git trees from Dave's
kernel.org tree until the checkpoint fop set is ready to be sent to Oren.

The net result is I haven't added any checkpoint operations to filesystems
outside the lists above.

Open ramfs directories aren't checkpointable because, like many special
filesystems, the directories are kept in the dcache with
simple_dir_operations from libfs.c. Filesystems that use it include:
	autofs
	cifs
	debugfs
	devpts
	fuse
	hugetlbfs
	ocfs2
	ramfs

I think I could fix this with a private copy of simple_dir_operations but I
wasn't certain it would work or that it was the best way to handle it. So I've
postponed full ramfs checkpoint support. This means that ramfs files are always
checkpointable but the directories aren't.

A few "regular" filesystems have /proc or debugfs contents (many of them
using the seq_file API). These tend to contain information about the
filesystem or special control interfaces (btrfs). I'm not quite sure
what we'll want to do with these for now. I think eventually we'd add a
checkpoint operation to the seq_file API. My hunch is the majority
of seq_files won't be checkpointable. I also suspect that the
control files won't usually care what the file position is so we may be
able to add generic_file_checkpoint to those after a more careful review of
each one.

It may be easier to remember what's left "TODO" in fs/*:
	9p
	afs
	autofs[4]
	cifs
	coda
	configfs
	debugfs
	devpts
	ext[234] (Dave's handling this)
	(anything that uses dlm)
	fuse
	gfs2
	hostfs
	hugetlbfs
	(anything that uses jbd[2])
	ncpfs
	nfs (I've got patches for NFS but I don't trust them yet and they lack
		support for the seq_file interfaces in /proc)
	ocfs2
	proc (HUGE)
	ramfs
	smbfs (deprecated, so .. never?)
	sysfs

	bad_inode.c (unused outside bad_inode.c so low priority??)
	binfmt_misc.c
	block_dev.c
	char_dev.c (def_chr_fops)
	epoll (eventpoll.c)
	eventfd.c
	fifo.c
	filesystems.c (/proc/filesystems)
	no-block.c
	notify/*
	select.c
	signalfd.c
	locks.c
	pipe.c

I haven't looked outside of fs/* for anything that uses struct file_operations 
-- I'm assuming most of that is for "irregular" filesystems :).

Cheers,
	-Matt
