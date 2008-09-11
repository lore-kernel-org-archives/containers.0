From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 5/9] Memory managemnet (restore)
Date: Thu, 11 Sep 2008 03:37:42 -0400
Message-ID: <48C8CAC6.3090209__3963.23617683283$1221118968$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0809040404060.5982@takamine.ncl.cs.columbia.edu>	
	<1220551683.23386.32.camel@nimitz>
	<48C345D2.1020603@cs.columbia.edu>	
	<1220892596.23386.166.camel@nimitz>
	<48C6113A.3080804@cs.columbia.edu>
	<1221082922.6781.62.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221082922.6781.62.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2008-09-09 at 02:01 -0400, Oren Laadan wrote: 
>>> Have you looked at mprotect_fixup()?  It deals with two things:
>>> 1. altering the commit charge against RSS if the mapping is actually
>>>    writable.
>>> 2. Merging the VMA with an adjacent one if possible
>>>
>>> We don't want to do either of these two things.  Even if we do merge the
>>> VMA, it will be a waste of time and energy since we'll just re-split it
>>> when we mprotect() again.
>> Your observation is correct; I chose this interface because it's really
>> simple and handy. I'm not worried about the performance because such VMAs
>> (read only but modified) are really rare, and the code can be optimized
>> later on.
> 
> The worry is that it will never get cleaned up, and it is basically
> cruft as it stands.  People may think that it is here protecting or
> fixing something that it is not.

Let me start with the bottom line - since this creates too much confusion,
I'll just switch to the alternative: will use get_user_pages() to bring
pages in and copy the data directly. Hopefully this will end the discussion.

(Note, there there is a performance penalty in the form of extra data copy:
instead of reading data directly to the page, we instead read into a buffer,
kmap_atomic the page and copy into the page).

> 
>>>>>> +	/* restore original protection for this vma */
>>>>>> +	if (!(cr_vma->vm_flags & VM_WRITE))
>>>>>> +		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
>>>>>> +
>>>>>> + out:
>>>>>> +	return ret;
>>>>>> +}
>>>>> Ugh.  Is this a security hole?  What if the user was not allowed to
>>>>> write to the file being mmap()'d by this VMA?  Is this a window where
>>>>> someone could come in and (using ptrace or something similar) write to
>>>>> the file?
>>>> Not a security hole: this is only for private memory, so it never
>>>> modifies the underlying file. This is related to what I explained before
>>>> about read-only VMAs that have modified pages.
>>> OK, so a shared, read-only mmap() should never get into this code path.
>>> What if an attacker modified the checkpoint file to pretend to have
>>> pages for a read-only, but shared mmap().  Would this code be tricked?
>> VMAs of shared maps (IPC, anonymous shared) will be treated differently.
>>
>> VMAs of shared files (mapped shared) are saved without their contents,
>> as the contents remains available on the file system !  (yes, for that
>> we will eventually need file system snapshots).
>>
>> As for an attack that provides an altered checkpoint image: since we
>> (currently) don't escalate privileges, the attacker will not be able
>> to modify something that it doesn't have access to in the first place.
> 
> I bugged Serge about this.  He said that this, at least, bypasses the SE
> Linux checks that are normally done with an mprotect() system call.
> That's a larger design problem that we need to keep in mind: we need to
> be careful to keep existing checks in place.

I also discussed this with Serge, and I got the impression that he
agreed that there was no security issue because it was all and only
about private memory.

> 
>>>> The process is restarting, inside a container that is restarting. All
>>>> tasks inside should be calling sys_restart() (by design) and no other
>>>> process from outside should be allowed to ptrace them at this point.
>>> Are there plans to implement this, or is it already in here somehow?
>> Once we get positive responses about the current patchset, the next
>> step is to handle multiple processes: I plan to extend the freezer
>> with two more state for this purpose (dumping, restarting).
> 
> OK, but I just asked you why a ptrace() of a process during this
> elevated privilege operation couldn't potentially do something bad.  You
> responded that, by design, we can't ptrace things.  The design is all
> well and good, but the patch isn't, because it doesn't implement that
> design. :(  Before we get these merged, that needs to get resolved.

If a task is ptraced, then the tracer can easily arrange for the tracee
to call mprotect(), or to call sys_restart() with a tampered checkpoint
file, or do other tricks. The call to mprotect_fix(), on a private vma,
does not make this any worse. That is why I didn't bother implementing
that bit.

> 
>>>> (In any case, if some other tasks ptraces this task, it can make it do
>>>> anything anyhow).
>>> No.  I'm suggesting that since this lets you effectively write to
>>> something that is not writable, it may be a hole with which to bypass
>>> permissions which were set up at an earlier time.
>> That's a good comment, but here all we are doing here is to modify a
>> privately mapped/anonymous memory.
>>
>>>>> We copy into the process address space all the time when not in its
>>>>> context explicitly.  
>>>> Huh ?
>>> I'm just saying that you don't need to be in a process's context in
>>> order to copy contents into its virtual address space.  Check out
>>> access_process_vm().
>>>
>> That would be the other way to implement the restart. But, since restart
>> executes in task's context, it's simpler and more efficient to leverage
>> copy-to-user().
>> In terms of security, both methods brings about the same end results: the
>> memory is modified (perhaps bypassing the read-only property of the VMA)
> 
> But copy_to_user() is fundamentally different.  It writes *over*
> contents and in to files.  Simulating a fault fills in those pages, but
> it never writes over things or in to files.   Faulting is fundamentally
> safer.

copy_to_user() does not write into a file with private VMAs.
copy_to_user() in our case will always trigger a page fault.
copy_to_user() is faster as it does not require an extra copy.

> 
> Faulting today can also handle populating a memory area with pages that
> appear read-only via userspace.  That's exactly what we're doing here as
> well.
> 
> Anyway, I don't expect that you'll agree with this.  I'll prototype
> doing it the other way at some point and we can compare how both look.

Back to bottom line - whether or not I agree - I already changed the code
to use get_user_pages() and got rid of this controversy.

Oren.
