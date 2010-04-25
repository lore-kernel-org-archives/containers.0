From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/4] Add IPv6 address checkpoint handler
Date: Sun, 25 Apr 2010 16:49:39 -0400
Message-ID: <4BD4AAE3.1040304@cs.columbia.edu>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>	<1270748932-26745-4-git-send-email-danms@us.ibm.com>	<20100412161148.GC23380@us.ibm.com>	<871vekbmen.fsf@caffeine.danplanet.com>
	<20100412174756.GA15269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100412174756.GA15269-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>>> +#ifdef CONFIG_NETNS_CHECKPOING
>> SH> How could that be defined?  :)
>>
>> Hmm, I must have typo'd that after I did all my config testing because
>> otherwise I wouldn't have been able to test checkpointing ipv6 stuff.
>>
>> SH> Again, I'd prefer ckpt_err here.
>>
>> SH> Note that in my last email that really was a q - if you're under
>> SH> spinlock here, then you can't use ckpt_err().
>>
>> Right, the point of this loop was to iterate the list quickly while
>> holding the device lock, so we could write out the results after we
>> release it.
>>
>> I think these two cases (and the ipv4 case) are pretty unlikely to be
>> a problem as they would only be triggered if you actually have
>> active multicast or anycast sessions configured.  This will not
>> trigger for the default addresses.
>>
>> I don't think that dropping the lock to do ckpt_err() would be very
>> pretty, nor would introducing a result string for an error message.
> 
> Agreed.
> 
>> This is plumbed a couple levels deep.
>>
>> Is there some way you see this being handled better?
> 
> Not really...  looks like we're doing what we can at the moment
> then, good enough :)

Actually, you can use _ckpt_err() which can be called under
spinlock, and then the caller should call _ckpt_msg_complete()
after it drops the lock, to flush the message out.

Oren.
