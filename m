From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Tue, 05 Aug 2008 22:17:17 +0900 (JST)
Message-ID: <20080805.221717.112609710.ryov__7505.8157126934$1217942370$gmane$org@valinux.co.jp>
References: <489748E6.5080106@gmail.com>
	<000901c8f6a5$fe64ba30$fb2e2e90$@jp.nec.com>
	<48981D3B.2020701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48981D3B.2020701-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Andrea, Satoshi and all,

Thanks for giving a chance to discuss.

> Mr. Andrew gave a advice "Should discuss about design more and more"
> to me.
> And, in Containers Mini-summit (and Linux Symposium 2008 in Ottawa),
> Paul said that a necessary to us is to decide a requirement first.
> So, we must discuss requirement and design.

We've implemented dm-ioband and bio-cgroup to meet the following requirements:
    * Assign some bandwidth to each group on the same device.
      A group is a set of processes, which may be a cgroup.
    * Assign some bandwidth to each partition on the same device.
      It can work with the process group based bandwidth control.
        ex) With this feature, you can assign 40% of the bandwidth of a
	    disk to /root and 60% of them to /usr.
    * It can work with virtual machines such as Xen and KVM.
      I/O requests issued from virtual machines have to be controlled.
    * It should work any type of I/O scheduler, including ones which
      will be released in the future.
    * Support multiple devices which share the same bandwidth such as
      raid disks and LVM.   
    * Handle asynchronous I/O requests such as AIO request and delayed 
      write requests.
        - This can be done with bio-cgroup, which uses the page-tracking
	  mechanism the cgroup memory controller has.
    * Control dirty page ratio.
        - This can be done with the cgroup memory controller in the near
	  feature. It would be great that you can also use other features
	  the memory controller is going to have with dm-ioband.
    * Make it easy to enhance.
        - The current implementation of dm-ioband has an interface to
	  add a new policy to control I/O requests. You can easily add
	  I/O throttling policy if you want.
    * Fine grained bandwidth control.
    * Keep I/O throughput.
    * Make it scalable.
    * It should work correctly if the I/O load is quite high,
      even when the io-request queue of a certain disk is overflowed.

> Ryo, do you have other documentation besides the info reported in the
> dm-ioband website?

I don't have any documentation besides in the website.

Thanks,
Ryo Tsuruta
