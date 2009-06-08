From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/restart of robust futex lists
Date: Mon, 08 Jun 2009 12:31:31 -0400
Message-ID: <4A2D3CE3.6030400@cs.columbia.edu>
References: <20090603041919.GO9285@us.ibm.com>
	<4A2C7972.9090404@cs.columbia.edu>
	<20090608140810.GB29432@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090608140810.GB29432-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Matt Helsley wrote:
>>>     Save and restore the [compat_]robust_list member of the task struct.
>>>     
>>>     These lists record which futexes the task holds. To keep the overhead of
>>>     robust futexes low the list is kept in userspace. When the task exits the
>>>     kernel carefully walks these lists to recover held futexes that
>>>     other tasks may be attempting to acquire with FUTEX_WAIT.
>>>     
>>>     Because they point to userspace memory that is saved/restored by
>>>     checkpoint/restart saving the list pointers works.
>>>     
>>>     While saving the pointers works during checkpoint, restart is tricky
>>>     because the robust futex ABI contains provisions for changes based on
>>>     checking the size of the list head. So we need to save the length of
>>>     the list head too in order to make sure that the kernel used during
>>>     restart is capable of handling that ABI. Since there is only one ABI
>>>     supported at the moment taking the list head's size is simple. Should
>>>     the ABI change we will need to use the same size as specified during
>>>     sys_set_robust_list() and hence some new means of determining the length
>>>     of this userspace structure in sys_checkpoint would be required.
>>>     
>>>     Rather than rewrite the logic that checks and handles the ABI we reuse
>>>     sys_set_robust_list() by factoring out the body of the function and
>>>     calling it during restart.
>>>     
>>>     Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Patch looks good. Too bad we don't support futex, yet...
> 
> ?
> 
> IIUC (from Matt and Dave), after this patch, you might need something
> for PI futexes, but otherwise non-contended cases "just work" because
> there is no kernel involvement.

That's what I thought. But I also thought that a checkpoint would
fail anyway as soon as it hits the futex-file-descriptor. Or am I
missing something ?

Oren.
