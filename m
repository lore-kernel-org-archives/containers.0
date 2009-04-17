From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Sat, 18 Apr 2009 01:12:45 +0200
Message-ID: <20090417231244.GB6972__23325.9214474403$1240010255$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417173955.GF29086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417173955.GF29086-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 01:39:55PM -0400, Vivek Goyal wrote:
> On Tue, Apr 14, 2009 at 10:21:12PM +0200, Andrea Righi wrote:
> 
> [..]
> > +4.2. Buffered I/O (write-back) tracking
> > +
> > +For buffered writes the scenario is a bit more complex, because the writes in
> > +the page cache are processed asynchronously by kernel threads (pdflush), using
> > +a write-back policy. So the real writes to the underlying block devices occur
> > +in a different I/O context respect to the task that originally generated the
> > +dirty pages.
> > +
> > +The I/O bandwidth controller uses the following solution to resolve this
> > +problem.
> > +
> > +If the operation is a buffered write, we can charge the right cgroup looking at
> > +the owner of the first page involved in the I/O operation, that gives the
> > +context that generated the I/O activity at the source. This information can be
> > +retrieved using the page_cgroup functionality originally provided by the cgroup
> > +memory controller [4], and now provided specifically by the bio-cgroup
> > +controller [5].
> > +
> > +In this way we can correctly account the I/O cost to the right cgroup, but we
> > +cannot throttle the current task in this stage, because, in general, it is a
> > +different task (e.g., pdflush that is processing asynchronously the dirty
> > +page).
> > +
> > +For this reason, all the write-back requests that are not directly submitted by
> > +the real owner and that need to be throttled are not dispatched immediately in
> > +submit_bio(). Instead, they are added into an rbtree and processed
> > +asynchronously by a dedicated kernel thread: kiothrottled.
> > +
> 
> Hi Andrea,

Hi Vivek,

> 
> I am trying to go through your patches now and also planning to test it

thanks for trying to test first of all.

> out. While reading the documentation async write handling interested
> me. IIUC, looks like you are throttling writes once they are being 
> written to the disk (either by pdflush or in the context of the process
> because vm_dirty_ratio crossed etc).

Correct, more exactly in submit_bio().

The difference between synchronous IO and writeback IO is that in the
first case the task itself is throttled via schedule_timeout_killable();
in the second case pdflush is never throttled, the IO requests instead
are simply added into a rbtree and dispatched asynchronously by another
kernel thread (kiothrottled) using a EDF-like scheduling. More exactly,
a deadline is evaluated for each writeback IO request looking at the
cgroup BW and iops/sec limits, then kiothrottled periodically selects
and dispatches the requests with an elapsed deadline.

> 
> If that's the case, will a process not see an increased rate of writes
> till we are not hitting dirty_background_ratio?

Correct. And this is a good behaviour IMHO. At the same time we have a
smooth BW usage (according to the cgroup limits I mean) even in presence
of writeback IO only.

> 
> Secondly, if above is giving acceptable performance resutls, then we
> should be able to provide max bw control at IO scheduler level (along
> with proportional bw control)?
> 
> So instead of doing max bw and proportional bw implementation in two
> places with the help of different controllers, I think we can do it
> with the help of one controller at one place. 
> 
> Please do have a look at my patches also to figure out if that's possible
> or not. I think it should be possible.
> 
> Keeping both at single place should simplify the things.

Absolutely agree to do both proportional and max BW limiting in a single
place. I still need to figure which is the best place, if the IO
scheduler in the elevator, when the IO requests are submitted. A natural
way IMHO is to control the submission of requests, also Andrew seemed to
be convinced about this approach. Anyway, I've already scheduled to test
your patchset and I'd like to see if it's possible to merge our works,
or select the best from ours patchsets.

Thanks!
-Andrea
