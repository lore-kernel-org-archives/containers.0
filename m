From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: List of filesystems to use generic checkpoint fops
Date: Fri, 27 Mar 2009 10:56:51 -0400
Message-ID: <49CCE933.5050004@cs.columbia.edu>
References: <20090327040534.GB27803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090327040534.GB27803-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> In case anyone's curious here is my list of filesystems which I think should
> have generic_file_checkpoint fops (31):

Thanks, Matt.

> 	adfs
> 	affs
> 	befs
> 	bfs
> 	btrfs
> 	cramfs
> 	ecryptfs
> 	efs
> 	fat
> 	freevxfs
> 	hfs
> 	hfsplus
> 	hpfs
> 	hppfs
> 	isofs
> 	jffs2
> 	jfs
> 	minix
> 	ntfs
> 	omfs
> 	openpromfs
> 	qnx4
> 	ramfs

I'd think that in the case of ramfs we always need to dump the contents of the
file, or the entire file system, with the checkpoint image.

> 	reiserfs
> 	romfs
> 	squashfs
> 	sysv
> 	ubifs
> 	udf
> 	ufs
> 	xfs
> 
> I also added the checkpoint operation to generic_ro_fops since it's used
> only in the set of filesystems listed above. For the curious:
> 	befs
> 	cramfs
> 	efs
> 	freevxfs
> 	isofs
> 	romfs
> 	squashfs

??

[...]

Oren.
