From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Tue, 21 Jul 2009 23:41:20 -0700
Message-ID: <20090722064120.GA24373@us.ibm.com>
References: <20090713190211.GA4208@us.ibm.com>
	<20090713193058.GL18617@megiteam.pl>
	<20090713202610.GA6447@us.ibm.com>
	<20090713223444.GM18617@megiteam.pl>
	<20090714064905.GA25278@us.ibm.com>
	<20090714103129.GB12958@megiteam.pl>
	<20090715044744.GA25745@us.ibm.com>
	<20090715131923.GB21417@megiteam.pl>
	<20090718205244.GA23625@us.ibm.com>
	<20090719071531.GA20818@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090719071531.GA20818-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
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
| Hi,
| 
| On sob, lip 18, 2009 at 01:52:44 -0700, Sukadev Bhattiprolu wrote:
| > 	virsh --connect lxc:/// start lxc-vm2
| > 
| > Is that what you mean by "just run" :-) ?
| > If so, I have to first resolve my unrelated problem with libvirtd+lxc.
| > 
| > Running "ns_exec -cpuim ./tty-bug", I dont get the failure with 2.6.31-rc3
| > on a Fedora 11 KVM.
| 
| I get the oops by simply running the program, without libvirtd,
| lxc-tools or ns_exec (it sets up a mount namespace itself). Are you
| running with slub debugging (poisoning) enabled? 

I set 
	CONFIG_SLUB_DEBUG=y
	CONFIG_SLUB=y
	CONFIG_SLUB_DEBUG_ON=y
	# CONFIG_SLUB_STATS is not set

and tried 2.6.29, 2.6.31-rc3 and linux-mmotm from July 13, but have
not been able to repro either on an i386 machine or on a KVM guest.

I run your program ./tty-bug in a tight loop. I will try to run the
program overnight in a loop. 

Given that your program does not depend on NET_NS, can you see if you
can repro on 2.6.28 and see if we can bisect this problem ?

| The bug causes
| access to freed memory, so otherwise often nothing will happen
| (the memory won't have been overwritten yet).
| 
| OTOH, I haven't tried 2.6.31-rc3 either (but it doesn't look like fixed
| there too).
| 
| Best regards,
|  Grzegorz Nosek
