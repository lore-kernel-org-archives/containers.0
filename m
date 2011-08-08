From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/4] proc: Introduce the /proc/<pid>/mfd/ directory
Date: Mon, 8 Aug 2011 20:20:33 +0400
Message-ID: <20110808162032.GC2434@sun>
References: <20110807210112.245578619@openvz.org>
 <20110807210526.741513583@openvz.org>
 <20110808154842.GD22863@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110808154842.GD22863@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>
List-Id: containers.vger.kernel.org

On Mon, Aug 08, 2011 at 05:48:42PM +0200, Tejun Heo wrote:
> Hello,
> 
> Maybe cc'ing linux-mm is a good idea for this one?

Yup!
...

> > 
> > This thing is aimed to help checkpointing processes.
> 
> I generally agree this is a good idea.  Can you please add how it
> would look (say, example ls -l output) in the patch description?
> Maybe some people think using both start and end addresses for symlink
> name is better?

OK, will do in update.

> 
> Another nit: I find the 'mfd' name a bit confusing as there's no file
> descriptor involved at all.  Maybe map_files (as we already have maps)
> or something like that?

map_files looks good to me.

> 
> > +static int proc_mfd_get_link(struct inode *inode, struct path *path)
> ...
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		if (vma->vm_start < vm_start)
> > +			continue;
> > +		if (vma->vm_start > vm_start)
> > +			break;
> 
> Why do linear walk instead of find_vma()?

I suppose we simply missed this helper :/

> 
> > +static const struct dentry_operations tid_mfd_dentry_operations = {
> > +	.d_delete	= pid_delete_dentry,
> > +};
> 
> Don't we also need revalidation here like tid_fd_dentry_operations?

Stricktly speaking, yes. Since in previous patchset this entries was
used in helper tool _only_ when task is frozen it was not needed but
to fit run-time requirements I think we need d_revalidate here indeed.
Thanks!

> Also, I think it would be better if all the related functions are
> collected into one contiguous chunk.  The scattering doesn't seem to
> make much sense.

ok

> 
> > +static struct dentry *proc_mfd_lookup(struct inode *dir,
> > +		struct dentry *dentry, struct nameidata *nd)
> > +{
> ..
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		if (vma->vm_start == vm_start)
> > +			break;
> > +		if (vma->vm_start > vm_start)
> > +			goto out_no_vma;
> > +	}
> 
> Ditto, no reason to do linear walk.

ok

> 
> Thanks.
> 

Thanks for comments, Tejun!

	Cyrill
