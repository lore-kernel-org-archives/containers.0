From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Mon, 13 Jul 2009 23:49:05 -0700
Message-ID: <20090714064905.GA25278@us.ibm.com>
References: <20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
	<20090711193055.GA11303@megiteam.pl>
	<20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
	<20090712074932.GA17291@megiteam.pl>
	<20090713190211.GA4208@us.ibm.com>
	<20090713193058.GL18617@megiteam.pl>
	<20090713202610.GA6447@us.ibm.com>
	<20090713223444.GM18617@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090713223444.GM18617-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Grzegorz Nosek [root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org] wrote:
| Simply run it as container init. Sometimes it oopses immediately,

I am trying to reproduce this too and just trying to make sure I get
your environment correctly.  I have just built/installed libvirt 0.6.5
on Ubuntu 9.04. 

The bug does require libvirt+kvm right ?  IOW, does this simple test repro
if it is run as a container-init with say lxc-start (i.e from liblxc - see
http://lxc.sourceforge.net/) ? Another simpler way to create container-init
is the ns_exec program - I assume that won't create the problem ?

Also in an earlier mail you mentioned that disabling the 'newinstance'
mount option to devpts did not help. So does your setup work with older
kernels like 2.6.28 ?

| usually it goes as far as the pause. If you kill it with SIGINT then,
| everything will probably be fine. But if you first kill the libvirt_lxc
| process above it (holding the pty master), and only then kill init, it
| should oops.
| 
| Note that the weird mount stuff is critical here (couldn't reproduce the
| oops by simply opening /dev/pts/0, even if I mounted it on /dev/console
| before).
| 
| After applying my patch from some earlier mail I can no longer crash the
| kernel, but the "Hello world!" appears on my current VT, so there's
| potential for container root to mess up host console. I don't know how
| that happened, actually.
| 
| Best regards,
|  Grzegorz Nosek
| 
| /*------------------------------------------------------------------*/
| #include <sys/mount.h>
| #include <fcntl.h>
| #include <unistd.h>
| #include <sys/signal.h>
| 
| void dummy(int sig)
| {
| }
| 
| int main(void)
| {
| 	sleep(2); /* wait for /dev/pts/0 to appear */
| 	close(0);
| 	close(1);
| 	close(2);
| 	mount("/dev/pts/0", "/dev/console", NULL, MS_BIND, NULL);
| 	signal(SIGINT, dummy);
| 	pause();
| 
| 	open("/dev/console", O_RDWR);
| 	dup(0);
| 	dup(0);
| 	write(1, "Hello world!\n", sizeof("Hello world!\n")-1);
| 	return 0;
| }
