From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: restarting tests/sleep
Date: Mon, 9 Jun 2008 11:23:09 -0500
Message-ID: <20080609162309.GA32120@us.ibm.com>
References: <484D2E7C.4060905@bull.net> <20080609143626.GA23253@us.ibm.com>
	<484D4364.2080509@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <484D4364.2080509-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nadia Derbey (Nadia.Derbey-6ktuUTfB/bM@public.gmane.org):
> Serge E. Hallyn wrote:
>> Can you check your /var/log/messages for a 'protection fault' message?
>> Then, if there is one for 'sleep', run gdb on sleep, take the IP in
>> the protection fault msg, and do 'x/10 0x8005cd0' or whatever the
>> address is?
>
> No, I'm not getting a protection fault, and I've got nothing generated  
> in the /var/log/messages. But when I reran the test to check what you're  
> asking me to, I didn't reach the same point: I'm not reaching the [vdso]  
> restoring. I'm getting an EFAULT. Here are the last lines from the 
> output:
>
> =====
> DEBUG (cr.c::923) next memseg_t is: start bfd99000 end bfdae000 prot 3  
> flag 50 offset 3221139456 fnam [stack]
> DEBUG (cr.c::969) Delete segment bfc96000 - bfcab000
> DEBUG (cr.c::971) Restore segment bfd99000 - bfdae000
> [1 cr.c:972 restore_mem()] inj_func(ic, inj_readbuf, 3, remfd,  
> memseg->start, memseg->end - memseg->start) : -14
> ERROR (cr.c:926) unexpected item name: '' (size=0)
> =====

Yeah that's insurmountable - notice the stack in the process which was
fork()ed to be the restarted process topped at bfcab000, while the
checkpointed stack topped at bfdae000.  You're not allowed to write
above the stack.  So the only things to do are

	1. keep trying the restart in the hopes you get a task with
	   stack topping at or above bfdae000
	2. if the checkpointed stack is too high to be likely to be
	   restartable, generate a new checkpoint image and you
	   should get a lower stack top.

(Dave, maybe you had other ideas I haven't considered)

Good thing cryo is just a proof of concept to exploit the kernel code :)

thanks,
-serge
