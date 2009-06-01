From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 7/7] Define clone_with_pids syscall
Date: Mon, 01 Jun 2009 12:54:10 -0400
Message-ID: <4A2407B2.8030304@cs.columbia.edu>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000350.GF4191@us.ibm.com>
	<20090601151650.GA20295@us.ibm.com>
	<4A240213.70001@cs.columbia.edu>
	<20090601164232.GA23252@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090601164232.GA23252-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> The two issues are related, and this is intentional. The idea
>> was that when you use CLONE_NEWPID, you imply a new nesting level
>> and a pid==1 there. So you are not supposed to specify the pid
>> of that new level.
>>
>> IOW, the parent specify the pid's of the child from the _parent's_
>> level and up (of the desired depth). CLONE_NEWPID creates a new
>> pidns level below the parent's, and that is not covered in the
>> array of pids.
>>
>> By allocation an extra slot and forcing it to be 0, we ensure that
>> the case of CLONE_NEWPID is covered correctly. Clearly, if this
>> flag isn't set, then the extra slot is redundant (but doesn't hurt).
> 
> Ok, I see - I guess I don't mind those semantics.  So:
> 
>>>> +	j = knum_pids - unum_pids;
>>>         j = 1, so we copy the 3 pids in the right place.
>>>
>>>> +	rc = copy_from_user(&target_pids[j], pid_set.target_pids, size);
>>>> +	if (rc) {
>>>> +		rc = -EFAULT;
>>>> +		goto out_free;
>>>> +	}
>>>> +
>>>> +	return target_pids;
>>>
>>> For the second one, we have a parent task
>>>
>>> level no       |     pid
>>> 0                   5009
>>> 1                   1000
>>> 2                    49
>>>
>>> calling clone_with_pid with CLONE_NEWPID and {1001,50,1} to produce:
>>>
>>> level no       |     pid
>>> 0                   5010
>>> 1                   1001
>>> 2                    50
>>> 3                    1
>>>
>>> So the numbers in your code become:
>>>
>>>> +	unum_pids = pid_set.num_pids;
>>>         unum_pids = 3
>> This is a "bug" of the parent. The parent should specify the pids
>> from the parent's level only and up, and not include the new level
>> below that will be created. (After all, it will have to be 1).
>>
>> So unum_pids = 3 will not do what you want; instead it will try to
>> create the process:
>>
>> 0	1001
>> 1	50
>> 2	1
>> 3	1
>>
>> And will fail, of course, because pid==1 at level 2 is already
>> taken.
>>
>> Instead, parent should say use {1001, 50}.
> 
> Ok, but then we have the task:
> 
> level no       |     pid
> 0                   5009
> 1                   1000
> 2                    49
> 
> calling clone(CLONE_NEWPID) with unum_pids = 2, so
> 
>>>> +	knum_pids = task_pid(current)->level + 1;
>>>         knum_pids = 2 + 1 = 3
>>>
>>>> +	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);
>>>         target_pids gets room for 4 pids
>>>
>>>> +	j = knum_pids - unum_pids;
> 
> j = 3 - 2 = 1, so we copy 1001 into pid[1] and
> 50 into pid[2], with 0 in pid[0] and pid[3]
> 
> Looks good.  Thanks for indulging me :)
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> One last thought - should there be an explicit check to make sure that
> if CLONE_NEWPID, then at the end pid[knum_pids+1] = 0?  Or is that
> there and I just missed it?

the wonders of kzalloc() ...

Oren.
