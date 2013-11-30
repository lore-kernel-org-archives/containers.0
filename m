From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: use vlan in container
Date: Sat, 30 Nov 2013 09:46:59 +0800
Message-ID: <52994393.8060601@huawei.com>
References: <5296E003.80804@huawei.com> <20131129050549.GB8830@sergelap>
	<529836CD.1080900@huawei.com> <20131129141826.GA5018@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131129141826.GA5018@sergelap>
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
Cc: dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "zhangwei(Jovi)" <jovi.zhangwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/11/29 22:18, Serge Hallyn wrote:
> Quoting Libo Chen (clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>> On 2013/11/29 13:05, Serge Hallyn wrote:
>>> Quoting Libo Chen (clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>>>> Hello LXC experts,
>>>>
>>>> 	I meet a problem. When using vlan as network device in suse11 system container,
>>>> I can not use halt to stop this container. It hung on "eth0 is still used from interfaces eth0" in cycle.
>>>>
>>>> The config file:
>>>>
>>>> lxc.network.type = vlan
>>>> lxc.network.flags = up
>>>> lxc.network.link = eth0
>>>> lxc.network.name = eth0
>>>> lxc.network.vlan.id = 1301
>>>> lxc.network.ipv4 = 128.5.131.100/24
>>>>
>>>>
>>>> The reason is in the shell command /sbin/ifdown, see below:
>>>>
>>>> ######################################################################
>>>> # Shut down depending interfaces
>>>> #
>>>> # Check if there are interfaces which depend on this interface. If yes these
>>>> # have to be shut down first.
>>>> # For example these might be bonding or vlan interfaces. Note that we don't
>>>> # catch all types of depending interfaces currently. See function
>>>> # 'get_depending_ifaces' in file 'functions' for details.
>>>> #
>>>> test "$SCRIPTNAME" = ifdown && DEP_IFACES=`get_depending_ifaces $INTERFACE`
>>>> if [ "$?" = 0 -a "$NODEPS" != yes ] ; then
>>>>         message "`printf "    %-9s is still used from interfaces %s" \
>>>>                          $INTERFACE "$DEP_IFACES"`"
>>>>         for DI in $DEP_IFACES; do
>>>
>>> Should the proper fix be to fix this script so that it doesn't call
>>> ifdown recursively if $DI = $INTERFACE ?
>>
>> Hi Serge,
>>
>> yes, I had try this way before as below:
>>
>>         for DI in $DEP_IFACES; do
>> 	         if [ "$DI" != "$INTERFACE" ] ; then
>>                        ifdown $DI -o $OPTIONS
>> 	         fi
>>         done
>>
>> It works well, but I have no idea it is safe enough and no side effects?
> 
> It's safe enough and should have no side effects itself.  But
> I recommend you first look up how get_depending_ifaces() is
> implemented.  That's where this really should be fixed, and if
> it turns out that the proper fix for *that* is in the kernel
> then that's ok.

thank you for your suggestion.

Libo


> 
> -serge
> 
> .
> 
