From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Kernel 2.6.33-rc6, 3 bugs container specific.
Date: Thu, 04 Feb 2010 10:33:21 +0100
Message-ID: <4B6A9461.1010309@free.fr>
References: <1265074676.6260.212.camel@Mercier.safe.ca>
	<20100202031647.GA14318@fqdn.org>
	<1265121846.6260.231.camel@Mercier.safe.ca>
	<4B68649D.2000503@free.fr> <20100202181801.GA28412@us.ibm.com>
	<1265136215.6260.261.camel@Mercier.safe.ca>
	<20100202213254.GH32305@us.ibm.com> <4B695535.7020301@free.fr>
	<20100203150350.GA7146@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20100203150350.GA7146-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=lxc-users>
List-Post: <mailto:lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>   
>> Serge E. Hallyn wrote:
>>     
>>> Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
>>>       
>>>> Hello,
>>>>
>>>>
>>>>         
>>>>> I was wondering out loud about the best design to solve his problem.
>>>>>
>>>>> If we try to redirect kernel-generated messages to containers, we have
>>>>> several problems, including whether we need to duplicate the messages
>>>>> to the host container.  So in one sense it seems more flexible to
>>>>> 	1. send everything to host syslog
>>>>>           
>>>> 		No, if we do that all CONTs message will reach
>>>> 		the same bucket and it will be difficult to sort
>>>> 		them out..
>>>> 		CONT sys_admin and HOST sys_admin could be different
>>>> 		"entity", so you debug CONT config and critical
>>>> 		needed information reach HOST (which you do not 		have access
>>>> to).
>>>>         
>>> Yes, so a privileged task on HOST must pass that information back to
>>> you on CONT.  That is not a valid complaint imo.  But how to sort the
>>> msgs out is a valid question.
>>>
>>> We need some sort of identifier, unique system-wide, attached to.. something.
>>> Is ifindex unique system-wide right now?  Oh, IIRC it is, but we wnat it to
>>> be containerized, so that would be a bad choice :)
>>>
>>>       
>>>>> 	2. clamp down on syslog use by processes not in the init_user_ns
>>>>>           
>>>> 		Could give me more detail??...
>>>>         
>>> Simplest choices would be to just refuse sys_syslog() and open(/proc/kmsg)
>>> altogether from a container, or to only allow reading/writing messages
>>> to own syslog.  (I had hoped to find time to try out the second option but
>>> simply haven't had the time, and it doesn't look like I will very soon.
>>> So if anyone else wants to, pls jump at it...)
>>>
>>> Then /proc/kmsg can provide what I described above through a FUSE file,
>>> and if, as you mentioned, the container unmounts the FUSE fs and gets
>>> to real procfs, they just get nothing.
>>>
>>>       
>>>>> 	3. let the userspace on the host copy messages into a socket or
>>>>> 	   file so child container can pretend it has real syslog.
>>>>>           
>>>> 		So you trap printk message from CONT on the HOST and
>>>> 		redirect them on CONT but on a standard syslog channel.
>>>> 		Seem OK to me, as long /proc/kmsg is not existing
>>>> 		(/dev/null) in the CONT file tree.
>>>>         
>> We have:
>>        * Commands to sys_syslog:
>>        *
>>        *      0 -- Close the log.  Currently a NOP.
>>        *      1 -- Open the log. Currently a NOP.
>>        *      2 -- Read from the log.
>>        *      3 -- Read all messages remaining in the ring buffer.
>>        *      4 -- Read and clear all messages remaining in the ring buffer
>>        *      5 -- Clear ring buffer.
>>        *      6 -- Disable printk to console
>>        *      7 -- Enable printk to console
>>        *      8 -- Set level of messages printed to console
>>        *      9 -- Return number of unread characters in the log buffer
>>        *     10 -- Return size of the log buffer
>>
>> And add:
>>       *     11 -- create a new ring buffer for the current process
>> and its childs
>>
>>
>> We have, let's say a global ring buffer keep untouched, used by
>> syslog(2) and printk. When we create a new ring buffer, we allocate
>> it and assign to the nsproxy (global ring buffer is the default in
>> the nsproxy).
>>
>> The prink keeps writing in the global ring buffer and the syslog(2)
>> writes to the "namespaced" ring buffer.
>>
>> Does it makes sense ?
>>     
>
> Yeah, it's a nice alternative.  Though (1) there is something to be said for
> forcing a new ring buffer upon clone(CLONE_NEWUSER), and (2) assuming the
> new ring buffer is pointed to from nsproxy, it might be frowned upon to do
> an unshare/clone action in yet another way.
>   
Why do you want to tie clone(CLONE_NEWUSER) with a new ring buffer ?
I mean one may want to use CLONE_NEWUSER but keep the ring buffer, no ?
> I still think our first concern should be safety, and that we should consider
> just adding 'struct syslog_struct' to nsproxy, and making that NULL on a
> clone(CLONE_NEWUSER).  any sys_syslog() or /proc/kmsg access returns -EINVAL
> after that.  Then we can discuss whether and how to target printks to
> namespaces, and whether duplicates should be sent to parent namespaces.
>   
That makes sense to do it step by step. Targeting the printk is the more 
difficult, no ? I mean you should have always the destination namespace 
available which is not obvious when the printk is called from an 
interrupt context.

> After we start getting flexible with syslog, the next request will be for
> audit flexibility.  I don't even know how our netlink support suffices for
> that right now.
>
> (So, this all does turn into a big deal...)
>   
Mmh ... right.

------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
