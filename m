From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 13 Mar 2009 12:15:56 -0500
Message-ID: <20090313171556.GB10685@us.ibm.com>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com> <49B99144.9000106@free.fr>
	<877i2upcvo.fsf@caffeine.danplanet.com> <49B996BC.1090908@free.fr>
	<873adipc5l.fsf@caffeine.danplanet.com>
	<49B999A6.2000005@free.fr> <20090313153004.GA8317@us.ibm.com>
	<49BA811C.4070302@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49BA811C.4070302-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Serge E. Hallyn wrote:
>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>>   
>>> Dan Smith wrote:
>>>     
>>>> DL> I guess it will be esay to implement with a nsproxy level counter.
>>>> DL> Each time you unshare, the new nsproxy count is incremented.
>>>> DL> Assuming the init_nsproxy is level 0, when the nsproxy counter is
>>>> DL> > 1, the process is uncheckpointable.
>>>>
>>>> This should also be possible by just making sure that the nsproxy of
>>>> the root process being checkpointed is the same as any of the
>>>> children, correct?  That way we avoid having to modify the core
>>>> nsproxy bits and can still reject any nested namespaces.
>>>>         
>>> Right, this is another option. The nsproxy counter will allow to flag 
>>> at runtime a process to be uncheckpointable. The nsproxy comparison 
>>> will detect nested nsproxies at checkpoint time.
>>>     
>>
>> Or, to stick more to the resource->may_checkpoint way of doing it, you
>> setbit(&nsproxy->uts_ns->may_checkpoint, 0) when the uts_ns is
>> created, and anytime a task does clone(CLONE_NEWUTS) or
>> unshare(CLONE_NEWUTS), you clear the bit on the parent uts_ns.
>>   
> Hmm, you will need to add a back pointer for the nsproxy | utsns parent,  
> no ?

Why?

> What I was proposing is a counter directly in the nsproxy. Maybe instead  
> of initializing it to zero, it can be initialized to the max supported  
> nested level ( only one right now) and decrement each time a clone or a  
> unshare is done whatever the namespace.
>
> init nsproxy->may_checkpoint = 2
> First clone | unshare => for the new nsproxy the counter may_checkpoint  
> becomes 1

I don't understand why it gets decremented twice before not being
checkpointable - or do you mean that by the time the nsproxy is
useful it will be 1?   2 is basically an init-only unused phase?

> Second clone | unshare (forbidden) => may_checkpoint becomes 0

Ok but if I

	unshare(CLONE_NEWNS)

I'll get a new nsproxy with an old uts_ns.  So we'll need
some (potentially complicated) logic at nsproxy creation to
decide whether the namespaces being cloned or not being cloned
impact the checkpointability of the new nsproxy...

Hmm.  I think I prefer making sure that the uts_ns is the
same for all checkpointed tasks :)

-serge
