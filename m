From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Mon, 08 Feb 2010 09:43:10 -0500
Message-ID: <4B7022FE.4060704@cs.columbia.edu>
References: <20100127071636.GA16624@us.ibm.com>
	<Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
	<20100127201037.GA23119@us.ibm.com>
	<4B60A763.4030806@cs.columbia.edu>
	<20100127211052.GA27579@us.ibm.com>
	<4B60AC7E.2010908@cs.columbia.edu>
	<20100205233800.GA17057@us.ibm.com>
	<4B6CC00C.2090509@cs.columbia.edu>
	<20100206170902.GA20497@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100206170902.GA20497-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>> Serge E. Hallyn wrote:
>>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>>> Serge E. Hallyn wrote:
>>>>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>>>>> Cool !
>>>>>>>>
>>>>>>>> So what do we have working now for 64 bit kernel (for 32 bit kernel
>>>>>>>> we know it works...):
>>>>>>>>
>>>>>>>> 	'restart'	checkpointed
>>>>>>>> 	 program	  program
>>>>>>>> 	----------------------------------------
>>>>>>>> 	  64bit		  64bit		-> works
>>>>>>>> 	  32bit		  32bit		-> works
>>>>>>>>
>>>>>>>> 	  64bit		  32bit		-> ?????
>>> s/?????/Rejected/
>>>
>>> CKPT_ARCH_ID is of course different for X86_32 than X86_64, so
>>> we refuse restart in restore_read_header().
>>>
>>> -serge
>>>
>> lol ... that's actually funny !
>>
>> Anyway, in light of the IRC discussions, here are the cases again:
>>
>>
>> original	original	restart		target
>> program		kernel		program		kernel
>> --------	---------	--------	--------
>> 64 bit		64 bit		64 bit		64 bit	  [0] works
>>
>> 32 bit		32 bit		32 bit		32 bit	  [0] works
>> 32 bit		64 bit		32 bit		64 bit	  [0] works
>>
>> 32 bit		32 bit		32 bit		64 bit	  [1]
>> 32 bit		64 bit		32 bit		32 bit	  [1]
>>
>> 32 bit		any		64 bit		64 bit	  [2]
>> 64 bit		64 bit		32 bit		64 bit	  [2]
>>
>> [0] The first 3 cases are "homogeneous", with conditions equal at
>> checkpoint and restart. AFAIK, they work.
>>
>> [1] The next two cases consider 32 bit program, and vary only the
>> environment - the kernel may change from 32 to 64 or back. We want
>> them to work.
>>
>> IIUC, your comment above means that they don't work because the
>> CKPT_ARCH_ID is a mismatch. The fix should be trivial - either
>> make 'restart' modify it, or make the kernel tolerate it.
> 
> Well, you'd think so, but we also check for uts->machine, and want
> to eventually check for kernel config, both of which are obviously
> different.

Then we'll have to take that in account when we get to also
check those other fields.

> 
> After I comment out the obvious offending checks, it still fails to
> restart from x8632->x86-64.  I can spend some time next week figuring
> out what we're not quite doing right as there shouldn't be a
> problem really.  But do we definately want to go out of our way to try
>  and mask out the differences in this case, while trying to detect
> cpu differences between two x86-32's for instance?

I agree, there shouldn't be a problem really, and I expect this to
be a very useful feature for migration/fault-tolerance.

Checking for differences between CPU's is a separate issue, and is
orthogonal to migration (of 32bit programs) between 32 and 64 bit
kernels.

I tend to answer "yes" - we should eventually refuse restart if we
detect that the "configuration" at restart time differs from that at
checkpoint time "sufficiently".

Now "configuration" is very basic - the architecture. I would like
that to also include cpu features, kernel features, fpu capabilities...
Also "sufficiently" is vaguely defined, because I don't know enough
to describe it more precisely.

Ideally there will be some clever user-space logic that will detect
and make a decision. And, yes, it will take a lot of details...

Oren.
