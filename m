From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [Devel] Re: LXC container, unmounting unneeded mount points (from
	the 	container namespace)
Date: Wed, 13 Jan 2010 14:53:58 +0100
Message-ID: <4B4DD076.3090007@free.fr>
References: <8e04b5821001080608w47b0529dhcd6f8a26e38f24e0@mail.gmail.com>	
	<4B473E89.1040200@free.fr>	
	<8e04b5821001080625j22517f1i22ec3495d8d1e53b@mail.gmail.com>	
	<4B4742A8.1000708@free.fr> <1263268449.14592.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263268449.14592.53.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Cc: Michael Holzt <lxc-y7YfGAZ8UuFAfugRpC6u6w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Ciprian Dorin, Craciun" <ciprian.craciun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Michael H. Warfield wrote:
> Added lxc-devel to the cc list since this seems to be more appropriate
> over there (maybe) and I've just joined that one as well.
>
> On Fri, 2010-01-08 at 15:35 +0100, Daniel Lezcano wrote: 
>   
>> Ciprian Dorin, Craciun wrote:
>>     
>>> On Fri, Jan 8, 2010 at 4:17 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>>>   
>>>       
>>>> Ciprian Dorin, Craciun wrote:
>>>>     
>>>>         
>>>>>    Hy all!
>>>>>
>>>>>    Today I've started to play with the LXC containers, and I've got a
>>>>> question: when starting a container (with it's own mount point
>>>>> namespace), and I do a `cat /proc/mounts` I also see the mount points
>>>>> from my host system.
>>>>>
>>>>>    So the question is: how can I force `lxc-create` to remove any
>>>>> uneeded mount points (maybe all)?
>>>>>
>>>>>       
>>>>>           
>>>> Committed today :)
>>>>
>>>> http://git.lab.toulouse-stg.fr.ibm.com/?p=lxc.git;a=commit;h=ed83715df7666879116d1657b1dd54a8fc6513f6
>>>>     
>>>>         
>
>   
>> Oops, this one:
>>     
>
>   
>> http://lxc.git.sourceforge.net/git/gitweb.cgi?p=lxc/lxc;a=commit;h=bf601689a9e0cea1ceaf17e4f7f853f5392c2827
>>     
>
> Nice.  This is EXACTLY what I've been looking for as well.  Only problem
> is...  It didn't work.  It complains about:
>
> lxc-start: could not umount 1 mounts"
>
> Then terminates saying it can't start the container.
>
> When I throw in some debugging prints, I find out that it's complaining
> that it can't umount {pivotdir}/dev.  Commented out the return -1's in
> that routine so it starts the container anyways and jump into the
> running container and I discover that {pivotdir}/dev/shm is still
> mounted even though it thinks it umounted it.  I can see from the
> debugging prints that it seems to have successfully umount it (the
> debugging message indicates that it umounted it - so it saw it had it
> and tried and got a good return from the attempt) but it's apparently
> still mount.  If I umount that {pivotdir}/dev/shm inside the container,
> I can then umount {pivotdir}/dev and {pivotdir}. 
>
> Tried it both by defining lxc.pivotdir and by letting it choose a
> temporary one.  Tried two different containers.  Same result.
>
> This is what I get with the "return -1"'s commented out in the function
> and laced with my own debugging prints to print each step of the umount
> loop (this is with lxc.pivotdir = /rootfs):
>
> ===
> [root@Berserker-Base ~]# lxc-start -n 1009
> still mounted '/rootfs/dev'
> umounted '/rootfs/dev/pts'
> umounted '/rootfs/dev/shm'
> still mounted '/rootfs/proc'
> umounted '/rootfs/proc/bus/usb'
> umounted '/rootfs/proc/sys/fs/binfmt_misc'
> umounted '/rootfs/sys'
> umounted '/rootfs/home'
> still mounted '/rootfs/var'
> umounted '/rootfs/var/lib/cgroup'
> umounted '/rootfs/var/lib/nfs/rpc_pipefs'
> umounted '/rootfs/usr'
> umounted '/rootfs/boot'
> still mounted '/rootfs/srv'
> umounted '/rootfs/misc'
> umounted '/rootfs/net'
> still mounted '/rootfs/srv/lxc/root/1009'
> umounted '/rootfs/srv/lxc/root/1009/export'
> umounted '/rootfs/srv/lxc/root/1009/srv/shared'
> umounted '/rootfs/srv/lxc/root/1009/dev/pts'
> umounted '/rootfs/srv/lxc/root/1009/proc'
> umounted '/rootfs/srv/lxc/root/1009/sys'
> umounted '/rootfs/srv/lxc/root/1009/dev/shm'
> umounted '/rootfs/srv/lxc/root/1009/dev/console'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty1'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty2'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty3'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty4'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty5'
> umounted '/rootfs/srv/lxc/root/1009/dev/tty6'
> still mounted '/rootfs/dev'
> umounted '/rootfs/proc'
> umounted '/rootfs/var'
> still mounted '/rootfs/srv'
> umounted '/rootfs/srv/lxc/root/1009'
> still mounted '/rootfs/dev'
> umounted '/rootfs/srv'
> still mounted '/rootfs/dev'
> lxc-start: could not umount 1 mounts
> lxc-start: Device or resource busy - could not unmount old rootfs
> INIT: version 2.86 booting
> ===
>
> Container now continues to boot, since I commented out the error
> returns.  Jumping into that container:
>
> === 
> [root@Berserker ~]# df
> Filesystem           1K-blocks      Used Available Use% Mounted on
> rootfs               288433504 240305660  33476248  88% /
> /dev/sda6              2063504    662116   1296568  34% /rootfs
> udev                   1031280       200   1031080   1% /rootfs/dev
> /dev/shm               1031280         0   1031280   0% /rootfs/dev/shm
> /dev/mapper/VolGroup00-LogVol00
>                      288433504 240305660  33476248  88% /
> /dev/sda6              2063504    662116   1296568  34% /export
> /dev/sda7            693727244 554704408 103783460  85% /srv/shared
> none                   1031280         0   1031280   0% /dev/shm
> [root@Berserker ~]# umount /rootfs/dev/shm
> [root@Berserker ~]# umount /rootfs/dev    
> [root@Berserker ~]# umount /rootfs    
> [root@Berserker ~]# df
> Filesystem           1K-blocks      Used Available Use% Mounted on
> rootfs               288433504 240305672  33476236  88% /
> /dev/mapper/VolGroup00-LogVol00
>                      288433504 240305672  33476236  88% /
> /dev/sda6              2063504    662116   1296568  34% /export
> /dev/sda7            693727244 554704408 103783460  85% /srv/shared
> none                   1031280         0   1031280   0% /dev/shm
> ===
>
> Of course we also have the strange "rootfs" entry there as well.
>
> Host system is Fedora 12.
> Host kernel is: 2.6.31.9-174.fc12.i686
> Guest system in each case is CentOS 5.4
>   

I added in the Cc Michael Holzt.

Thanks for reporting this.

  -- Daniel
