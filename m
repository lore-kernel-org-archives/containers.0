From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 04/36] btrfs: Add checkpoint file operations
Date: Mon, 4 May 2009 17:25:13 -0500
Message-ID: <20090504222513.GA32323@us.ibm.com>
References: <63ff4e88102e10e86bffefd5e4445ab433ed51c0.1241462097.git.matthltc@us.ibm.com>
	<d4c7782efa9f33324f65188dfb480d4ba1af7a27.1241462097.git.matthltc@us.ibm.com>
	<20090504214146.GA31338@us.ibm.com>
	<49FF69B4.3010700@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49FF69B4.3010700-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > 
> > ...
> > 
> >> diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
> >> index a7acfe6..f16be9d 100644
> >> --- a/fs/btrfs/super.c
> >> +++ b/fs/btrfs/super.c
> >> @@ -686,6 +686,7 @@ static const struct file_operations btrfs_ctl_fops = {
> >>  	.unlocked_ioctl	 = btrfs_control_ioctl,
> >>  	.compat_ioctl = btrfs_control_ioctl,
> >>  	.owner	 = THIS_MODULE,
> >> +	.checkpoint = generic_file_checkpoint,
> >>  };
> > 
> > Do we really want this one?
> 
> We need to checkpoint the open file regardless of whether the underlying
> filesystem has snapshot capabilities.

But maybe we need to refuse a checkpoint if a task is talking to the
underlying btrfs filesystem?

-serge
