From: "xiaoming.zhang" <zxm927-9Onoh4P/yGk@public.gmane.org>
Subject: Re: sysfs question
Date: Thu, 11 Sep 2008 22:26:59 +0800
Message-ID: <200809112226.59518.zxm927@163.com>
References: <dac45060809110701i49acb8e7m7d8e3ccea7c59ab7@mail.gmail.com>
	<dac45060809110705r2474060bi71c657a23588975f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <dac45060809110705r2474060bi71c657a23588975f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mark Ryden <markryde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thursday 11 September 2008 10:05:43 pm Mark Ryden wrote:
> In fact, after looking more closely, I see that before that message
> appears: Error: unmouting old /sys
> ERROR unmounting old /sys: Invalid argument.
> forcing unmount of /sys
> switchroot...
>

My experience is you'd better to find a sysfs patch, since the sysfs 
filesystem is required by ramdisk and some system utilities, e.g., system 
network configuration scripts.

Patch for mm-tree can be found here:
	http://lxc.sourceforge.net/patches/2.6.26/

This is what I used:
http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc8-mm1-lxc1/broken-out/sysfs/

I merged these 11 patches on Linux-2.6.26.1 though I don't understand these 
patches, luckily enough it worked for me.

> Any ideas?
> Rgs,
> Mark
>
> On Thu, Sep 11, 2008 at 5:01 PM, Mark Ryden <markryde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hello,
> > I am trying to follow the
> > Linux Containers - Network Namespace configuration instructions from
> > http://lxc.sourceforge.net/network/configuration.php
> >
> >
> > I had built a kernel with CONFIG_SYS=n and  CONFIG_NET_NS=y
> > and CONFIG_VETH=y , etc, according to the instructions.
> >
> >
> > Now, the CONFIG_SYSFS help text says:
> >
> > sysfs is currently used by the block subsystem to mount the root
> > partition. If sysfs is disabled you must specify the boot device on
> > the kernel boot command line via its major and minor numbers. For
> > example, "root=03:01" for /dev/hda1.
> >
> >
> > So I added root=08,02 to my kernel boot parameter line and booted.
> >
> >
> > it starts booting, but then gets:
> > switchroot: mount failed: No such file or directory.
> > Booting has failed.
> >
> > 8 is the majoror number and 2 is the minor number of /dev/sda2, where I
> > have my root partition.
> >
> > Googling for this found the following, which not helped much:
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2007-11/msg05032.html
> >
> > Any ideas?
> > Regards,
> > Mark
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers



-- 
Have fun,
Xiaoming Zhang
