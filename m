From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: liblxc: lxc-debian
Date: Wed, 3 Dec 2008 20:39:36 -0600
Message-ID: <20081204023936.GA31830@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Daniel,

to create a debian-based container using lxc-debian on fedora 10,
I needed to just a couple of things:

	1. iptables -F   :)  Grrr.

	2. Right above the debootstrap command, I had to fool
	   chage (used during openssh configuration) into thinking
	   selinux was disabled.  So after the line:
	   mkdir -p "$CACHE/rootfs-$ARCH"
	   I added
	   mkdir -p "$CACHE/rootfs-$ARCH/selinux"
	   echo 0 > "$CACHE/rootfs-$ARCH/selinux/enforce"

	3. For the actual debootstrap command I had to do
	   debootstrap --arch $ARCH etc $CACHE/rootfs-$ARCH
	   Then apt-get install openssh-server and apache
	   worked fine.  But your debootstrap command failed
	   (the last time i tried) on chroot - no idea why.

Now it seems to work.  This shouldn't have taken me 2 hours to
figure out, but the symptoms were deceptive :)

thanks,
-serge
