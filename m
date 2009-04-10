From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/30] Remove struct mm_struct::exe_file et al
Date: Thu, 9 Apr 2009 20:33:01 -0700
Message-ID: <20090410033301.GA29496__30771.6596442789$1239334557$gmane$org@us.ibm.com>
References: <20090410023312.GC27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023312.GC27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 10, 2009 at 06:33:12AM +0400, Alexey Dobriyan wrote:
> Commit 925d1c401fa6cfd0df5d2e37da8981494ccdec07 aka "procfs task exe symlink".
> introduced struct mm_struct::exe_file and struct
> mm_struct::num_exe_file_vmas.
> 
> The rationale is weak: unifying MMU and no-MMU version of /proc/*/exe code.
> For this a) struct mm_struct becomes bigger, b) mmap/munmap/exit become slower,

Again -- no numbers to tell us how significant the performance savings are.
Until I see numbers it seems to me you're making a mountain of a molehill here
so I guess I can do the same.

With this patch any task can briefly hold any mmap semaphore it wants by doing
readlink on /proc/*/exe. In contrast, exe_file avoids the need to hold mmap_sem 
when doing a readlink on /proc/*/exe. As far as I am aware mmap_sem is
a notoriously bad semaphore to hold for any duration and hence anything that
avoids using it would be helpful.

> c) patch adds more code than removes in fact.
> 
> After commit 8feae13110d60cc6287afabc2887366b0eb226c2 aka
> "NOMMU: Make VMAs per MM as for MMU-mode linux" no-MMU kernels also
> maintain list of VMAs in ->mmap, so we can switch back for MMU version
> of /proc/*/exe.
> 
> This also helps C/R, no need to save and restore ->exe_file and to count
> additional references.

Checkpointing exe_file is easy -- it can be done just like any other file
reference the task holds. No extra reference counting code is necessary.
num_exe_file_vmas need not be saved so long as exe_file is set prior to creating
the VMAs.

It looks to me like you've fixed the bugs from the previous version that David
Howells nacked. He is missing from the Cc list so I've added him.

> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
>  fs/exec.c                |    2 
>  fs/proc/base.c           |  105 +++++++++++++----------------------------------
>  include/linux/mm.h       |   12 -----
>  include/linux/mm_types.h |    6 --
>  include/linux/proc_fs.h  |   20 --------
>  kernel/fork.c            |    3 -
>  mm/mmap.c                |   22 +--------
>  mm/nommu.c               |   16 -------
>  8 files changed, 36 insertions(+), 150 deletions(-)

Granted, the reduction in code certainly looks nice. IMHO this is your
only strong argument for the patch.

Cheers,
	-Matt Helsley
