From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 5/9] Memory managemnet (restore)
Date: Tue, 09 Sep 2008 19:35:06 -0400
Message-ID: <48C7082A.1050608__37116.7442448952$1221003438$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-6-git-send-email-orenl@cs.columbia.edu>
	<20080909160724.GA23397@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080909160724.GA23397-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):

[...]

>> +/* change the protection of an address range to be writable/non-writable.
>> + * this is useful when restoring the memory of a read-only vma */
>> +static int cr_vma_set_writable(struct mm_struct *mm, unsigned long start,
>> +			       unsigned long end, int writable)
>> +{
>> +	struct vm_area_struct *vma, *prev;
>> +	unsigned long flags = 0;
>> +	int ret = -EINVAL;
>> +
>> +	cr_debug("vma %#lx-%#lx writable %d\n", start, end, writable);
>> +
>> +	down_write(&mm->mmap_sem);
>> +	vma = find_vma_prev(mm, start, &prev);
>> +	if (!vma || vma->vm_start > end || vma->vm_end < start)
>> +		goto out;
>> +	if (writable && !(vma->vm_flags & VM_WRITE))
>> +		flags = vma->vm_flags | VM_WRITE;
>> +	else if (!writable && (vma->vm_flags & VM_WRITE))
>> +		flags = vma->vm_flags & ~VM_WRITE;
>> +	cr_debug("flags %#lx\n", flags);
>> +	if (flags)
>> +		ret = mprotect_fixup(vma, &prev, vma->vm_start,
>> +				     vma->vm_end, flags);
> 
> As Dave has pointed out, this appears to be a security problem.  I think

As I replied to Dave, I don't see why this would be a security problem.

This handles private memory only. In particular, the uncommon case of a
read-only VMA tha has modified contents. This _cannot_ affect the file
from which this VMA may have been mapped.

Shared memory (not file-mapped) will be handled differently: since it is
always backed up by an inode in shmfs, the restart will populate the
relevant pages directly. Besides, non-file-mapped shared memory is again
not a security concern.

Finally, shared memory that maps to a file is simply _not saved_ at all;
it is part of the file system, and belongs to the (future) file system
snapshot capability. Since the contents are always available in the file
system, we don't need to save it (like we don't save shared libraries).

That said, it is necessary that the code ensures that the vm_flags that
belong to a VMA of a private type, e.g. CR_VMA_ANON/CR_VMA_FILE, indeed
match it (ie, don't have VM_MAY_SHARE/VM_SHARED). I'll add that.

> what you need to do is create a new helper mprotect_fixup_withchecks(),
> which does all the DAC+MAC checks which are done in the sys_mprotect()
> loop starting with "for (nstart = start ; ; ) {...  Otherwise an
> unprivileged user can create a checkpoint image of a program which has
> done a ro shared file mmap, edit the checkpoint, then restart it and (i
> assume) cause the modified contents to be written to the file.  This
> could violate both DAC checks and selinux checks.
> 
> So create that helper which does the security checks, and use it
> both here and in the sys_mprotect() loop, please.
> 

[...]

Oren.
