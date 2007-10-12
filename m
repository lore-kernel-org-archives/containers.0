From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 0/2][NETNS49][IPV4][IGMP] activate multicast per
	namespace
Date: Fri, 12 Oct 2007 15:37:59 -0600
Message-ID: <m18x688154.fsf@ebiederm.dsl.xmission.com>
References: <20071012171013.105324992@mai.toulouse-stg.fr.ibm.com>
	<m17ils9ngz.fsf@ebiederm.dsl.xmission.com>
	<470FE130.8040403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <470FE130.8040403-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Fri,
	12 Oct 2007 23:03:44 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> The following patches activate the multicast sockets for
>>> the namespaces. The results is a traffic going through differents
>>> namespaces. So if there are several applications
>>> listenning to the same multicast group/port, running in
>>> different namespaces, they will receive multicast packets.
>>
>> At a first glance this feels wrong.  I don't see any per
>> namespace filtering of multicast traffic.  Unless the
>> multicast traffic is routed/bridged between namespaces
>> it should be possible to send multicast traffic in one
>> namespace and listen for that same traffic in another
>> namespace and not get it.
>
> The described behavior is the case were the namespaces are communicating via
> veth like:
>
> eth0
>  |
>  |        ------------- nsA
> veth0 <--|--> veth1    |
>  |        -------------
>  |
>  |        -------------nsB
> veth2 <--|--> veth3    |
>           -------------
>
>
> If an application is listening in nsA and nsB. And if in nsA, an application
> sends multicast traffic, both will receive the packets because they are routed
> by the pair device.
> As you said this is the correct behavior, if we have two machines hostA and
> hostB in the same network and both are listening on the multicast address and if
> an application on hostA send multicast packets, both should receive the
> multicast packets.
> If the traffic is not routed, multicast will not pass through the namespaces.
>
> The description I gave in the patchset introduction was to describe such
> behavior which is, IMHO, important for inter-container communication.
> Perhaps, I should have not gave this description which seems to sow confusion in
> mind, sorry for that.
>
> Anyway, I hope the patchset is ok :)

Sounds more reasonable.  I didn't see the second patch when I replied
which was part of the reason I was worried.  So at least at first glance
that patchset looks reasonable.

Thanks,
Eric
