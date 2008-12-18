From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
Date: Thu, 18 Dec 2008 15:11:02 -0500
Message-ID: <494AAE56.6010704__34847.4133680158$1229631195$gmane$org@cs.columbia.edu>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	<1228498282-11804-6-git-send-email-orenl@cs.columbia.edu>
	<4949B4ED.9060805@google.com> <494A2F94.2090800@cs.columbia.edu>
	<494A9350.1060309@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <494A9350.1060309-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linux Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org



Mike Waychison wrote:
> Oren Laadan wrote:
>>
>> Mike Waychison wrote:
>>> Comments below.
>>
>> Thanks for the detailed review.
>>
>>> Oren Laadan wrote:
>>>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>>>> it will be followed by the file name. Then comes the actual contents,
>>>> in one or more chunk: each chunk begins with a header that specifies
>>>> how many pages it holds, then the virtual addresses of all the dumped
>>>> pages in that chunk, followed by the actual contents of all dumped
>>>> pages. A header with zero number of pages marks the end of the
>>>> contents.
>>>> Then comes the next VMA and so on.
>>>>
>>
>> [...]
>>
>>>> +    mutex_lock(&mm->context.lock);
>>>> +
>>>> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
>>>> +    hh->nldt = mm->context.size;
>>>> +
>>>> +    cr_debug("nldt %d\n", hh->nldt);
>>>> +
>>>> +    ret = cr_write_obj(ctx, &h, hh);
>>>> +    cr_hbuf_put(ctx, sizeof(*hh));
>>>> +    if (ret < 0)
>>>> +        goto out;
>>>> +
>>>> +    ret = cr_kwrite(ctx, mm->context.ldt,
>>>> +            mm->context.size * LDT_ENTRY_SIZE);
>>> Do we really want to emit anything under lock?  I realize that this
>>> patch goes and does a ton of writes with mmap_sem held for read -- is
>>> this ok?
>>
>> Because all tasks in the container must be frozen during the checkpoint,
>> there is no performance penalty for keeping the locks. Although the
>> object
>> should not change in the interim anyways, the locks protects us from,
>> e.g.
>> the task unfreezing somehow, or being killed by the OOM killer, or any
>> other change incurred from the "outside world" (even future code).
>>
>> Put in other words - in the long run it is safer to assume that the
>> underlying object may otherwise change.
>>
>> (If we want to drop the lock here before cr_kwrite(), we need to copy the
>> data to a temporary buffer first. If we also want to drop mmap_sem(), we
>> need to be more careful with following the vma's.)
>>
>> Do you see a reason to not keeping the locks ?
>>
> 
> I just thought it was a bit ugly, but I can't think of a case
> specifically where it's going to cause us harm.  If tasks are frozen,
> are they still subject to the oom killer?   Even that should be
> reasonably ok considering that the exit-path requires a
> down_read(mmap_sem) (at least, it used to..  I haven't gone over that
> path in a while..).

Excatly: this is safe because we keep the lock. It all boils down to
two points: holding the locks doesn't impair performance or functionality,
and it protects us against existing (if any) and future undesired
interactions with other code.

[...]

Oren.
