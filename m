From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Thu, 30 Apr 2009 11:14:12 -0400
Message-ID: <49F9C044.8040907@cs.columbia.edu>
References: <20090424210608.GA16973@us.ibm.com>
	<20090425083908.GA2767@us.ibm.com>
	<20090430145735.GA19684@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090430145735.GA19684-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> On Fri, Apr 24, 2009 at 04:06:08PM -0500, Serge E. Hallyn wrote:
> 
> Thanks for taking a look, Matt.  Oren has done some nice work to it
> in his ckpt-v14, please take a look there.
> 
>>> +	cnt = ref->users + 1;
>> Perhaps this switch is another candidate for an fops-style function pointer.
> 
> Yup, Oren did that :)
> 
>>> +static int cr_check_leaks(struct cr_ctx *ctx)
>> What are "leaks" ? ;)
>>
>> How about cr_find_ref_leaks ? I suggest "find" because "check" confuses with
>> "checkpoint". "ref" because we're not looking for memory leaks.
> 
> Oren renamed it to ckpt_obj_contained()
> 
> ...
> 
>>>  	mm = get_task_mm(t);
>>>
>> Might add a check for exe_file == NULL here too (see below).
> 
> Hmm, I think it's ok to store a NULL pointer in the objhash...

It's theoretically ok to store a NULL pointer, but then - it must be the
only one, because the next lookup of any NULL will find that one ...

So in general, it's an excellent practice to avoid NULL pointer (note
the singular form!) in the objhash. In this case, the caller instead
sets objref = 0, which indicates to the restart that the original pointer
was NULL.

Anyway, this specific concern is fixed already as the current patch tests
for NULL before doing anything.

> 
> ...
> 
>>> +	if (!exe_file) {
>>> +		/* really it can't be the case that it NOT be NULL... */
>> This comment isn't correct. Yes, *most* of the time exe_file should be
>> non-NULL. 
> 
> You misread the comment, though you're right about the code.
> 
> The comment says it can't be the case that it *not* be NULL here.
> That's because the object can't be in the objhash yet, because it always
> comes after the main mm entry in the layout.
> 
>> Some tools avoid pinning the filesystem with a reference to its executable file
>> by copying the executable into private, anonymous, executable pages,
>> and then unmaping the originals. This drops the last VMA reference to the
>> file which causes the exe_file reference to be dropped as well.
>>
>> It may provide an interesting testcase for checkpoint/restart since it
>> would mean the executable couldn't be mapped from a checkpointed file --
>> we'd have to rely solely on VMA reconstruction for these.
> 
> Yeah, taking another look I don't handle the restart case where exe_file
> is NULL.  (It won't harm the kernel, just return an error from
> checkpoint I believe)

Handled in my code, though :)

> 
> How does a userspace tool do that though?  Once the file has been
> exec()d, userspace doesn't have an open fd to the executable anymore...
> Can you explain how it's done, and/or send me a testcase?
> 

Hmmm... IIUC from the text above then:

	ptr = mmap(NULL, size, MMAP_EXEC | ... )
	memcpy(ptr, src, size);
	mremap(src, size, size, MREMAP_FIXED | ..., ptr);

?

(or use other trick to avoid having to relocate all the code)

Oren.


>>>  /* cr_ctx: flags */
>>> -#define CR_CTX_CKPT	0x1
>>> -#define CR_CTX_RSTR	0x2
>>> +#define CR_CTX_CKPT		0x1
>>> +#define CR_CTX_RSTR		0x2
>>> +#define CHECKPOINT_SUBTREE	0x4
>> The whitespace change somewhat obscures the introduction of the flag here.
> 
> True.  Guess that could've been a separate tiny patch.
> 
> thanks,
> -serge
> 
