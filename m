From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: List of filesystems to use generic checkpoint fops
Date: Fri, 27 Mar 2009 20:19:11 -0700
Message-ID: <20090328031911.GD27803@us.ibm.com>
References: <20090327040534.GB27803@us.ibm.com>
	<49CCE933.5050004@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49CCE933.5050004-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 27, 2009 at 10:56:51AM -0400, Oren Laadan wrote:
> 
> 
> Matt Helsley wrote:
> > In case anyone's curious here is my list of filesystems which I think should
> > have generic_file_checkpoint fops (31):
> 
> Thanks, Matt.

You're welcome!

<snip>
> > 	ramfs
> 
> I'd think that in the case of ramfs we always need to dump the contents of the
> file, or the entire file system, with the checkpoint image.

I anticipated Dave's answer when I lumped ramfs with "regular"
filesystems. To the best of my knowledge it doesn't matter what kind of "block"
device backs these files. Only that the file contents can be migrated somehow
and that they support the seek operation.

Note that procfs is difficult for checkpoint/restart because the contents
often can't be migrated using rsync. Each non-process /proc file probably
will need its own checkpoint operation. I suspect this would frequently need to
be passed through an extended seq_file API much like the checkpoint op
extends the VFS file_operations. 

> > 	reiserfs
> > 	romfs
> > 	squashfs
> > 	sysv
> > 	ubifs
> > 	udf
> > 	ufs
> > 	xfs
> > 
> > I also added the checkpoint operation to generic_ro_fops since it's used
> > only in the set of filesystems listed above. For the curious:
> > 	befs
> > 	cramfs
> > 	efs
> > 	freevxfs
> > 	isofs
> > 	romfs
> > 	squashfs

The patch modifying generic_ro_fops doesn't quite match the pattern
established when patching the other filesystems so I thought it deserved
special mention. The other filesystems all define their own file_operation
structs but these share one.

Amongst other things these filesystems do not allow modifications to their file
contents. Consequently they share generic_ro_fops rather than define their own
file operations. cramfs, isofs, romfs, and squashfs are designed to be static,
offline-generated filesystems so generic_ro_fops makes sense here. I guess befs,
freevxfs, and efs are legacy filesystems and there is little reason to
implement write operations for them.

Cheers,
	-Matt
