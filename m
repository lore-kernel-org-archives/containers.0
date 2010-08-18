From: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Subject: Re: Containers vs. OpenVZ
Date: Tue, 17 Aug 2010 20:56:56 -0400
Message-ID: <20100818005656.GA2070@transpect.com>
References: <20100817103339.GA8495@nibiru.local>
	<20100818002416.GG3648@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100818002416.GG3648-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
List-Id: containers.vger.kernel.org

As someone who's not running either, but was sampling both about a month
back, my experience was (1) the current and next-to-latest openvz patches
produced kernels which couldn't really run openvz - it crashed - and it took
a couple of weeks to get a response to my bug report on that, while (2) lxc
has a very responsive development team, when I hit bugs there too, but it's
maybe 6 months out of being mature enough to really pay off for a sysadmin
of mid-level skills like me. If you're an ace, I'm sure you can get good use
now.

For what little my short-acquaintance comparison's worth, the openvz bugs
I hit were a lot more serious. It's doubtless presently more
feature-complete, when it works. But there's a lot more momentum in lxc,
plus it's mainline in the kernel so it's future's brighter.

Meanwhile I've settled on kvm, but can see some real uses for lxc in the
not-far future.

Whit
