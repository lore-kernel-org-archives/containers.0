From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: a work for lxc monitor network interface
Date: Thu, 23 Jan 2014 09:59:02 +0800
Message-ID: <52E07766.90209@huawei.com>
References: <52B15E7B.8080009@huawei.com> <20131218201622.GA25926@tp>
	<52CA6B69.1000402@huawei.com> <20140106165545.GC7123@sergelap>
	<52CE9620.9040108@huawei.com> <20140122141736.GA18507@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140122141736.GA18507@tp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, karma-sWkBwLop/e8RbODiWk9XIg@public.gmane.org, takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org, caglar-mM0DFpta8ko@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, "zhangwei(Jovi)" <jovi.zhangwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, james.hunt-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/1/22 22:17, Serge Hallyn wrote:
> Quoting Libo Chen (clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>> On 2014/1/7 0:55, Serge Hallyn wrote:
>>> Quoting Libo Chen (clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>>>> On 2013/12/19 4:16, Serge Hallyn wrote:
>>>>> Quoting Libo Chen (clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>>>>>> Hello LXC experts,
>>>>>>
>>>>>> 	lxc tool can set network interface by config, but it is static.
>>>>>> In some scene, the network interface will be dynamic created on the host
>>>>>> and need be shared to container, but it is not suitable to do by hand,
>>>>>> so lxc can not work for it.
>>>>>>
>>>>>> 	I also know lxc_user_nic() can only do a part of work, but we have
>>>>>> two more work:
>>>>>> 1. grasp the netlink/uevent message about network interface online
>>>>>> 2. config interface attached to container ip address .
>>>>>>
>>>>>> so it can not fully meet my requirements.
>>>>>>
>>>>>> 	I want there is a monitor can work for network interface hotplug.
>>>>>>
>>>>>> 1. read config form config file, it describe monitor which network interface
>>>>>>    and what's the network configuration
>>>>>> 2. grasp the netlink/uevent message about network interface online on the host
>>>>>> 3. create veth pair, put veth attach to container and bridge
>>>>>> 4. config the veth attached to container ipaddr
>>>>>>
>>>>>> 			
>>>>>>          	          netlink  create veth pair
>>>>>> monitor ---> read config  -------> veth0 attach to container --> config ipaddr
>>>>>> 				   veth1 attach to bridge
>>>>>>
>>>>>> monitor may be the lxc-start or a child forked by lxc-start.
>>>>>>
>>>>>>
>>>>>>  Is this reasonable?  If so, I'd like to do it.
>>>>>
>>>>> I'm not quite clear on what you're trying to do, but it sounds like you
>>>>> could use a udev rule, triggered on the nic creation, and use lxc-device
>>>>> from inside that rule to attach the nic to the container.
>>>>>
>>>> hi Serge,
>>>>
>>>> using udev rule is a good idea, but not common. for instance android uses ueventd and
>>>> busybox uses mdev, sometimes nothing at all.
>>>>
>>>> so how about lxc itself provides this feature?
>>>
>>> Just one more question - what would the configuration look like?
>>> Especially, what would the monitor be looking for?  How would it
>>> recognzie a link that came up as being the one which the container
>>> should be attached to?  (We're constantly reminded that the names
>>> cannot be unambiguously used to identify a physical link)
>>>
>>
>> My idea is this, may not reason.
>>
>> 1. I would like to add a field 'lxc.network.dynamic' which describes a static
>> or dynamic nic in config file.
>>
>> if lxc.network.dynamic = false(default false), lxc should go as before,else it means
>> the following device will appear in a future time.
>>
>> e.g.
>> lxc.network.dynamic = true
>> lxc.network.type = veth   // need veth mode to container
>> lxc.network.flags = up
>> lxc.network.link = br0    // be attached to
>> lxc.network.name = ppp0   //monitor nic ppp0
>>
>> e.g.
>> lxc.network.dynamic = true
>> lxc.network.type = phys   //  direct to container
>> lxc.network.flags = up
>> lxc.network.name = ppp0   //monitor nic ppp0
>>
>>
>> 2.the monitor should look for uevent, since uevent message includes interface name like:
>>
>> add@/devices/virtual/net/veth5
>> ACTION=add
>> DEVPATH=/devices/virtual/net/veth5
>> SUBSYSTEM=net
>> INTERFACE=veth5   ****
>> IFINDEX=19
>> SEQNUM=12292
> 
> Since most hosts already have a well-understood daemon watching uevents,
> udev/mdev/probably others, I still think it would be better for users
> who want this behavior to write a udev rule which fires off
> lxc-device.
> 
> In your design, would there be one long-running daemon for all
> containers, which each container registers nics with, or a
> daemon per container?

a daemon per container, so container can track the uevents it
is interested and this makes code simple.

Libo

> 
> -serge
> 
> .
> 
