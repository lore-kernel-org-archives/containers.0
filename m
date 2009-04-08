From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 15/36] c/r of restart-blocks
Date: Tue, 07 Apr 2009 22:24:05 -0400
Message-ID: <49DC0AC5.2010900@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>	<1239107264-21775-16-git-send-email-orenl@cs.columbia.edu>	<87r6042uwm.fsf@caffeine.danplanet.com>	<49DB9F01.4050605@cs.columbia.edu>
	<87myas2sjr.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87myas2sjr.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> +	/* were we from a system call?  if so, get old error/retval */
> OL> +	if (syscall_get_nr(current, regs) >= 0)
> OL> +		ret = syscall_get_error(current, regs);
> 
> OL> The test "were we from a system call ?" is implemented differently
> OL> on the s390, for example. Compare the code in handle_signal(),
> OL> whose logic I follow.
> 
> As far as I can tell, handle_signal() doesn't make that determination
> on s390.  However, do_signal() does:
> 
>   /* Are we from a system call? */
>   if (regs->svcnr) {
> 
> which is identical to the outcome of your code, based on the
> implementation of syscall_get_nr():
> 
>   static inline long syscall_get_nr(struct task_struct *task,
>   				  struct pt_regs *regs)
>   {
>   	return regs->svcnr ? regs->svcnr : -1;
>   }
> 
> Perhaps I need to further study where your function is used to figure
> out what obscure details I'm missing... :)
> 

So my speculation was exactly that - whether or not the code in
{do,handle}_signal() is effectively the same as in the functions
syscall_get_{nr,error}(). I didn't investigate it, but if this
holds true for all architectures, then my code can be safely made
non-arch-dependent (and the arch code for s390 and maybe others
should be fixed to use those functions !).

Oren.
