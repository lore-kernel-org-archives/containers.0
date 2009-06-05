From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Thu, 4 Jun 2009 20:49:40 -0700
Message-ID: <20090605034940.GC9285__36016.4345046089$1244173818$gmane$org@us.ibm.com>
References: <20090604224239.GA10666@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604224239.GA10666-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 04, 2009, Alexey Dobriyan wrote:
> On Thu, Jun 04, 2009 at 02:30:33PM -0700, Matt Helsley wrote:
> > On Thu, Jun 04, 2009 at 08:07:23AM -0700, Linus Torvalds wrote:
> > > On Thu, 4 Jun 2009, Matt Helsley wrote:
> > > > 
> > > > Doesn't this pin the vfs mount of the executable for the lifetime
> > > > of
> > > > the task?
> > > 
> > > Well, yes, but so does the current code.
> > 
> > Not quite. The current code pins it as long as the corresponding VMAs
> > are mapped -- not for the lifetime of the task.
> > 
> > > Sure, in _theory_ it can be a non-mmap executable (maybe people
> > > still have 
> > > those old OMAGIC a.out executables), and in _theory_ you could unmap
> > > the 
> > > executable even if it was originally mmap'ed, but neither of those
> > > is 
> > > exactly common, are they?
> > 
> > Not common to my knowledge, no.
> > 
> > > 
> > > So in practice, nothing has changed wrt lifetime of the executable.
> > 
> > Almost all of the time, yes.
> 
> And year ago executable wasn't pinned at all, so if you're opposing
> widening of time executable is pinned, you should revert your own patch
> which introduced it in first place.

You're wrong -- my patch did not widen the time the executable is pinned.
Read the exe_file changelog and give the code a more thorough read:

	[The exe_file] reference would prevent the filesystem holding the executable
	file from being unmounted even after unmapping the VMAs. So we track the
	number of VM_EXECUTABLE VMAs and drop the new reference when the last one is
	unmapped. This avoids pinning the mounted filesystem.

So long as the VMAs are mapped the filesystem is pinned. Until these VMAs are
unmapped exe_file does not extend the time that the filesystem is pinned. So
dropping the exe_file reference when the last VMA goes away should suffice in
preserving this property of the old VMA walk. The code does this by:

When exe_file is set from the bprm during exec we also set num_exe_file_vmas to 0.

When a VMA with VM_EXECUTABLE is mapped we call added_exe_file_vma() since
MAP_EXECUTABLE is only used for this (binfmt_* do_mmap() calls pass MAP_EXECUTABLE).
added_exe_file_vma() increments num_exe_file_vmas.

When a VM_EXECUTABLE VMA is split in two we call added_exe_file_vma() since there
is one more VMA.

When two VM_EXECUTABLE VMAs are merged we call removed_exe_file_vma() since there
is one less VMA. See removed_exe_file_vma() below.

When a VM_EXECUTABLE VMA is unmapped we call removed_exe_file_vma() since there
is one less VMA. When the last VM_EXECUTABLE VMA is unmapped num_exe_file_vmas 
drops to 0 and we trigger fput(exe_file):

void removed_exe_file_vma(struct mm_struct *mm)
{
       mm->num_exe_file_vmas--;
       if ((mm->num_exe_file_vmas == 0) && mm->exe_file){
               fput(mm->exe_file);
               mm->exe_file = NULL;
       }
}

which avoids pinning the VFS mount after the last VM_EXECUTABLE VMA is unmapped.

This is what used to happen with the old VMA-walk code too -- when the last
VM_EXECUTABLE VMA was unmapped the /proc/*/exe link disappeared  (as you've noted)
and the vfs mount was no longer pinned by the /proc/*/exe code.

In case you're curious here's what Al said when my original patch lacked this code
and hence ignored mount pinning:

	http://lkml.org/lkml/2007/7/12/398

So I added the VMA tracking code.

Since Linus seems to think vfs mount pinning is inconsequential
I don't mind dropping this objection. Please feel free to add my:

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

to this entire series.

> 
> ->exec_path merely makes /proc/*/exe very unheuristical (binfmt loader
> decides, nothing else) and suitable for other code as demonstrated.

Yes, the VMA walk that exe_file replaced was a bit of a heuristic.

Cheers,
	-Matt Helsley
