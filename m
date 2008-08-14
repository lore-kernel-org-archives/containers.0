From: David Collier-Brown <davecb-xsfywfwIY+M@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Thu, 14 Aug 2008 07:18:13 -0400
Message-ID: <48A41475.4070108__32902.5685591207$1218727394$gmane$org@sun.com>
References: <1218117578.11703.81.camel@sebastian.kern.oss.ntt.co.jp>
	<48A0A689.40908@gmail.com> <loom.20080812T071504-212@post.gmane.org>
	<20080812.201025.57762305.taka@valinux.co.jp>
	<48A18854.9020000@gmail.com>
Reply-To: davecb-xsfywfwIY+M@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <48A18854.9020000-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> A more complicated issue is how to evaluate the total IO bandwidth of a
> generic device. We can use some kind of averaging/prediction, but
> basically it would be inaccurate due to the mechanic of disks (head
> seeks, but also caching, buffering mechanisms implemented directly into
> the device, etc.). It's a hard problem. And the same problem exists also
> for proportional bandwidth as well, in terms of IO rate predictability I
> mean.

  Actually it's a little-known easy problem.

  The capacity planning community does it all the time, but then describes
it in terms that are only interesting (intelligible?) to an enthusiastic
amateur mathematician (;-))

  One finds the point, called N*, at which the throughput flattens
out and and the response time starts to grow without bounds, and
calls that level the maximum.

  In practice, one does an easier variant.  One sets a response-time 
limit and throttles *everyone* proportionally when th disk starts to 
regularly degrade beyond the limit.  Interestingly, because we're 
slowing the application to prevent slowing the disks, the value we 
pick needn't be terribly precise.  It also doesn't require any pre-
knowledge about the disks.

  Send me a note if you want to discuss this in more detail.

--dave
-- 
David Collier-Brown            | Always do right. This will gratify
Sun Microsystems, Toronto      | some people and astonish the rest
davecb-xsfywfwIY+M@public.gmane.org                 |                      -- Mark Twain
cell: (647) 833-9377, bridge: (877) 385-4099 code: 506 9191#
