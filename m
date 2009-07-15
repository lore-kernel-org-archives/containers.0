From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Tue, 14 Jul 2009 21:47:44 -0700
Message-ID: <20090715044744.GA25745@us.ibm.com>
References: <20090711193055.GA11303@megiteam.pl>
	<20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
	<20090712074932.GA17291@megiteam.pl>
	<20090713190211.GA4208@us.ibm.com>
	<20090713193058.GL18617@megiteam.pl>
	<20090713202610.GA6447@us.ibm.com>
	<20090713223444.GM18617@megiteam.pl>
	<20090714064905.GA25278@us.ibm.com>
	<20090714103129.GB12958@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090714103129.GB12958-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
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
| On pon, lip 13, 2009 at 11:49:05 -0700, Sukadev Bhattiprolu wrote:
| > Grzegorz Nosek [root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org] wrote:
| > | Simply run it as container init. Sometimes it oopses immediately,
| > 
| > I am trying to reproduce this too and just trying to make sure I get
| > your environment correctly.  I have just built/installed libvirt 0.6.5
| > on Ubuntu 9.04. 
| 
| 0.6.4 or 0.6.5, no difference really (tested both). Host distro is
| Debian Lenny but Ubuntu is probably close enough. Didn't test distro
| kernel, only used hand-built 2.6.30, 2.6.30.1 and 2.6.31-rc2

Ok.  Will try 2.6.31-rc2.

| 
| > The bug does require libvirt+kvm right ?  IOW, does this simple test repro
| > if it is run as a container-init with say lxc-start (i.e from liblxc - see
| > http://lxc.sourceforge.net/) ? Another simpler way to create container-init
| > is the ns_exec program - I assume that won't create the problem ?
| 
| Probably, as it requires a "cross-namespace" pty.  I didn't yet set up a
| lxc config file. Maybe you can help off the top of your head with the
| right incantations?

I don't have any beyond what is in the lxc-source examples. Maybe
Daniel Lezcano has some.

|BTW, where's the canonical source for ns_exec?

It is here: git://git.sr71.net/~hallyn/cr_tests.git
| 
| > Also in an earlier mail you mentioned that disabling the 'newinstance'
| > mount option to devpts did not help. So does your setup work with older
| > kernels like 2.6.28 ?
| 
| Well, I failed to build 2.6.28 with NET_NS (even without SYSFS it wasn't
| available in menuconfig) but 2.6.29 exhibits very similar behaviour,
| i.e. crashes instantly. The difference is that when the pty master
| exits, container init receives a SIGHUP. If it chooses to ignore it and
| open /dev/console anyway, *boom*. Looking roughly at %eip and the
| faulting address, it's the same bug.

So I guess this is the first time we are trying this scenario out (i.e.
it may not be a regression so we can't necessarily use git-bisect).

I am not too familiar with libvirt implementation, but do you think it
is possible to repro this using ns_exec and fewer/minimal namespaces ?

We should be able to get a cross-namespace pty using ns_exec, but am not
sure the set of namespaces need to be cloned -  would it be sufficient if
we clone pid and mount namespaces and remount /dev/pts in child container ?

Thanks,

Sukadev
