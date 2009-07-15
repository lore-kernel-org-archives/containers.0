From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Wed, 15 Jul 2009 07:42:53 +0200
Message-ID: <20090715054253.GA21417@megiteam.pl>
References: <20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
	<20090712074932.GA17291@megiteam.pl>
	<20090713190211.GA4208@us.ibm.com>
	<20090713193058.GL18617@megiteam.pl>
	<20090713202610.GA6447@us.ibm.com>
	<20090713223444.GM18617@megiteam.pl>
	<20090714064905.GA25278@us.ibm.com>
	<20090714103129.GB12958@megiteam.pl>
	<20090715044744.GA25745@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090715044744.GA25745-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

On wto, lip 14, 2009 at 09:47:44 -0700, Sukadev Bhattiprolu wrote:
> I don't have any beyond what is in the lxc-source examples. Maybe
> Daniel Lezcano has some.

Just asking :)

> |BTW, where's the canonical source for ns_exec?
> 
> It is here: git://git.sr71.net/~hallyn/cr_tests.git

Thanks a lot.

> So I guess this is the first time we are trying this scenario out (i.e.
> it may not be a regression so we can't necessarily use git-bisect).
> 
> I am not too familiar with libvirt implementation, but do you think it
> is possible to repro this using ns_exec and fewer/minimal namespaces ?

I didn't try that, but regarding devpts the libvirt code does basically:

unshare(CLONE_NS)
mount --make-slave /
mount devpts /dev/pts -t devpts 

clone(all the namespace options including CLONE_NEWNS)
child:
 mount --move /the/above/dev/pts /dev/pts
 set up everything else

As the point of the bug is opening a pts when its other end is already
gone, I'm not sure we have to even do anything in the parent (maybe
open/close the ptm).

Will have a look today.

> We should be able to get a cross-namespace pty using ns_exec, but am not
> sure the set of namespaces need to be cloned -  would it be sufficient if
> we clone pid and mount namespaces and remount /dev/pts in child container ?

As my testcase doesn't know nor care about its pid, quite possibly we
would only need mount namespaces.

Best regards,
 Grzegorz Nosek
