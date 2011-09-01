From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Thu, 1 Sep 2011 12:05:08 +0400
Message-ID: <20110901080508.GF30615@sun>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110831151023.5b7e12da.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, Aug 31, 2011 at 03:10:23PM -0700, Andrew Morton wrote:
...

Pavel has just addressed the intention of the patch in another
reply.

> >  
> > +static struct vm_area_struct *
> > +find_exact_vma(struct mm_struct *mm, unsigned long vm_start, unsigned long vm_end)
> > +{
> > +	struct vm_area_struct *vma = find_vma(mm, vm_start);
> > +	if (vma && (vma->vm_start != vm_start || vma->vm_end != vm_end))
> > +		vma = NULL;
> > +	return vma;
> > +}
> 
> This function would benefit from a code comment.

ok

> 
> Given that it's pretty generic (indeed there might be open-coded code
> which already does this elsewhere), perhaps it should be in mm/mmap.c
> as a kernel-wide utility function.  That will add a little overhead to
> CONFIG_PROC_FS=n builds, which doesn't seem terribly important.
> 

Will update.

> > +static int map_name_to_addr(const unsigned ...
> > +{
> 
...
> Again, a little bit of interface documentation would be nice.  Explain
> what the parsed input format is, at least.
> 
> simple_strtoul() is obsolete - use kstrto*().  A checkpatch rule for
> this is queued.

OK, will update.

> 
> > +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> > +{
> > +
...
> > +	if (!map_name_to_addr(dentry->d_name.name, &vm_start, &vm_end)) {
> > +		down_read(&mm->mmap_sem);
> > +		vma = find_exact_vma(mm, vm_start, vm_end);
> 
> OK, this is nasty.  We have a local variable which points to a vma but
> then we release the locks and refcounts which protect that vma.  So we
> have a pointer which we cannot dereference.  That's dangerous.
...
> And we don't actually dereference it - at present.  We use it as a bool.
>
> Would it not be nicer, safer and clearer to turn this pointer-as-a-bool
> into a bool?
> 
> 	bool matching_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
> 

Yeah, thanks, will update.

...
> > +
> > +	inode->i_op	= &proc_pid_link_inode_operations;
> > +	inode->i_size	= 64;
> > +	inode->i_mode	= S_IFLNK;
> 
> The fancy indenting is not a thing we usually do in the kernel.

Fancy indenting really makes code easier to read, and in real
we do it in kernel as well, but ok, I'll drop it.

...
> > +/*
> > + * NOTE: The getattr/setattr for both /proc/$pid/map_files and
> > + * /proc/$pid/fd seems to have share the code, so need to be
> > + * unified and code duplication eliminated!
> 
> Why not do this now?

There are a couple of reasons. Yesterday I was talking to
Vasiliy Kulikov about this snippet, so he seems about to send
you patches related to /proc/$pid/fd update, and after those
patches will be merged we are to drop code duplication.
Vasiliy, what the status of the update?

Secondly, I've had a problems trying to download -mm patches
yesterday (I believe 'cause of kernel.org problem) so I rather
put this note here in patch just to *not* forget to do a cleanup
work once things calm down. And eventually, I believe this
cleanup should be separately in a sake of bisectability.

Again, this note is related to the future patch from Vasiliy
and mark for myself to not forget clean it up later.

> 
> > + */
> > +
> > +int proc_map_files_setattr(struct dentry *dentry, struct iattr *attr)
> 
> static

Nod, thanks.

...
> > +		 * othrewise we get lockdep complains since filldir
> 
> typo

Thanks.

> 
> > +		 * might sleep.
> > +		 */
> 
> Why would lockdep complain about sleep-inside-mmap_sem?

filldir calls for might_fault and need mmap_sem as well
(when CONFIG_PROVE_LOCKING is set) and this makes lockdep
to complain. In real I revealed it during testing.

...
> > +		if (nr_files) {
> > +			info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);
> 
> I figure sizeof(*info) = 50 bytes.  nr_files can easily be >1000.
> 
> On large some applications the kmalloc attempt will be too large.  This
> is a must-fix.  Using vmalloc() would be very lame.

Yes, I'll add a test which one to use, either kmalloc, either vmalloc,
depending on size needed.

...
> > +				vmai++;
> 
> What is "vmai"?  "vma index"?  If so, please call it vma_index.  If
> not, please call it something better anyway.
> 
> vmai/vma_index could be made local to this code block.

ok

...
> > +		for (i = 0; i < used; i++) {
> > +			ret = proc_fill_cache(filp, dirent, filldir,
> > +					      info[i].name, info[i].len,
> > +					      proc_map_files_instantiate,
> > +					      task, info[i].file);
> > +			if (ret)
> > +				break;
> > +			filp->f_pos++;
> > +		}
> > +
> > +		for (i = 0; i < used; i++)
> > +			put_filp(info[i].file);
> 
> Why not do the put_filp() in the previous loop and avoid some cache
> misses?

Because first loop may fail (break) and I still have to drop
refs to filep -- which in turn means I'll have to continue
from broken position, ie like this

	for (; i < used; i++)
		put_filp(info[i].file);

But, OK, I'll update. Thanks a huge for comments, Andrew!

	Cyrill
