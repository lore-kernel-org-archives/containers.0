From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/10] Checkpoint/restart of open, unlinked files
Date: Mon, 28 Feb 2011 21:05:20 -0800
Message-ID: <20110301050520.GJ14893@count0.beaverton.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1298952316-15763-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Argh, always seem to forget some important details!
This series is based on Oren's ckpt-v23-rc1 tree plus:

1. sys-wrappers
	This patch set from Namhyung Kim wraps "various syscalls
	that were used in init code." These wrappers are also useful
	for the c/r patchset.

2. setns
	Because we're often checkpointing files in an namespace
	other than that occupied by the task calling sys_checkpoint()
	relink fails with EXDEV _unless_ we change to the appropriate
	mount namespace first. This dependency affects patch 9 of the
	series.

Cheers,
	-Matt Helsley

On Mon, Feb 28, 2011 at 08:05:06PM -0800, Matt Helsley wrote:
> This patch set implements the relink file operation and uses it to support
> checkpoint and restart of open, unlinked files. During checkpoint,
> sys_checkpoint relinks the files and returns. Userspace then checkpoints the
> filesystem contents using any backup-like method prior to thawing. That
> backup is then made available for use during an optional migration followed
> by restore and sys_restart. In the case of network and cluster/distributed
> filesystems copying the filesystem contents explicitly for migration may not
> be necessary at all -- it would be part of normal file writes. For
> non-migration uses of checkpoint/restart filesystems like btrfs a snapshot
> could simply be taken during checkpoint and mounted during restart -- again
> without requiring IO proportional to the aggregate size of filesystem
> contents being checkpointed.
> 
> These IO savings are critical to the use of checkpoint/restart as a
> fault mitigation solution in HPC environments where the probability of
> component failure is very high simply due to the number of system
> components. Incurring substantial IO for checkpoint/restart interferes
> with the IO requirements of HPC jobs and thus reduces the frequency of
> checkpoint/restart. That in turn means more processing time is lost
> as a consequence of a fault -- the longer period between checkpoints
> plus the IO required to re-establish hardlinks are simply not acceptable
> for these environments.
> 
> Without relinking we would need to walk the entire filesystem to find out
> that "b" is a path to the same inode (another variation on this case: "b"
> would also have been unlinked). We'd need to do this for every
> unlinked file that remains open in every task to checkpoint. Even then
> there is no guarantee such a "b" exists for every unlinked file -- the
> inodes could be "orphans" -- and we'd need to preserve their contents
> some other way.
> 
> I considered a couple alternatives to preserving unlinked file contents:
> copying and file handles. Each has significant drawbacks.
> 
> First I attempted to copy the file contents into the image and then
> recreate and unlink the file during restart. Using a simple version of
> that method the write above would not reach "b". One fix would be to search
> the filesystem for a file with the same inode number (inode of "b") and
> either open it or hardlink it to "a". Another would be to record the inode
> number. This either shifts the search from checkpoint time to restart time
> or has all the drawbacks of the second method I considered: file handles.
> 
> Instead of copying contents or recording inodes I also considered using
> file handles. We'd need to ensure that the filehandles persist in storage,
> can be snapshotted/backed up, and can be migrated. Can handlefs or any
> generic file handle system do this? My _guess_ is "no" but folks are
> welcome to tell me I'm wrong.
> 
> In contrast, linking the file from a_fd back into its filesystem can avoid
> these complexities. Relinking avoids the search for matching inodes and
> copying large quantities of data from storage only to write it back (in
> fact a non-linking solution requires that the data be read-and-written
> twice -- once for checkpoint and once for restart). Like file handles it does
> require changes to the filesystem code. Unlike file handles, enabling
> relinking does not require every filesystem to support a new kind of
> filesystem "object" -- only an operation that is quite similar to one that
> already exists: link.
> 
> [PATCH 01/10] Create the .relink file_operation
> [PATCH 02/10] ext3/4: Allow relinking to unlinked files
> [PATCH 03/10] Split do_linkat() out of sys_linkat
> [PATCH 04/10] Checkpoint/restart unlinked files
> [PATCH 05/10] Enable c/r of unlinked fifos
> [PATCH 06/10] Support relinking unlinked files in btrfs
> [PATCH 07/10] Add relink_dir superblock field
> [PATCH 08/10] Parse the relink=%s mount option
> [PATCH 09/10] Enabling checkpoint relink of unlinked files inside containers
> [PATCH 10/10] [RFC] Use call_usermodehelper to cleanup after failure
> 
> BUGS:
> 
> 	There's a memory leak (Reported-by: "Jose R. Santos"
> <jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>) that I haven't tracked down completely yet.
> It seems to be in the "relink=" mount option parsing code -- I feel like I
> must be missing some code path related to vfsmount handling.
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
