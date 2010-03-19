From: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Fri, 19 Mar 2010 17:19:22 -0600
Message-ID: <F18D161D-850B-4C82-83D5-1F19D573E84F__47503.9988327355$1269040829$gmane$org@sun.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <1268960401-16680-4-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2010-03-18, at 18:59, Oren Laadan wrote:
> +int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path,  
> struct path *root)
> +{
> +	fname = ckpt_fill_fname(path, root, buf, &flen);
> +	if (!IS_ERR(fname)) {
> +		ret = ckpt_write_obj_type(ctx, fname, flen,
> +					  CKPT_HDR_FILE_NAME);

What is the intended use case for the checkpoint/restore being  
developed here?  It seems like a major risk to do the checkpoint using  
the filename, since this is not guaranteed to stay constant and the  
restore may give you a different state than what was running when the  
checkpoint was done.  Storing a file handle in the checkpoint, instead  
of (or in addition to) the filename would allow restoring the state  
correctly.

Note that you would also need to store some kind of FSID as part of  
the file handle, which is a functionality that would be desirable for  
Aneesh's recent open_by_handle() patches as well, so getting this  
right once would be of use to both projects.

That said, if the intent is to allow the restore to be done on another  
node with a "similar" filesystem (e.g. created by rsync/node image),  
instead of having a coherent distributed filesystem on all of the  
nodes then the filename makes sense.

I would recommend to store both the file handle+FSID and the filename,  
preferring the former for "100% correct" restores on the same node,  
and the latter for being able to restore on a similar node (e.g.  
system files and such that are expected to be the same on all nodes,  
but do not necessarily have the same inode number).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
