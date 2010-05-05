From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][cr][PATCH  2/6] Checkpoint file-locks
Date: Wed, 5 May 2010 09:56:56 -0500
Message-ID: <20100505145656.GA14459@us.ibm.com>
References: <1273023883-19264-1-git-send-email-Sukadev>
	<1273023883-19264-2-git-send-email-Sukadev>
	<20100505031256.GJ31830@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100505031256.GJ31830-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Tue, May 04, 2010 at 06:44:39PM -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > +int
> > +checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
> > +		struct file *file, int fd)
> > +{
> > +	int rc;
> > +	struct inode *inode;
> > +	struct file_lock **lockpp;
> > +	struct file_lock *lockp;
> > +	struct file_lock last_lock;
> > +
> > +	lock_kernel();
> 
> Eep. What are the current standards as far as adding "new" uses of the BKL?
> Arnd/anti-BKL-ninjas might be good folks to Cc on the next round if this
> is still here.

I'd say
	1. look at Arnd's tree just to be ready to switch to it's
	   locking method
	   (see http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/arnd/playground.git;a=commit;h=8dd5597e27d8c055376719434de6fa630da1b9f7)
	   Heck, maybe even use 'lock_flocks()' and just #define it to
	   lock_kernel for now.
	2. put this code straight into fs/locks.c, so that the related
	   uses of lock_kernel() are localized.
