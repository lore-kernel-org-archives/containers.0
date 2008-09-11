From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: sysfs question
Date: Thu, 11 Sep 2008 16:49:41 +0200
Message-ID: <48C93005.6030806@bull.net>
References: <dac45060809110701i49acb8e7m7d8e3ccea7c59ab7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <dac45060809110701i49acb8e7m7d8e3ccea7c59ab7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Hi Mark,

Indeed booting a distro without sysfs can be tricky because, for
example, initrd might need it (eg. Fedora).

IIRC, to boot without sysfs, in addition to the "root=" option,  you
have to create some devices nodes in advance in your /dev tree
(mainly the /dev/sda* ones, plus a bunch of others /dev/urandom,
/dev/null, /dev/console, /dev/tty).

mknod /dev/sda b 8 0
mknod /dev/sda1 b 8 1
...

But my advice to test netns is to apply the tagged directories sysfs
patchses. It is a lot easier (and complete).

Gregkh is merging the patchset to his tree today (he has added 6 out of
the 8 remaining patches this morning) :)
Once the patchset is completely merged I'll update the howto.

Also I can send you tarball too if you want. Which kernel version do you 
use?

Regards,
Benjamin


Mark Ryden wrote:
> Hello,
> I am trying to follow the
> Linux Containers - Network Namespace configuration instructions from
> http://lxc.sourceforge.net/network/configuration.php
> 
> 
> I had built a kernel with CONFIG_SYS=n and  CONFIG_NET_NS=y
> and CONFIG_VETH=y , etc, according to the instructions.
> 
> 
> Now, the CONFIG_SYSFS help text says:
> 
> sysfs is currently used by the block subsystem to mount the root
> partition. If sysfs is disabled you must specify the boot device on
> the kernel boot command line via its major and minor numbers. For
> example, "root=03:01" for /dev/hda1.
> 
> 
> So I added root=08,02 to my kernel boot parameter line and booted.
> 
> 
> it starts booting, but then gets:
> switchroot: mount failed: No such file or directory.
> Booting has failed.
> 
> 8 is the majoror number and 2 is the minor number of /dev/sda2, where I have
> my root partition.
> 
> Googling for this found the following, which not helped much:
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2007-11/msg05032.html
> 
> Any ideas?
> Regards,
> Mark
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
