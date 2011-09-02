From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 09:53:50 +0400
Message-ID: <20110902055350.GK30615@sun>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901104633.GG30615@sun>
 <20110901154946.b43ba91b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110901154946.b43ba91b.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, Sep 01, 2011 at 03:49:46PM -0700, Andrew Morton wrote:
> On Thu, 1 Sep 2011 14:46:34 +0400
> Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > On Wed, Aug 31, 2011 at 03:10:23PM -0700, Andrew Morton wrote:
> > > 
> > > This function would benefit from a code comment.
> > > 
> > > Given that it's pretty generic (indeed there might be open-coded code
> > > which already does this elsewhere), perhaps it should be in mm/mmap.c
> > > as a kernel-wide utility function.  That will add a little overhead to
> > > CONFIG_PROC_FS=n builds, which doesn't seem terribly important.
> > > 
> > 
> > Andrew, here is an attempt to address concerns. Please review.
> > Complains are welcome as always!
> 
> Changelog still doesn't explain why /proc/pid/maps is unfixably unsuitable.
> 

Will update.

> >
> > ...
> >
> > +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> > +{
> > +	unsigned long vm_start, vm_end;
> > +	struct task_struct *task;
> > +	const struct cred *cred;
> > +	struct mm_struct *mm;
> > +	struct inode *inode;
> > +
> > +	bool exact_vma_exists = false;
> >
> 
> Extraneous newline there.

ok, thanks

...
> > +
> > +		/*
> > +		 * We need two passes here:
> > +		 *
> > +		 *  1) Collect vmas of mapped files with mmap_sem taken
> > +		 *  2) Release mmap_sem and instantiate entries
> > +		 *
> > +		 * otherwise we get lockdep complained, since filldir()
> > +		 * routine might require mmap_sem taken in might_fault().
> > +		 */
> > +
> > +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +			if (vma->vm_file)
> > +				nr_files++;
> > +		}
> > +
> > +		if (nr_files) {
> > +			mem_size = nr_files * sizeof(*info);
> > +			if (mem_size <= KMALLOC_MAX_SIZE)
> > +				info = kmalloc(mem_size, GFP_KERNEL);
> > +			else
> > +				info = vmalloc(mem_size);
> 
> This still sucks :(
> 
> A KMALLOC_MAX_SIZE allocation is huuuuuuuuuuuuge!  I don't know how big

kmalloc_sizes.h said it could be quite a big :(

> it is nowadays, but over 100 kbytes.  This will frequently send page
> reclaim on a berzerk rampage freeing *thousands* of pages (or
> relocating pages) until it manages to generate 20 or 30 physically
> contiguous free pages.
> 
> Also, vmalloc sucks.  The more often we perform vmallocs (with a mix of
> differently-sized ones), the more internally fragmented the vmalloc
> arena will become.  With some workloads we'll run out of
> sufficiently-large contiguous free spaces and things will start
> failing.  This doesn't happen often.  Yet.  But the more vmalloc()
> callsites we add, the more likely and the more frequent it becomes.  So
> vmalloc is something we should only use as a last resort.
> 
> The most robust implementation here is to allocate a large number of
> small objects - one per vma.  A list would be a suitable way of
> managing them.

Actually I though about slab-cache with 64 bytes per object, but it
requires more code to push here, that is why I stopped. Still this
doesn't justify me. So yes, bad idea. Thanks!

> 
> But do we *really* need to do it in two passes?  Avoiding the temporary
> storage would involve doing more work under mmap_sem, and a put_filp()
> under mmap_sem might be problematic.
> 

In real, for the particular case where we use this /proc/pid/map_files
it could be done in one pass without mmap_sem taken (since we use it
when task is frozen and we know noone is poking vmas) but the problem
is that people might start using it not for c/r but in various different
cases when task is pretty running and I wanna give them more-less robust
result in ls -l over this directory.

Andrew, I'll think some more, probably I'll find a way to drop this two
passes requirement.

	Cyrill
