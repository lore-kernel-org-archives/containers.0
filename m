From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [Xen-devel] dm-band: The I/O bandwidth controller: Performance
 Report
Date: Wed, 30 Jan 2008 12:32:02 +0900 (JST)
Message-ID: <20080130.123202.189729685.ryov__45961.5877517082$1201664037$gmane$org@valinux.co.jp>
References: <20080123.215350.193721890.ryov@valinux.co.jp>
	<20080125.160720.183032233.ryov@valinux.co.jp>
	<479ECAC9.5070709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <479ECAC9.5070709-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: inakoshi.hiroya-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> you mean that you run 128 processes on each user-device pairs?  Namely,
> I guess that
> 
>   user1: 128 processes on sdb5,
>   user2: 128 processes on sdb5,
>   another: 128 processes on sdb5,
>   user2: 128 processes on sdb6.

"User-device pairs" means "band groups", right?
What I actually did is the followings:

  user1: 128 processes on sdb5,
  user2: 128 processes on sdb5,
  user3: 128 processes on sdb5,
  user4: 128 processes on sdb6.

> The second preliminary studies might be:
> - What if you use a different I/O size on each device (or device-user pair)?
> - What if you use a different number of processes on each device (or
> device-user pair)?

There are other ideas of controlling bandwidth, limiting bytes-per-sec,
latency time or something. I think it is possible to implement it if 
a lot of people really require it. I feel there wouldn't be a single
correct answer for this issue. Posting good ideas how it should work
and submitting patches for it are also welcome.

> And my impression is that it's natural dm-band is in device-mapper,
> separated from I/O scheduler.  Because bandwidth control and I/O
> scheduling are two different things, it may be simpler that they are
> implemented in different layers.

I would like to know how dm-band works on various configurations on
various type of hardware. I'll try running dm-band on with other
configurations. Any reports or impressions of dm-band on your machines
are also welcome.

Thanks,
Ryo Tsuruta
