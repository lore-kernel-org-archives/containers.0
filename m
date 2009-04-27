From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Mon, 27 Apr 2009 18:13:49 -0400
Message-ID: <49F62E1D.20003@cs.columbia.edu>
References: <20090424210608.GA16973@us.ibm.com> <m3vdotk34g.fsf@pobox.com>
	<20090425024515.GA4534@hallyn.com> <m3y6tmt3wb.fsf@pobox.com>
	<20090427180717.GA28476@us.ibm.com>
	<49F61181.9010809@cs.columbia.edu>
	<20090427203858.GA32290@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090427203858.GA32290-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>>> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>>>>> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>>>>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>>>>>>> +	cnt = ref->users + 1;
>>>>>>> +	switch (ref->type) {
>>>>>>> +	case CR_OBJ_UTSNS:
>>>>>>> +		utsns = ref->ptr;
>>>>>>> +		cnt2 = (unsigned long) atomic_read(&utsns->kref.refcount);
>>>>>>> +		if (cnt != cnt2) {
>>>>>>> +			cr_debug("uts namespace leak\n");
>>>>>> I'm struggling to understand what guarantee a check such as this is
>>>>>> supposed to be making.  I see that it will catch *some* undesirable
>>>>>> cases.  But "current refcount equals old refcount" does not imply that
>>>>>> "refcount has not changed in the meantime".
>>>>> It's got nothing to do with the refcounts changing.
>>>>>
>>>>> It ensures that, at the end of the checkpoint, the resources (utsns
>>>>> in this case) had no users not accounted for by a checkpointed task.
>>>>> In other words, there was no information leak.
>>>> Okay, I had mistakenly believed this code was running in the
>>>> subtree/non-container case.  I reread your patch description and it
>>>> indicates that these checks are made only in the case of container
>>>> checkpoint.  If I'm (finally) understanding the patch correctly, my
>>>> concern is lessened.  Comparing refcounts is still... unconventional.
>>> Yes, and there are cases where it won't be usable - for instance if
>>> opening a procfile increments the resource->use count.  That should
>>> not be an issue for utsns, ipcns, files, or vmas, afaik.
>> Actually, one such case is if you have a FIFO - and a task outside the
>> "container" (for whatever definition we choose) opens that FIFO because
>> the right thingie is mounted in its (distinct) mounts namespace.
> 
> That'll affect the CR_OBJ_INODE object, right?  (Not the CR_OBJ_FILE
> one).

Yes.  And the point is that this leak cannot be reliably detected.

... unless you hide FIFO's in the network namespace :o
(no !  I'm no suggesting...)

Oren.

> 
>> Also, unsure if unix domain sockets (those visible through the file
>> system, not the "abstract" type) are otherwise isolated as well ?
> 
> Yes, they are isolated by network namespace, to the chagrin of some
> people.
> 
> -serge
> 
