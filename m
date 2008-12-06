From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: liblxc: lxc-debian
Date: Fri, 5 Dec 2008 18:11:11 -0600
Message-ID: <20081206001110.GA32712@us.ibm.com>
References: <20081204023936.GA31830@us.ibm.com> <4939AFA7.1060903@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4939AFA7.1060903-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
>> Hi Daniel,
>>
>> to create a debian-based container using lxc-debian on fedora 10,
>> I needed to just a couple of things:
>>
>> 	1. iptables -F   :)  Grrr.
>>
>> 	2. Right above the debootstrap command, I had to fool
>> 	   chage (used during openssh configuration) into thinking
>> 	   selinux was disabled.  So after the line:
>> 	   mkdir -p "$CACHE/rootfs-$ARCH"
>> 	   I added
>> 	   mkdir -p "$CACHE/rootfs-$ARCH/selinux"
>> 	   echo 0 > "$CACHE/rootfs-$ARCH/selinux/enforce"
>
> Good catch ! :)

Are you going to put those lines into the 'official' lxc-debian?

>> 	3. For the actual debootstrap command I had to do
>> 	   debootstrap --arch $ARCH etc $CACHE/rootfs-$ARCH
>> 	   Then apt-get install openssh-server and apache
>> 	   worked fine.  But your debootstrap command failed
>> 	   (the last time i tried) on chroot - no idea why.
>
> Ok, I will try to figure out what is happening.

Great, thanks.

>> Now it seems to work.  This shouldn't have taken me 2 hours to
>> figure out, but the symptoms were deceptive :)
>
> I have a some bugs reported I will fix with this one. I'll release a  
> 0.5.1 version soon.
>
> Thanks a lot for taking the time to investigate :)

One more thing that would be helpful - can you think of an
easy way to specify devices whitelist rules for lxc-debian?
I don't want to complicate the creation process, but as it
is it's not trivial to define them.  Perhaps specifying a
default that should work for most everyone would be ok?  I
find the following to be plenty flexible:

(this is the code i inserted into the old lxc-debian command,
haven't checked if i need to change it for the new one)

    echo "lxc.cgroup.devices.deny = a" >> $CONFFILE
    # /dev/null and zero
    echo "lxc.cgroup.devices.allow = c 1:3 rwm" >> $CONFFILE
    echo "lxc.cgroup.devices.allow = c 1:5 rwm" >> $CONFFILE
    # consoles
    echo "lxc.cgroup.devices.allow = c 5:1 rwm" >> $CONFFILE
    echo "lxc.cgroup.devices.allow = c 5:0 rwm" >> $CONFFILE
    echo "lxc.cgroup.devices.allow = c 4:0 rwm" >> $CONFFILE
    echo "lxc.cgroup.devices.allow = c 4:1 rwm" >> $CONFFILE
    # /dev/{,u}random
    echo "lxc.cgroup.devices.allow = c 1:9 rwm" >> $CONFFILE
    echo "lxc.cgroup.devices.allow = c 1:8 rwm" >> $CONFFILE
    # /dev/pts/* - pts namespaces are "coming soon"
    echo "lxc.cgroup.devices.allow = c 136:* rwm" >> $CONFFILE
    # rtc
    echo "lxc.cgroup.devices.allow = c 254:0 rwm" >> $CONFFILE

thanks,
-serge
