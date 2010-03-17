From: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
Subject: Re: [C/R v20][PATCH 46/96] c/r: add checkpoint operation for opened
	files of generic filesystems
Date: Wed, 17 Mar 2010 15:09:00 -0600
Message-ID: <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6__24983.7203803056$1268860277$gmane$org@sun.com>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
	<1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <1268842164-5590-47-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2010-03-17, at 10:08, Oren Laadan wrote:
> These patches extend the use of the generic file checkpoint  
> operation to
> non-extX filesystems which have lseek operations that ensure we can  
> save
> and restore the files for later use. Note that this does not include
> things like FUSE, network filesystems, or pseudo-filesystem kernel
> interfaces.

I didn't see any other patches posted to linux-fsdevel regarding what  
this code is, or what it is supposed to be doing.  Could you please  
repost the patches related to generic_file_checkpoint(), and the  
overview email that explains what you mean by "checkpoint".  I'm  
assuming this is related to HPC/process restart/migration, but better  
to not guess.

> @@ -718,6 +718,7 @@ static const struct file_operations  
> btrfs_ctl_fops = {
> 	.unlocked_ioctl	 = btrfs_control_ioctl,
> 	.compat_ioctl = btrfs_control_ioctl,
> 	.owner	 = THIS_MODULE,
> +	.checkpoint = generic_file_checkpoint,
> };
>
> const struct file_operations exofs_file_operations = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.write		= do_sync_write,
> 	.aio_read	= generic_file_aio_read,
>
> static const struct file_operations hostfs_file_fops = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.splice_read	= generic_file_splice_read,
> 	.aio_read	= generic_file_aio_read,
> @@ -430,6 +431,7 @@ static const struct file_operations  
> hostfs_file_fops = {
>
> static const struct file_operations hostfs_dir_fops = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.readdir	= hostfs_readdir,
> 	.read		= generic_read_dir,
> };
>
> const struct file_operations nilfs_file_operations = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.write		= do_sync_write,
> 	.aio_read	= generic_file_aio_read,


Minor nit - it would be good to add this method in the same place in  
all of the *_file_operation structures for consistency.  Ideally these  
would already be in the order that they are declared in the structure,  
but at least new ones should be added consistently.

> static const struct vm_operations_struct nfs_file_vm_ops = {
> 	.fault = filemap_fault,
> 	.page_mkwrite = nfs_vm_page_mkwrite,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint = filemap_checkpoint,
> +#endif
> };

Why is this one conditional, but the others are not?


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
