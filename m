From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Wed, 27 Jan 2010 16:13:34 -0500
Message-ID: <4B60AC7E.2010908@cs.columbia.edu>
References: <20100127071636.GA16624@us.ibm.com>
	<Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
	<20100127201037.GA23119@us.ibm.com>
	<4B60A763.4030806@cs.columbia.edu>
	<20100127211052.GA27579@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100127211052.GA27579-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>> Cool !
>>>>
>>>> So what do we have working now for 64 bit kernel (for 32 bit kernel
>>>> we know it works...):
>>>>
>>>> 	'restart'	checkpointed
>>>> 	 program	  program
>>>> 	----------------------------------------
>>>> 	  64bit		  64bit		-> works
>>>> 	  32bit		  32bit		-> works
>>>>
>>>> 	  64bit		  32bit		-> ?????
>>> Actually the other way around works - /bin/restart_32 < 64bit.out
>>> works just fine.  /bin/restart_64 < 32bit.out does not.  The reason
>>> is that destroy_mm() ends up calling do_munmap on a 64-bit mapping
>>> after the switch to 32-bit had been made, and it refuses bc
>>> vma->vm_start > TASK_SIZE.
>>>
>>> Perhaps getting it to work will be as simple as temporarily switching
>>> back to 64-bit during destroy_mm().
>> Interesting, I didn't think about it.
>>
>> So yes, switching temporarily should work. An alternative we can
>> do the call destroy_mm() earlier, as it may suit us.
>>
>>>> Does it make sense to allow the opposite transition: 'restart' starts
>>>> as a 32bit and becomes a 64bit after it restores the state from the
>>>> image ?
>>>>
>>>> And what about if you checkpoint on a 32 bit kernel and try to 
>>>> restart on a 64 bit kernel, and vice versa ?  (in both cases, the
>>>> program of course is 32bit, and we can assume same physical host
>>>> for now). 
>>> I have no hw right now where I could test such a thing.  Do you?
>>>
>> Couldn't you use the same machine you are using - just reboot it
>> between checkpoint and restart with a 32bit kernel ... ?
> 
> maybe - but i'm borrowing this machine (with no phys access) so don't
> want to get too risky :)
> 
> can give it a shot i guess
> 

Or you can run the 32bit kernel inside a VM on that machine...
