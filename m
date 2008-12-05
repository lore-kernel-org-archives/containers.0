From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: liblxc: lxc-debian
Date: Fri, 05 Dec 2008 23:48:07 +0100
Message-ID: <4939AFA7.1060903@fr.ibm.com>
References: <20081204023936.GA31830@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081204023936.GA31830-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Hi Daniel,
> 
> to create a debian-based container using lxc-debian on fedora 10,
> I needed to just a couple of things:
> 
> 	1. iptables -F   :)  Grrr.
> 
> 	2. Right above the debootstrap command, I had to fool
> 	   chage (used during openssh configuration) into thinking
> 	   selinux was disabled.  So after the line:
> 	   mkdir -p "$CACHE/rootfs-$ARCH"
> 	   I added
> 	   mkdir -p "$CACHE/rootfs-$ARCH/selinux"
> 	   echo 0 > "$CACHE/rootfs-$ARCH/selinux/enforce"

Good catch ! :)

> 	3. For the actual debootstrap command I had to do
> 	   debootstrap --arch $ARCH etc $CACHE/rootfs-$ARCH
> 	   Then apt-get install openssh-server and apache
> 	   worked fine.  But your debootstrap command failed
> 	   (the last time i tried) on chroot - no idea why.

Ok, I will try to figure out what is happening.

> Now it seems to work.  This shouldn't have taken me 2 hours to
> figure out, but the symptoms were deceptive :)

I have a some bugs reported I will fix with this one. I'll release a 
0.5.1 version soon.

Thanks a lot for taking the time to investigate :)

   -- Daniel
