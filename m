From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Fri, 19 Mar 2010 21:43:10 -0700
Message-ID: <20100320044310.GC2887__20524.0756426521$1269060255$gmane$org@count0.beaverton.ibm.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F18D161D-850B-4C82-83D5-1F19D573E84F-xsfywfwIY+M@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Mar 19, 2010 at 05:19:22PM -0600, Andreas Dilger wrote:
> On 2010-03-18, at 18:59, Oren Laadan wrote:
> >+int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path,
> >struct path *root)
> >+{
> >+	fname = ckpt_fill_fname(path, root, buf, &flen);
> >+	if (!IS_ERR(fname)) {
> >+		ret = ckpt_write_obj_type(ctx, fname, flen,
> >+					  CKPT_HDR_FILE_NAME);
> 
> What is the intended use case for the checkpoint/restore being
> developed here?  It seems like a major risk to do the checkpoint

Yes, as you anticipated below, we want to be able to migrate the
image to a similar node.

> using the filename, since this is not guaranteed to stay constant
> and the restore may give you a different state than what was running
> when the checkpoint was done.  Storing a file handle in the

We're aware of this.

Our assumption is userspace will freeze the filesystem and/or take
suitable snapshots (e.g. with btrfs) while the tasks being checkpointed
are also frozen. If userspace wants to freeze everything but the task
performing the checkpoint then that's fine too.

We decided to have userspace checkpoint the filesystem contents because
it will likely take an extraordinarily long time. We anticipate that
userspace will want to take advantage of many time-saving strategies
which would be impossible to anticipate perfectly for our kernel
syscall ABI.

Even though a wide set of time-saving strategies is available,
the goal is to keep the checkpoint image format and content
independent of the tools that perform migration.

> checkpoint, instead of (or in addition to) the filename would allow
> restoring the state correctly.
>
> Note that you would also need to store some kind of FSID as part of
> the file handle, which is a functionality that would be desirable
> for Aneesh's recent open_by_handle() patches as well, so getting
> this right once would be of use to both projects.

I haven't looked at those, sorry. It may be useful but I think
there's room for adding that in the future as you hinted above.
My guess is, depending on the environment of the restarting machine,
an FSID might not even be enough. Again -- I need to find some time
to review those patches before I can be sure :).

Userspace coordinates the management of the nodes and thus knows
best how to map things like major:minor, /dev/foo, and/or
uuids to the appropriate "things" when it comes time to restart.
The best the kernel can do is provide all of those so that userspace
can make the choices it needs to. However, most of that information is
already available via /proc in mountinfo or via other userspace tools.
So we don't save it in the image nor do we provide new interfaces to
get it.

> That said, if the intent is to allow the restore to be done on
> another node with a "similar" filesystem (e.g. created by rsync/node
> image), instead of having a coherent distributed filesystem on all
> of the nodes then the filename makes sense.

Yes, this is the intent.

> I would recommend to store both the file handle+FSID and the
> filename, preferring the former for "100% correct" restores on the
> same node, and the latter for being able to restore on a similar
> node (e.g. system files and such that are expected to be the same on
> all nodes, but do not necessarily have the same inode number).

This sounds like a good idea for the future. However I do not think
inclusion of our patches should be predicated on this since the patches
are still useful for local restart (thanks to things like mount namespaces)
and migration without file handles.

Thanks for having a look at these!

Cheers,
	-Matt Helsley
