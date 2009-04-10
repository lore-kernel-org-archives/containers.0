From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 02/30] Remove struct mm_struct::exe_file et al
Date: Fri, 10 Apr 2009 09:22:28 -0700
Message-ID: <m1ljq8eawr.fsf__14131.0360901572$1239380773$gmane$org@fess.ebiederm.org>
References: <20090410023312.GC27788@x200.localdomain>
	<20090410085305.GC17962@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090410085305.GC17962-X9Un+BFzKDI@public.gmane.org> (Ingo Molnar's message of "Fri\,
	10 Apr 2009 10\:53\:05 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> writes:

> * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> Commit 925d1c401fa6cfd0df5d2e37da8981494ccdec07 aka "procfs task 
>> exe symlink". introduced struct mm_struct::exe_file and struct 
>> mm_struct::num_exe_file_vmas.
>> 
>> The rationale is weak: unifying MMU and no-MMU version of 
>> /proc/*/exe code. For this a) struct mm_struct becomes bigger, b) 
>> mmap/munmap/exit become slower, c) patch adds more code than 
>> removes in fact.
>
> Hm, nommu unification was not the only effect of that original 
> patch.
>
> The other effect was to introduce a managed 'which is the first 
> executable vma in the mm' abstraction in struct mm. Your patch 
> removes that abstraction and re-introduces a linear ->vma_next walk:
>
>> +	down_read(&mm->mmap_sem);
>> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>> +		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
>
> Which can walk along thousands (or tens of thousands) of vmas until 
> it finds the first executable vma. For example on PIE binaries it's 
> quite possible to have a lot of non-PROT_EXEC vmas before the first 
> EXEC vma is met.
>
> So your revert reintroduces that linear walk. It might not matter 
> much (/proc/*/exe might be sufficiently uninteresting in practice to 
> not deserve an optimization), but it's still worth a mention and a 
> discussion in the changelog.

There is also Andrew Morton's suggestion of just keeping a struct path
in mm_struct instead of struct file.  That should be the best of both
worlds.


Eric
