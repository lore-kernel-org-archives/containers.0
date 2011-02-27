From: Renato Westphal <renatowestphal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: netns: Issues with deleting virtual interfaces during namespace
	cleanup
Date: Sun, 27 Feb 2011 12:28:43 -0300
Message-ID: <AANLkTikBc4QLos3RoqBib2HLm-CTMCqKT98eA4+K+R-i@mail.gmail.com>
References: <4D69316F.4000606@ll.mit.edu> <4D697F6A.9000907@free.fr>
	<AANLkTinQQHKiujHNet07kbK5eqYvp6-2iBnn27v2-85+@mail.gmail.com>
	<4D6A1726.1010400@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6A1726.1010400-GANU6spQydw@public.gmane.org>
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
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Ward,
	David - 0663 - MITLL" <david.ward-OVIABD91gjs3uPMLIKxrzw@public.gmane.org>, Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel/Eric,

You're completely right. This patch adds more problems than it solves.

I have a problem similar to that of David, but now I'm convinced that
it is better to deal with it with the userspace tools.

Renato.

2011/2/27 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>:
> On 02/27/2011 06:16 AM, Renato Westphal wrote:
>>
>> Hello David,
>>
>> You may try the patch below (kernel v2.6.35) and see if that helps. It
>> basically does what you asked for: during namespace cleanup, move back t=
he
>> virtual interfaces to their original namespaces. I did some tests with
>> veth
>> pairs and nested netns's and everything worked fine.
>>
>> I think this should be the default behaviour, I would like if someone
>> could
>> review/fix this patch and push it upstream.
>
> I don't think you should modify this. The automatic destruction behavior =
is
> implemented since a couple of years now and the userspace components rely=
 on
> that.
>
> Moreover, that will add extra complexity to the kernel, especially with t=
he
> nested namespaces. For example, if netns1 and netns2 are created, where
> netns2 is child of netns1. You create a device in netns1, move it to netn=
s2
> and then netns1 exits. What happens to the device in netns2 when this one=
 is
> destroyed ? You have to track the net namespace life cycle to ensure the
> consistency with the network namespace origin of the device and take
> decision regarding if it is dead or not.
>
> No, really, I am not in favor of that.
>
> However, you can provide an interface to the device, eg a sysfs attribute,
> to flag it as non-destroyable-at-exit and so it will be kept untouched and
> moved back to the init_net_ns.
>
>> 2011/2/26 Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
>>
>>> On 02/26/2011 05:59 PM, Ward, David - 0663 - MITLL wrote:
>>>>
>>>> (Apologies for the cross-post, but Thunderbird messed up the formatting
>>>> when I sent this originally, and then I realized I sent it to the wrong
>>>> list.)
>>>>
>>>> A patch was applied to the kernel in November 2008 that deletes virtual
>>>> network interfaces when network namespaces are cleaned up
>>>> (d0c082cea6dfb9b674b4f6e1e84025662dbd24e8). A discussion about this
>>>> patch took place on this list
>>>> (
>>>
>>>
>>> https://lists.linux-foundation.org/pipermail/containers/2008-October/01=
3460.html
>>> ),
>>>>
>>>> where Daniel Lezcano wrote:
>>>>
>>>> =A0> =A0After discussing with Benjamin, this patch means an user can no
>>>> longer
>>>> =A0> =A0manage a pool of virtual devices because they will be automati=
cally
>>>> =A0> =A0destroyed when the namespace exits. I don't think it is a big
>>>> concern,
>>>> =A0> =A0but just in case I am asking :)
>>>>
>>>> I currently have two use cases where this behavior is not desirable:
>>>>
>>>> 1. I use a veth pair device to connect two containers together (as
>>>> opposed to connecting a container to the host). To do this, I
>>>> create the veth pair device manually in the host with iproute2
>>>> ("ip link add type veth"). Then when I start each container, it
>>>> pulls in one of the interfaces of the veth pair device with
>>>> "lxc.network.type =3D phys". When I stop one of the containers, its
>>>> interface to the veth pair device is deleted instead of moved back
>>>> to the host, so I can not just start the stopped container again
>>>> and re-establish the same link.
>>>
>>> Maybe you can rely on the lxc configuration to do that.
>>>
>>> Assuming you create the two container always in the same order.
>>>
>>> The first one:
>>>
>>> lxc.network.type=3Dveth
>>> lxc.network.veth.pair=3DvethX
>>>
>>> The second one
>>>
>>> lxc.network.type=3Dphys
>>> lxc.network.link=3DvethX
>>>
>>> The drawback is you have to stop / start both of them.
>>>
>>>
>>> Otherwise, why don't you use the macvlan configuration ?
>>>
>>> For both containers:
>>>
>>> lxc.network.type=3Dmacvlan
>>> lxc.network.macvlan.mode=3Dbridge
>>> lxc.network.link=3Ddummy0
>>>
>>>
>>>> 2. I start a process in the host that creates a TUN/TAP interface,
>>>> such as a VPN client. I pull the TUN/TAP interface into the
>>>> container with "lxc.network.type =3D phys". When the container
>>>> exits, the TUN/TAP interface is deleted because it is a virtual
>>>> interface, while the VPN client process continues to run in the
>>>> host. Again I can not just start the container again with the
>>>> same connection; I have to restart the VPN client.
>>>>
>>>> It makes sense that virtual network interfaces that get created inside=
 a
>>>> container should be deleted when the container exits. However, I feel
>>>> that network interfaces from the host that get assigned to the contain=
er
>>>> should be returned to the host when the container exits, whether they
>>>> are physical or virtual.
>>>
>>> Wouldn't make sense to add a configuration option for lxc to create such
>>> device and handle the vpn client ?
>>>
>>> There is the lxc.network.script.up option where you can launch your vpn
>>> client. So adding the tun/tap interface as a network option, lxc will
>>> create it for you and when it is up, the up script is invoked where the
>>> vpn client is launched.
>>>
>>> The lxc.network.script.down does not exist yet, but it is quite easy to
>>> add the option.
>>>
>>> What do you think ?
>>>
>>>> Can the kernel distinguish between network interfaces that were created
>>>> inside the namespace, and network interfaces that were moved there?
>>>
>>> IMHO that will add more complexity to the network namespace, especially
>>> to handle the nested namespaces. Furthermore that will impact the
>>> current design. I am not really in favor of that as that was initial
>>> behavior and there were limitations.
>>> =A0<javascript:void(0);>
>>> _______________________________________________
>>> Containers mailing list
>>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>>> https://lists.linux-foundation.org/mailman/listinfo/containers
>>>
>>
>>
>
> <javascript:void(0);>
>



-- =

Renato Westphal
