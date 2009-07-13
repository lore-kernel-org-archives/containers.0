From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Tue, 14 Jul 2009 00:34:44 +0200
Message-ID: <20090713223444.GM18617@megiteam.pl>
References: <20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
	<20090711193055.GA11303@megiteam.pl>
	<20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
	<20090712074932.GA17291@megiteam.pl>
	<20090713190211.GA4208@us.ibm.com>
	<20090713193058.GL18617@megiteam.pl>
	<20090713202610.GA6447@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090713202610.GA6447-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 13, 2009 at 03:26:10PM -0500, Serge E. Hallyn wrote:
> The container init is /bin/sh, and you
> while [ 1 ]; do
> 	virsh --connect lxc:/// start vm1
> 	virsh --connect lxc:/// destroy vm1
> done
> 
> ?  (I thought there was something about stracing the container
> init too, so i was basically doing the above while also
> stracing the bash shell)

That was the first occurrence of the crash (though I can't tell you
whether I used sash or upstart then). When I could reproduce the crash
reliably, I was using upstart without strace and the script was
basically

while [ 1 ]; do
	virsh --connect lxc:/// start vm1
	sleep 3
	virsh --connect lxc:/// shutdown vm1
	sleep 3
done

to let the startup/shutdown settle (also, SLUB debugging had to be on to
poison freed memory -- this was crucial for me).

OK, I've been writing this mail for over an hour now, but I managed to
produce a single program which produces the oops I've been encountering.

Simply run it as container init. Sometimes it oopses immediately,
usually it goes as far as the pause. If you kill it with SIGINT then,
everything will probably be fine. But if you first kill the libvirt_lxc
process above it (holding the pty master), and only then kill init, it
should oops.

Note that the weird mount stuff is critical here (couldn't reproduce the
oops by simply opening /dev/pts/0, even if I mounted it on /dev/console
before).

After applying my patch from some earlier mail I can no longer crash the
kernel, but the "Hello world!" appears on my current VT, so there's
potential for container root to mess up host console. I don't know how
that happened, actually.

Best regards,
 Grzegorz Nosek

/*------------------------------------------------------------------*/
#include <sys/mount.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/signal.h>

void dummy(int sig)
{
}

int main(void)
{
	sleep(2); /* wait for /dev/pts/0 to appear */
	close(0);
	close(1);
	close(2);
	mount("/dev/pts/0", "/dev/console", NULL, MS_BIND, NULL);
	signal(SIGINT, dummy);
	pause();

	open("/dev/console", O_RDWR);
	dup(0);
	dup(0);
	write(1, "Hello world!\n", sizeof("Hello world!\n")-1);
	return 0;
}
