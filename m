From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4] Object creation with a specified id
Date: Fri, 14 Mar 2008 12:02:46 -0400
Message-ID: <47DAA1A6.6010509@cs.columbia.edu>
References: <20080310135054.312992000@bull.net>
	<47D9B5B7.6060803@cs.columbia.edu> <47DA195B.8070704@bull.net>
	<47DA9EB5.8040704@cs.columbia.edu> <47DAA041.9090009@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47DAA041.9090009-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Pavel Emelyanov wrote:
> Oren Laadan wrote:
>> Nadia Derbey wrote:
>>> Oren Laadan wrote:
>>>> Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
>>>>
>>>>> A couple of weeks ago, a discussion has started after Pierre's 
>>>>> proposal for
>>>>> a new syscall to change an ipc id (see thread
>>>>> http://lkml.org/lkml/2008/1/29/209).
>>>>>
>>>>>
>>>>> Oren's suggestion was to force an object's id during its creation, 
>>>>> rather
>>>>> than 1. create it, 2. change its id.
>>>>>
>>>>> So here is an implementation of what Oren has suggested.
>>>>>
>>>>> 2 new files are defined under /proc/self:
>>>>>   . next_ipcid --> next id to use for ipc object creation
>>>>>   . next_pids --> next upid nr(s) to use for next task to be forked
>>>>>                   (see patch #2 for more details).
>>>> Generally looks good. One meta-comment, though:
>>>>
>>>> I wonder why you use separate files for separate resources, 
>>> That would be needed in a situation wheere we don't care about next, 
>>> say, ipc id to be created but we need a predefined pid. But I must admit 
>>> I don't see any pratical application to it.
>> exactly; why set the next-ipc value so far in advance ?  I think it's
>> better (and less confusing) if we require that setting the next-id value
>> be done right before the respective syscall.
> 
> And race with some other syscall caller? This will only work if the next-ipc-id
> and the next-pid are on a task_struct. Are they (at least supposed to be such)?

yes. that's the first detail I looked for in the patch :)
