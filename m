From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 1/5] ima: extend clone() with IMA namespace support
Date: Fri, 9 Mar 2018 08:52:42 -0500
Message-ID: <ec137677-34f8-df91-0d1c-6c6d6c951496@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<20170725175317.GA727@mail.hallyn.com>
	<1501008554.3689.30.camel@HansenPartnership.com>
	<20170725190406.GA1883@mail.hallyn.com>
	<1501009739.3689.33.camel@HansenPartnership.com>
	<1501012082.27413.17.camel@linux.vnet.ibm.com>
	<645db815-7773-e351-5db7-89f38cd88c3d@linux.vnet.ibm.com>
	<20170725204622.GA4969@mail.hallyn.com>
	<97839865-b0ab-8e5d-114e-0603ef2edf6f@linux.vnet.ibm.com>
	<20180309025942.GA15295@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180309025942.GA15295-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/08/2018 09:59 PM, Serge E. Hallyn wrote:
> On Thu, Mar 08, 2018 at 09:04:52AM -0500, Stefan Berger wrote:
>> On 07/25/2017 04:46 PM, Serge E. Hallyn wrote:
>>> On Tue, Jul 25, 2017 at 04:11:29PM -0400, Stefan Berger wrote:
>>>> On 07/25/2017 03:48 PM, Mimi Zohar wrote:
>>>>> On Tue, 2017-07-25 at 12:08 -0700, James Bottomley wrote:
>>>>>> On Tue, 2017-07-25 at 14:04 -0500, Serge E. Hallyn wrote:
>>>>>>> On Tue, Jul 25, 2017 at 11:49:14AM -0700, James Bottomley wrote:
>>>>>>>> On Tue, 2017-07-25 at 12:53 -0500, Serge E. Hallyn wrote:
>>>>>>>>> On Thu, Jul 20, 2017 at 06:50:29PM -0400, Mehmet Kayaalp wrote:
>>>>>>>>>> From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>>>>>>>>
>>>>>>>>>> Add new CONFIG_IMA_NS config option.  Let clone() create a new
>>>>>>>>>> IMA namespace upon CLONE_NEWNS flag. Add ima_ns data structure
>>>>>>>>>> in nsproxy. ima_ns is allocated and freed upon IMA namespace
>>>>>>>>>> creation and exit. Currently, the ima_ns contains no useful IMA
>>>>>>>>>> data but only a dummy interface. This patch creates the
>>>>>>>>>> framework for namespacing the different aspects of IMA (eg.
>>>>>>>>>> IMA-audit, IMA-measurement, IMA-appraisal).
>>>>>>>>>>
>>>>>>>>>> Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>>>>>>>>
>>>>>>>>>> Changelog:
>>>>>>>>>> * Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
>>>>>>>>> Hi,
>>>>>>>>>
>>>>>>>>> So this means that every mount namespace clone will clone a new
>>>>>>>>> IMA namespace.  Is that really ok?
>>>>>>>> Based on what: space concerns (struct ima_ns is reasonably small)?
>>>>>>>> or whether tying it to the mount namespace is the correct thing to
>>>>>>>> do.  On
>>>>>>> Mostly the latter.  The other would be not so much space concerns as
>>>>>>> time concerns.  Many things use new mounts namespaces, and we
>>>>>>> wouldn't want multiple IMA calls on all file accesses by all of
>>>>>>> those.
>>>>>>>
>>>>>>>> the latter, it does seem that this should be a property of either
>>>>>>>> the mount or user ns rather than its own separate ns.  I could see
>>>>>>>> a use where even a container might want multiple ima keyrings
>>>>>>>> within the container (say containerised apache service with
>>>>>>>> multiple tenants), so instinct tells me that mount ns is the
>>>>>>>> correct granularity for this.
>>>>>>> I wonder whether we could use echo 1 > /sys/kernel/security/ima/newns
>>>>>>> as the trigger for requesting a new ima ns on the next
>>>>>>> clone(CLONE_NEWNS).
>>>>>> I could go with that, but what about the trigger being installing or
>>>>>> updating the keyring?  That's the only operation that needs namespace
>>>>>> separation, so on mount ns clone, you get a pointer to the old ima_ns
>>>>>> until you do something that requires a new key, which then triggers the
>>>>>> copy of the namespace and installing it?
>>>>> It isn't just the keyrings that need to be namespaced, but the
>>>>> measurement list and policy as well.
>>>>>
>>>>> IMA-measurement, IMA-appraisal and IMA-audit are all policy based.
>>>>>
>>>>> As soon as the namespace starts, measurements should be added to the
>>>>> namespace specific measurement list, not it's parent.
>>> Shouldn't it be both?
>>>
>>> If not, then it seems to me this must be tied to user namespace.
>>>
>>>> IMA is about measuring things, logging what was executed, and
>>>> finally someone looking at the measurement log and detecting
>>>> 'things'. So at least one attack that needs to be prevented is a
>>>> malicious person opening an IMA namespace, executing something
>>>> malicious, and not leaving any trace on the host because all the
>>>> logs went into the measurement list of the IMA namespace, which
>>>> disappeared. That said, I am wondering whether there has to be a
>>>> minimum set of  namespaces (PID, UTS) providing enough 'isolation'
>>>> that someone  may actually open an IMA namespace and run their code.
>>>> To avoid leaving no traces one could argue to implement recursive
>>>> logging, so something that is logged inside the namespace will be
>>>> detected in all parent containers up to the init_ima_ns (host)
>>>> because it's logged (and TPM extended) there as well. The challenge
>>>> with that is that logging costs memory and that can be abused as
>>>> well until the machine needs a reboot... I guess the solution could
>>>> be requesting an IMA namespace in one way or another but requiring
>>>> several other namespace flags in the clone() to actually 'get' it.
>>>> Jumping namespaces with setns() may have to be restricted as well
>>>> once there is an IMA namespace.
>>> Wait.  So if I create a new IMA namespace, the things I run in
>>> that namespace are not subject to the parent namespace policy?
>> We'll let an IMA namespace set its own policy and rules in that
>> policy will decide whether the child namespaces' measurements will
>> also be logged. This is to avoid a potentially huge log on the host.
>> However, the activities of root in namespaces may need to be logged
>> independently of what the policy rules say so that root's activities
>> in the TCB will always be tracked also if he operates in a temporary
>> mount/IMA namespace pair (and sharing the rest of the namespaces
>> with the host).
> Thanks, Stefan.  Is there a particular paper where I can get a good
> idea of what is and is not part of the goals and threat model here?
Yuqiong is publishing a paper in this area. I believe the conference is 
only later this year.

Our goals are to enable IMA measurements, appraisal, and auditing inside 
a container using namespaces. IMA measurements are about logging files 
that were read or executables that were started on a machine, appraisal 
is about locking down the machine and only allowing files to be accessed 
that have been properly signed. We certainly want to prevent the abuse 
of namespaces by users to do things that go undetected. A primary 
concern are activities of root in the TCB.

Support for IMA in namespaces should enable the following:

- IMA policy for container (similar to the host):
   - there should be an initial default policy for every IMA namespace 
that measures activities inside the container
   - the policy can be overwritten once with a user-defined policy that 
may activate appraisal

- IMA policy extensions due to namespacing:
   - an IMA policy should allow rules that define whether activities in 
(all) child namespaces is to be measured (prevents huge logs on the host)
   - to prevent root from spawning new IMA namespaces and doing things 
undetected in the TCB, all activities of root are (recursively) measured 
in all IMA namespaces independent of whether the policy enables logging 
in child namespaces

- IMA appraisal and keys:
   - each IMA namespace should have its own keyring so that each 
container can have its files signed with different keys
   - it should be possible to enforce that only certified keys are 
loaded onto a keyring, similar to .ima on the host

- IMA auditing:
   - auditing should report activity in namespaces following the IMA 
policy; root's activities in containers should be audited

- TPM and measurements:
   - The IMA namespace that holds the logs should be configurable to 
extend PCRs; since the single TPM of the host cannot be shared by 
containers, each IMA namespace would have to be associated with its own 
TPM instance (vTPM); measurement on the initial IMA namespace are 
extended into the hardware TPM asdone today


A concrete 'ab-use' case that we are trying to avoid is the following:
- a user creating a privileged container that shares the host's mount 
namespace: it would be unexpected if there is an IMA policy active on 
the host that enforces file appraisal but in this case the IMA policy is 
not enforced since a (hypothetical) IMA namespace of the host was not 
joined since only the mount namespace of the host was joined. Now we 
have two choices here: We tie the mount and IMA namespaces together via 
sinlge clone flag, as proposed, and joining the mount namespace 
automatically joins the associated IMA namespace (single setns()). Or we 
make user space responsible for it and say if a mount namespace is 
joined, find the associated IMA namespace (how to do that?), and join 
both of them (2 setns() calls). Well, I think the former would preferred 
over the latter.

Let's assume we tie MNT and IMA together, then there are other scenarios 
with switching through the other namespaces (UTS, PID, IPC, NET, USER, 
CGROUP). I am not sure what is supposed to happen other than logging the 
activity active in the current IMA namespace:

What should happen with IMA logging, appraisal, and auditing if we 
setns() through all available
- PID namespaces and send signals: log, appraise, and audit file 
activity following IMA policy
- IPC namespaces and send messages via IPC: same as for PID
- UTS namespaces and setting hostname:  same as for PID
- NET namespaces and sending network traffic: same as for PID?
- CGROUP namespaces and configuring cgroups: same as for PID?
- USER: should now the keys of this USER namespace be active or the keys 
of the original user namespace used during the clone()? other than that, 
same as for PID?


>
> My impression was that you are measuring things that are executed in an
> effort to make sure that anything that can affect resource $x will
> be at some point detectable.  But if you allow containers (not in
> user namespace) to evade the ima measurements that seems to undermine
> that, so that must not be your goal.  And even if you insist on a

Yes, we want to prevent 'abuse', especially by root. See above.

> user namespace, if some resource is owned by $uid, then $uid can create
> a new namespace, evade the detection, and run malicious code to affect
> the resource.
>
> Unless you're counting on the container runtime to set a proper new
> ima policy?  But if that's the case then you can't have every CLONE_NEWNS
> start a new ima ns.

The container runtime will be able to overwrite a default IMA policy 
that is active upon spawning an IMA namespace. This policy has to be 
useful in so far that it must enable a gapless measurement chain and for 
example show keys that were loaded into keyrings or the IMA policy that 
was loaded.

    Stefan

>
> So I think I need to start from scratch.
>
> thanks,
> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
