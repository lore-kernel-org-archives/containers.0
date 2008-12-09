From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: liblxc: lxc-debian
Date: Tue, 9 Dec 2008 10:32:09 -0600
Message-ID: <20081209163209.GE9487@us.ibm.com>
References: <20081204023936.GA31830@us.ibm.com> <4939AFA7.1060903@fr.ibm.com>
	<20081206001110.GA32712@us.ibm.com>
	<1228772669.5558.9.camel@localhost>
	<20081208234348.GA7935@us.ibm.com> <493E4A48.5020200@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <493E4A48.5020200-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>>         #
>>>         # Write some reasonable default device whitelist rules
>>>         #
>>>         cat - >> $CONFFILE <<-"EOF"
>>>         lxc.cgroup.devices.deny = a
>>>         # /dev/null and zero
>>>         lxc.cgroup.devices.allow = c 1:3 rwm
>>>         lxc.cgroup.devices.allow = c 1:5 rwm
>>>         # consoles
>>>         lxc.cgroup.devices.allow = c 5:1 rwm
>>>         lxc.cgroup.devices.allow = c 5:0 rwm
>>>         lxc.cgroup.devices.allow = c 4:0 rwm
>>>         lxc.cgroup.devices.allow = c 4:1 rwm
>>>         # /dev/{,u}random
>>>         lxc.cgroup.devices.allow = c 1:9 rwm
>>>         lxc.cgroup.devices.allow = c 1:8 rwm
>>>         # /dev/pts/* - pts namespaces are "coming soon"
>>>         lxc.cgroup.devices.allow = c 136:* rwm
>>>         # rtc         lxc.cgroup.devices.allow = c 254:0 rwm
>>>         EOF
>>>
>>> The quotes around EOF prevent bash from doing any substitution on the
>>> file contents.
>
> I added these devices to the debian configuration file and fixed the  
> cgroup list order, "lxc.cgroup.devices.deny = a" was the last entry :/

Weird.  It's the first now I hope :)

> By default the debian has no root password, so the ssh connection will  
> always fail until a password is set for root. I will look on how to  
> change the root password to 'root' after debootstraping ...
>
> I added "lxc.cgroup.devices.allow = c 5:2 rwm"
> in order to use /dev/ptmx for the tty's ssh connection.
>
> The container is no longer able to create /dev/initctl, so the poweroff  
> command will fail. Serge do you know what is the syntax for the  
> devices.allow for initctl ?

initctl isn't a device, it's a fifo.  At least on my laptop.

thanks,
-serge
