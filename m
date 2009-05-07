From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Fri, 8 May 2009 00:40:04 +0200
Message-ID: <20090507224003.GB29774__40108.9729312391$1241736676$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
	<20090507141126.GA9463@redhat.com>
	<20090507144501.GB9463@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507144501.GB9463-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 10:45:01AM -0400, Vivek Goyal wrote:
> So now we are left with the issue of loosing the notion of priority and
> class with-in cgroup. In fact on bigger systems we will probably run into
> issues of kiothrottled scalability as single thread is trying to cater to
> all the disks.
> 
> If we do max bw control at IO scheduler level, then I think we should be able
> to control max bw while maintaining the notion of priority and class with-in
> cgroup. Also there are multiple pdflush threads and jens seems to be pushing
> flusher threads per bdi which will help us achieve greater scalability and
> don't have to replicate that infrastructure for kiothrottled also.

There's a lot of room for improvements and optimizations in the
kiothrottled part, obviously the single-threaded approach is not a
definitive solutions.

Flusher threads are probably a good solution. But I don't think we need
to replicate the pdflush replacement infrastructure for throttled
writeback IO. Instead it could be just integrated with the flusher
threads, i.e. activate flusher threads only when the request needs to be
written to disk according to the dirty memory limit and IO BW limits.

I mean, I don't see any critical problem for this part.

Instead, preserving the IO priority and IO scheduler logic inside
cgroups seems a more critical issue to me. And I'm quite convinced that
the right approach for this is to operate at the IO scheduler, but I'm
still a little bit skeptical that only operating at the IO scheduler
level would resolve all our problems.

-Andrea
