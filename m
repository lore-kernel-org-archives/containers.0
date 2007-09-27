From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 3/3][netns] net: hide master/linked interface from
	netlink
Date: Thu, 27 Sep 2007 11:15:45 +0200
Message-ID: <46FB74C1.9080100@fr.ibm.com>
References: <20070924122112.065703991@mai.toulouse-stg.fr.ibm.com>
	<20070924122837.979935055@mai.toulouse-stg.fr.ibm.com>
	<m1hclgo5eu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1hclgo5eu.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org writes:
> 
>> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>>
>> Actually when a network device is linked to another, the name appears
>> to be @<link>. For example, if a macvlan0 is created on top of eth0,
>> the ip link show is:
>>
>> 6: macvlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop 
>>     link/ether 6a:d4:10:0d:a8:55 brd ff:ff:ff:ff:ff:ff
>>
>> But if we move macvlan0 to a network namespace, eth0 does no longer
>> exist inside it and the result will be:
>>
>> 6: macvlan0@if2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop 
>>     link/ether 6a:d4:10:0d:a8:55 brd ff:ff:ff:ff:ff:ff
>>
>> if2 is, I guess, some random value. That can do invalid memory
>> access or inconsistent data showing.
>>
>> The patchset will avoid such case, it checks if the linked device exist
>> into the current network namespace and if it doesn't the result will
>> be:
>>
>> 6: macvlan0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop 
>>     link/ether 6a:d4:10:0d:a8:55 brd ff:ff:ff:ff:ff:ff
> 
> Hmm.  Currently the ifindex space is global.  Something that ultimately
> needs to be fixed to handle migration so we can preserve the ifindex
> on a device when we migrate it.

One interesting thing with the global ifindex, is we can keep track to 
the network device. For example, from outside the namespace we create 
macvlan0, push it to the netns, inside the netns, we rename it eth0 (eg. 
to fit os template), the netns finishes and the netdev is pop out to the 
initial network namespace. The names will conflict and the eth0 (former 
macvlan0) is renamed to dev0. If we want to automate the destruction of 
such interface, we should be able to identify them when the namespace 
exits. The global ifindex allow that.

If the ifindex is changed to be local to the namespace, the ifindex will 
be changed each time we change namespaces. So in this case, it will be 
hard to track these interfaces.

This point is out of migration consideration and having a ifindex per 
namespace makes sense.

Should we consider an identifier for the network devices ? so we can 
setup this identifier each time we create/migrate an interface and find 
them by this identifier.

> So the @if2 piece is harmless, as it is just reporting the ifindex
> number because it can't figure out the name that corresponds to
> that network device.
> 
> So the worst we get is hints that some extra data exists somewhere.
> I suspect the correct fix is to not even write the additional attribute
> in this case instead of setting the value to zero.
> 
> I am not yet convinced we need to handle this case yet, at most this
> is a cosmetic issue.
