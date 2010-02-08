From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Mon, 08 Feb 2010 12:40:31 -0500
Message-ID: <4B704C8F.5050403@cs.columbia.edu>
References: <20100127071636.GA16624@us.ibm.com>
	<Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
	<20100127201037.GA23119@us.ibm.com>
	<4B60A763.4030806@cs.columbia.edu>
	<20100127211052.GA27579@us.ibm.com>
	<4B60AC7E.2010908@cs.columbia.edu>
	<20100205233800.GA17057@us.ibm.com>
	<4B6CC00C.2090509@cs.columbia.edu>
	<20100206062650.GG3714@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100206062650.GG3714-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


[snip]

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
>>
>> [2] The last two cases consider the case when the restart program
>> itself has different bit-ness than the checkpointed program (and
>> transition may occur in either direction). While lower priority,
>> we would like this to work, too.
> 
> Great table. Is it posted in the ckpt wiki too?
> 

I updated the wiki:
     http://ckpt.wiki.kernel.org/index.php/Architecture

For powerpc I just assumed it's like x86 ... :)
Can you please approve or modify for archs other than x86-{32,64} ?

Thanks,

Oren.
