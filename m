From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
	directory v6
Date: Wed, 7 Sep 2011 15:13:23 -0700
Message-ID: <20110907151323.613e62e7.akpm@linux-foundation.org>
References: <20110902163711.GA3124@albatros> <20110905185358.GA2103@albatros>
	<20110905192009.GJ761@sun> <20110905194908.GA2690@albatros>
	<20110905203627.GL761@sun> <20110906101518.GA4799@albatros>
	<20110906165144.GJ18425@mtj.dyndns.org>
	<20110906172952.GA28055@albatros>
	<20110906173341.GM18425@mtj.dyndns.org>
	<20110907112301.GA12157@albatros> <20110907215329.GB28162@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110907215329.GB28162@sun>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 8 Sep 2011 01:53:29 +0400
Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Wed, Sep 07, 2011 at 03:23:01PM +0400, Vasiliy Kulikov wrote:
> > Hi,
> > 
> > On Wed, Sep 07, 2011 at 02:33 +0900, Tejun Heo wrote:
> > > On Tue, Sep 06, 2011 at 09:29:52PM +0400, Vasiliy Kulikov wrote:
> > > > I agree with you.  I don't think that showing system-global debug
> > > > information to all users by default is the right thing.  But some people
> > > > doesn't agree with this point of view:
> > > > 
> > > > http://thread.gmane.org/gmane.linux.kernel/1108378
> > > 
> > > Yeap, I know there are two sides of the discussion but if one takes
> > > the position that hiding such global debug info is more harmful, it's
> > > only crazier to hide such information from each individual users of
> > > the said global facility.  So, let's just forget about information
> > > leak via freeing or not freeing here.  It's the wrong battle field.
> > 
> > Andrew, are you OK with closing the hole with pid_no_revalidate()
> > and 0600 /proc/slabinfo?  If so, I feel I have to start this discussion
> > with people participating in the discussion above: Theodore, Dan, Linus, etc.

I fell asleep a long time ago and don't know what pid_no_revalidate()
and slabinfo permissions have to do with this.  Perhaps summarising the
issues in the changelog would be appropriate, dunno.

> > By Andrew Morton
> >
> > But do we *really* need to do it in two passes?  Avoiding the temporary
> > storage would involve doing more work under mmap_sem, and a put_filp()
> > under mmap_sem might be problematic.
> 
> I fear we still need to use two passes in proc_map_files_readdir, I found no way
> to escape lockdep complains when doing all work in one pass with mmap_sem taken.
> The /maps does the same thing -- ie it fills maps file with mmap_sem taken to produce
> robust data.

The code's using three passes.

> And I'm not really sure what you mean with problematic put_filp?

I was thinking fput(), which can do a hell of a lot of stuff if it's
the final put on the inode.

>
> ...
>
> +static int proc_map_files_readdir(struct file *filp, void *dirent, filldir_t filldir)
> +{
> +	struct dentry *dentry = filp->f_path.dentry;
> +	struct inode *inode = dentry->d_inode;
> +	struct vm_area_struct *vma;
> +	struct task_struct *task;
> +	struct mm_struct *mm;
> +	ino_t ino;
> +	int ret;
> +
> +	ret = -ENOENT;
> +	task = get_proc_task(inode);
> +	if (!task)
> +		goto out_no_task;
> +
> +	ret = -EPERM;
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ))
> +		goto out;
> +
> +	ret = 0;
> +	switch (filp->f_pos) {
> +	case 0:
> +		ino = inode->i_ino;
> +		if (filldir(dirent, ".", 1, 0, ino, DT_DIR) < 0)
> +			goto out;
> +		filp->f_pos++;
> +	case 1:
> +		ino = parent_ino(dentry);
> +		if (filldir(dirent, "..", 2, 1, ino, DT_DIR) < 0)
> +			goto out;
> +		filp->f_pos++;
> +	default:
> +	{
> +		unsigned long nr_files, used, pos, i;
> +		struct flex_array *fa = NULL;
> +		struct map_files_info info;
> +		struct map_files_info *p;
> +
> +		mm = get_task_mm(task);
> +		if (!mm)
> +			goto out;
> +		down_read(&mm->mmap_sem);
> +
> +		nr_files = 0;
> +		used = 0;
> +
> +		/*
> +		 * We need two passes here:
> +		 *
> +		 *  1) Collect vmas of mapped files with mmap_sem taken
> +		 *  2) Release mmap_sem and instantiate entries
> +		 *
> +		 * otherwise we get lockdep complained, since filldir()
> +		 * routine might require mmap_sem taken in might_fault().
> +		 */
> +
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (vma->vm_file)
> +				nr_files++;
> +		}
> +
> +		if (nr_files) {
> +			ret = -ENOMEM;
> +			fa = flex_array_alloc(sizeof(info), nr_files, GFP_KERNEL);
> +			if (!fa)
> +				goto err;
> +			if (flex_array_prealloc(fa, 0, nr_files, GFP_KERNEL))
> +				goto err;
> +			for (vma = mm->mmap, pos = 2; vma; vma = vma->vm_next) {
> +				if (!vma->vm_file)
> +					continue;
> +				if (++pos <= filp->f_pos)
> +					continue;
> +
> +				get_file(vma->vm_file);
> +				info.file = vma->vm_file;
> +				info.len = snprintf(info.name, sizeof(info.name),
> +						    "%lx-%lx", vma->vm_start,
> +						    vma->vm_end);
> +				if (flex_array_put(fa, used, &info, GFP_KERNEL)) {
> +					/*
> +					 * This must never happen on preallocated array,
> +					 * but just to be sure.
> +					 */
> +					WARN_ON_ONCE(1);
> +					put_filp(vma->vm_file);
> +					goto err;
> +				}
> +				used++;
> +			}
> +			ret = 0;
> +		}
> +err:
> +		up_read(&mm->mmap_sem);
> +
> +		for (i = 0; i < used && !ret; i++) {

The "&& !ret" is unneeded?

> +			p = flex_array_get(fa, i);
> +			ret = proc_fill_cache(filp, dirent, filldir,
> +					      p->name, p->len,
> +					      proc_map_files_instantiate,
> +					      task, p->file);
> +			if (ret)
> +				break;
> +			filp->f_pos++;
> +			put_filp(p->file);
> +		}
> +
> +		for (; i < used; i++) {
> +			p = flex_array_get(fa, i);
> +			put_filp(p->file);
> +		}

Still unclear why we need the third loop.

> +		if (fa)
> +			flex_array_free(fa);
> +
> +		mmput(mm);
> +	}
> +	}
> +
> +out:
> +	put_task_struct(task);
> +out_no_task:
> +	return ret;
> +}
>
> ...
>
