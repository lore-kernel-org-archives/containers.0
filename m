From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: ckpt-v19-rc2
Date: Fri, 04 Dec 2009 19:24:16 -0500
Message-ID: <4B19A830.3040703@cs.columbia.edu>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>	<1259875869.8693.30.camel@localhost.localdomain>
	<4B183888.7070103@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B183888.7070103-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Thinking about it further, here are two possible scenarios:

A) Task maps a file beyond it's limit, never touches those
extra page (if it did, it would get EFAULT)

B) Task maps a file and writes the last page, then the file gets
truncated (by at least a page).  The task may continue to access
that extra page since it already became anonymous.

In kernel 2.3.31, FOLL_ANON flags would make follow_page() return
the zero-page for case A. For case B, the actual page is returned.

In kernel 2.3.32, FOLL_ANON is gone. Instead FOLL_DUMP makes
follow_page() return -EFAULT in case A, which we can use to
conclude that the page is not interesting (unmodified). Case B
is handled the same as before.

So checkpoint should work.

Now restart: case A is easy, because mmap() works as before, and
those pages that were never touched will not be restored either,
they will remain untouched.

For case B it may be problematic, since we will start with a map
that goes beyond the current file size (originally it wasn't),
and we will attempt to modify a page in the "forbidden" zone.
I wonder if get_user_page() will respond favorably when restart
requests such a page ?   let's see ...

Oren.


Oren Laadan wrote:
> Oh ... maybe that's what why checkpoint fails on my experimental
> x86-64 port: it worked well on 2.6.31 but fails with "bad address"
> on 2.6.32.
> 
> It may be related to a change between 2.6.31 and 2.6.32 in
> the arguments to follow_page(), see commit:
> 
> 	mm: FOLL_DUMP replace FOLL_ANON
> 	8e4b9a60718970bbc02dfd3abd0b956ab65af231
> 
> ?
> 
> Oren.
> 
> Nathan Lynch wrote:
>> On Wed, 2009-12-02 at 00:23 -0500, Oren Laadan wrote:
>>> I put together ckpt-v19-rc2 (kernel and user)
>> I'm not sure yet whether this is a regression, but checkpoint seems to
>> be unable to handle file mappings that extend past the end of the file.
>> I noticed this with Fedora 11 userspace on powerpc (ld.so sometimes maps
>> libraries this way).  I did not see this failure with a v19-rc1-based
>> kernel I tested earlier this week, but I haven't retested with that yet.
>>
>> Here's an example - 8K mapping of a 4K file:
>>
>> # stat -c%s /tmp/myfile 
>> 4096
>>
>> # grep myfile /proc/5164/maps
>> f7e2b000-f7e2d000 r--p 00000000 08:06 5103709                            /tmp/myfile
>>
>> # checkpoint 5164 > /tmp/mmap.ckpt
>> checkpoint: Bad address
>>
>> When we try to follow the mapping past the end of the file, we get
>> VM_FAULT_SIGBUS from handle_mm_fault(); the stack trace from debugging
>> code I added is:
>>
>> .__get_dirty_page+0x4c/0x164 (unreliable)
>> .checkpoint_memory_contents+0x134/0x5a4
>> .private_vma_checkpoint+0xf4/0x120
>> .filemap_checkpoint+0x198/0x1d0
>> .checkpoint_mm+0x3c4/0x4fc
>> .checkpoint_obj+0x17c/0x1d0
>> .checkpoint_obj_mm+0x50/0x88
>> .checkpoint_task+0x710/0xaa0
>> .do_checkpoint+0x9c0/0xb24
>> .SyS_checkpoint+0xd0/0x11c
>>
>> Attached is a testcase.
>>
>>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
