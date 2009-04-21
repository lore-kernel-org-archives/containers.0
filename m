From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Tue, 21 Apr 2009 10:30:02 +0200
Message-ID: <20090421083001.GA8441__31189.0573510484$1240302869$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-10-git-send-email-righi.andrea@gmail.com>
	<20090417123805.GC7117@mit.edu> <20090417125004.GY4593@kernel.dk>
	<20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421001822.GB19186-3s7WtUTddSA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 20, 2009 at 08:18:22PM -0400, Theodore Tso wrote:
> On Fri, Apr 17, 2009 at 04:39:05PM +0200, Andrea Righi wrote:
> > 
> > Exactly, the purpose here is is to prioritize the dispatching of journal
> > IO requests in the IO controller. I may have used an inappropriate flag
> > or a quick&dirty solution, but without this, any cgroup/process that
> > generates a lot of journal activity may be throttled and cause other
> > cgroups/processes to be incorrectly blocked when they try to write to
> > disk.
> 
> With ext3 and ext4, all journal I/O requests end up going through
> kjournald.  So the question is what I/O control group do you put
> kjournald in?  If you unrestrict it, it makes the problem go away
> entirely.  On the other hand, it is doing work on behalf of other
> processes, and there is no real way to separate out on whose behalf
> kjournald is doing said work.  So I'm not sure fundamentally you'll be
> able to do much with any filesystem journalling activity --- and ext3
> makes life especially bad because of data=ordered mode. 

OK, I've just removed the ext3/ext4 patch from io-throttle v14 and
results are pretty the same. BTW I can't even prioritize all the
BIO_RW_SYNC, because in this way all the direct IO would be never
limited at all. Or at least I should add something like a
is_in_direct_io() check or kind of.

Anyway, I agree and I think it's reasonable to always leave kiojournald
into the root cgroup, and doesn't set any IO limit for that cgroup.

But I wouldn't add additional checks for this, at the end we know that
"Unix gives you just enough rope to hang yourself".

> 
> > > I'm assuming it's the "usual" problem with lower priority IO getting
> > > access to fs exclusive data. It's quite trivial to cause problems with
> > > higher IO priority tasks then getting stuck waiting for the low priority
> > > process, since they also need to access that fs exclusive data.
> > 
> > Right. I thought about using the BIO_RW_SYNC flag instead, but as Ted
> > pointed out, some cgroups/processes might be able to evade the IO
> > control issuing a lot of fsync()s. We could also limit the fsync()-rate
> > into the IO controller, but it sounds like a dirty workaround...
> 
> Well, if you use data=writeback or Chris Mason's proposed data=guarded
> mode, then at least all of the data blocks will be written process
> context of the application, and not kjournald's process context.  So
> one solution that might be the best that we have for now is to treat
> kjournald as special from an I/O controller point of view (i.e., give
> it its own cgroup), and then use a filesystem mode which avoids data
> blocks getting written in kjournald (i.e., ext3 data=wirteback or
> data=guarded, ext4's delayed allocation, etc.)

Agree.

> 
> One major form of leakage that you're still going to have is pdflush;
> which again, is more I/O happening in somebody else's process context.
> Ultimately I think trying to throttle I/O at write submission time
> whether at entry into block layer or in the elevators, is going to be
> highly problematic.  Suppose someone dirties a large number of pages?
> That's a system resource, and delaying the writes because a particular
> container has used more than its fair share will cause the entire
> system to run out of memory, which is not a good thing.
> 
> Ultimately, I think you'll need to do is write throttling, and suspend
> processes that are dirtying too many pages, instad of trying to
> control the I/O.

We're trying to address also this issue, setting max dirty pages limit
per cgroup, and force a direct writeback when these limits are exceeded.

In this case dirty ratio throttling should happen automatically because
the process will be throttled by the IO controller when it tries to
writeback the dirty pages and submit IO requests.

What's your opinion?

Thanks,
-Andrea
