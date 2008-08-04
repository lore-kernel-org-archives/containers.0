From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Mon, 04 Aug 2008 20:22:30 +0200
Message-ID: <489748E6.5080106__10834.4633634717$1217874374$gmane$org@gmail.com>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217870433.20260.101.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Mon, 2008-08-04 at 17:51 +0900, Ryo Tsuruta wrote:
>> This series of patches of dm-ioband now includes "The bio tracking mechanism,"
>> which has been posted individually to this mailing list.
>> This makes it easy for anybody to control the I/O bandwidth even when
>> the I/O is one of delayed-write requests.
> 
> During the Containers mini-summit at OLS, it was mentioned that there
> are at least *FOUR* of these I/O controllers floating around.  Have you
> talked to the other authors?  (I've cc'd at least one of them).
> 
> We obviously can't come to any kind of real consensus with people just
> tossing the same patches back and forth.
> 
> -- Dave
> 

Dave,

thanks for this email first of all. I've talked with Satoshi (cc-ed)
about his solution "Yet another I/O bandwidth controlling subsystem for
CGroups based on CFQ".

I did some experiments trying to implement minimum bandwidth requirements
for my io-throttle controller, mapping the requirements to CFQ prio and
using the Satoshi's controller. But this needs additional work and
testing right now, so I've not posted anything yet, just informed
Satoshi about this.

Unfortunately I've not talked to Ryo yet. I've continued my work using a
quite different approach, because the dm-ioband solution didn't work
with delayed-write requests. Now the bio tracking feature seems really
prosiming and I would like to do some tests ASAP, and review the patch
as well.

But I'm not yet convinced that limiting the IO writes at the device
mapper layer is the best solution. IMHO it would be better to throttle
applications' writes when they're dirtying pages in the page cache (the
io-throttle way), because when the IO requests arrive to the device
mapper it's too late (we would only have a lot of dirty pages that are
waiting to be flushed to the limited block devices, and maybe this could
lead to OOM conditions). IOW dm-ioband is doing this at the wrong level
(at least for my requirements). Ryo, correct me if I'm wrong or if I've
not understood the dm-ioband approach.

Another thing I prefer is to directly define bandwidth limiting rules,
instead of using priorities/weights (i.e. 10MiB/s for /dev/sda), but
this seems to be in the dm-ioband TODO list, so maybe we can merge the
work I did in io-throttle to define such rules.

Anyway, I still need to look at the dm-ioband and bio-cgroup code in
details, so probably all I said above is totally wrong...

-Andrea
