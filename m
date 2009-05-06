From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 6 May 2009 22:42:51 +0200
Message-ID: <20090506204249.GB4282__19747.6623616696$1241643125$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<1241562049.11059.921.camel@twins>
	<20090506034254.GD4416@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090506034254.GD4416-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, May 06, 2009 at 09:12:54AM +0530, Balbir Singh wrote:
> * Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> [2009-05-06 00:20:49]:
> 
> > On Tue, 2009-05-05 at 13:24 -0700, Andrew Morton wrote:
> > > On Tue,  5 May 2009 15:58:27 -0400
> > > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > 
> > > > 
> > > > Hi All,
> > > > 
> > > > Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
> > > > ...
> > > > Currently primarily two other IO controller proposals are out there.
> > > > 
> > > > dm-ioband
> > > > ---------
> > > > This patch set is from Ryo Tsuruta from valinux.
> > > > ...
> > > > IO-throttling
> > > > -------------
> > > > This patch set is from Andrea Righi provides max bandwidth controller.
> > > 
> > > I'm thinking we need to lock you guys in a room and come back in 15 minutes.
> > > 
> > > Seriously, how are we to resolve this?  We could lock me in a room and
> > > cmoe back in 15 days, but there's no reason to believe that I'd emerge
> > > with the best answer.
> > > 
> > > I tend to think that a cgroup-based controller is the way to go. 
> > > Anything else will need to be wired up to cgroups _anyway_, and that
> > > might end up messy.
> > 
> > FWIW I subscribe to the io-scheduler faith as opposed to the
> > device-mapper cult ;-)
> > 
> > Also, I don't think a simple throttle will be very useful, a more mature
> > solution should cater to more use cases.
> >
> 
> I tend to agree, unless Andrea can prove us wrong. I don't think
> throttling a task (not letting it consume CPU, memory when its IO
> quota is exceeded) is a good idea. I've asked that question to Andrea
> a few times, but got no response.

Sorry Balbir, I probably missed your question. Or replied in a different
thread maybe...

Actually we could allow an offending cgroup to continue to submit IO
requests without throttling it directly. But if we don't want to waste
the memory with pending IO requests or pending writeback pages, we need
to block it sooner or later.

Instead of directly throttle the offending applications, we could block
them when we hit a max limit of requests or dirty pages, i.e. something
like congestion_wait(), but that's the same, no? the difference is that
in this case throttling is asynchronous. Or am I oversimplifying it?

As an example, with writeback IO io-throttle doesn't throttle the IO
requests directly, each request instead receives a deadline (depending
on the BW limit) and it's added into a rbtree. Then all the requests are
dispatched asynchronously using a kernel thread (kiothrottled) only when
the deadline is expired.

OK, there's a lot of space for improvements: provide many kernel threads
per block device, multiple queues/rbtrees, etc., but this is actually a
way to apply throttling asynchronously. The fact is that if I don't
apply the throttling also in balance_dirty_pages() (and I did so in the
last io-throttle version) or add a max limit of requests the rbtree
increases indefinitely...

That should be very similar to the proportional BW solution allocating a
quota of nr_requests per block device and per cgroup.

-Andrea
