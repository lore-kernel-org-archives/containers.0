From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/6] c/r: [pty 1/2] allow allocation of desired pty	slave
Date: Tue, 08 Sep 2009 09:19:03 -0400
Message-ID: <4AA659C7.5020700@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-3-git-send-email-orenl@librato.com>
	<20090904152644.GA15253@us.ibm.com>
	<20090908080944.GP12824@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090908080944.GP12824-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On 04/09/09 10:26 -0500, Serge E. Hallyn wrote:
>> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>> During restart, we need to allocate pty slaves with the same
>>> identifiers as recorded during checkpoint. Modify the allocation code
>>> to allow an in-kernel caller to request a specific slave identifier.
>>>
>>> For this, add a new field to task_struct - 'required_id'. It will
>>> hold the desired identifier when restoring a (master) pty.
>>>
>>> The code in ptmx_open() will use this value only for tasks that try to
>>> open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
>>> isn't CKPT_REQUIRED_NONE (-1).
>> So noone has indicated any preference for this versus the ptmx_create()
>> approach...
>>
>> I'm satisfied knowing we have a working fallback in case task->required_id
>> is deemed unacceptable.
>>
>> However I'd like to not have linux-kernel folks think us morons for not
>> having considered that.  Can you add a message to the changelog saying
>> why we're going with this approach (namely, that it lets us re-use
>> filp_open() instead of having to do a custom alloc_file in a new code-path,
>> which introduces maintenance duplication for file permission checking
>> paths)?
> 
> As far as I am concerned, I do have a preference for the ptmx_create()
> approach. This task->required_id field reminds me the former approach taken for
> restarting pids and (and SYSV IPC ids IIRC) from userspace, that was proposed
> last year and actually deemed unacceptable [ IIRC, this was an argument in favor
> of a restart() syscall ]. I know that it's not the same since ->required_id is
> not set from userspace and used in a later syscall, but still ...
> 
> Moreover I see no reason whey there would be no way to refactorize ptmx code and
> have less duplicated code with the ptmx_create() approach.

I basically agree - I simply took the easiest/fastest path; if the ptmx
code is properly refactored, we should use that instead.

Did you have a chance to look at Serge's attempt to do exactly that ?
https://lists.linux-foundation.org/pipermail/containers/2009-September/020363.html

Thanks,

Oren.
