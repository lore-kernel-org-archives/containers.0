From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/38] Remove struct mm_struct::exe_file et al
Date: Tue, 26 May 2009 04:36:18 -0700
Message-ID: <20090526113618.GJ28083__44568.8209184029$1243337892$gmane$org@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

I don't see any mention in the changelog of the point brought up by Ingo:

http://lkml.org/lkml/2009/4/10/105

You also haven't responded to my comment about holding mmap
semaphore:

http://lkml.indiana.edu/hypermail/linux/kernel/0904.1/01417.html

Also, please consider combining with Ingo's point with mine: the mmap
semaphore will be held for the duration of that long VMA walk. Plus
any userspace task can trigger that walk as often as they like via
readlink.

It also appears you haven't responded to Eric and Andrew's suggestion
of a struct path in place of a file reference: 

http://lkml.indiana.edu/hypermail/linux/kernel/0904.1/01698.html

Lastly, please keep me on Cc for future revisions of this patch since
I am interested in following changes to the implementation of
/proc/*/exe.

Thanks,
	-Matt Helsley

----- Forwarded message from Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> -----

From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Subject: [PATCH 14/38] Remove struct mm_struct::exe_file et al
Date: Fri, 22 May 2009 08:55:08 +0400
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Commit 925d1c401fa6cfd0df5d2e37da8981494ccdec07 aka "procfs task exe
symlink".
introduced struct mm_struct::exe_file and struct
mm_struct::num_exe_file_vmas.

The rationale is weak: unifying MMU and no-MMU version of /proc/*/exe
code.
For this a) struct mm_struct becomes bigger, b) mmap/munmap/exit become
slower,
c) patch adds more code than removes in fact.

After commit 8feae13110d60cc6287afabc2887366b0eb226c2 aka
"NOMMU: Make VMAs per MM as for MMU-mode linux" no-MMU kernels also
maintain list of VMAs in ->mmap, so we can switch back for MMU version
of /proc/*/exe.

This also helps C/R, no need to save and restore ->exe_file and to count
additional references to check if there is a leak of struct file outside
group of checkpointed resources.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/exec.c                |    2 -
 fs/proc/base.c           |  105
+++++++++++++---------------------------------
 include/linux/mm.h       |   12 -----
 include/linux/mm_types.h |    6 ---
 include/linux/proc_fs.h  |   20 ---------
 kernel/fork.c            |    3 -
 mm/mmap.c                |   22 ++--------
 mm/nommu.c               |   16 +------
 8 files changed, 36 insertions(+), 150 deletions(-)
