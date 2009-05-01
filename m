From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/9] cgroup: io-throttle controller (v13)
Date: Fri, 1 May 2009 13:11:22 +0200
Message-ID: <20090501111121.GA25964__2192.32035237855$1241176451$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<49F9A5BA.9030100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49F9A5BA.9030100-VXdhtT5mjnY@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Alan D. Brunelle" <Alan.Brunelle-VXdhtT5mjnY@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 30, 2009 at 09:20:58AM -0400, Alan D. Brunelle wrote:
> Hi Andrea -

Hi Alan,

> 
> FYI: I ran a simple test using this code to try and gauge the overhead
> incurred by enabling this technology. Using a single 400GB volume split
> into two 200GB partitions I ran two processes in parallel performing a
> mkfs (ext2) on each partition. First w/out cgroup io-throttle and then
> with it enabled (with each task having throttling enabled to
> 400MB/second (much, much more than the device is actually capable of
> doing)). The idea here is to see the base overhead of just having the
> io-throttle code in the paths.

Interesting. I've never explicitly measured the actual overhead of the
io-throttle infrastructure, I'll add a similar test to the io-throttle
testcase.

> 
> Doing 30 runs of each (w/out & w/ io-throttle enabled) shows very little
> difference (time in seconds)
> 
> w/out: min=80.196 avg=80.585 max=81.030 sdev=0.215 spread=0.834
> with:  min=80.402 avg=80.836 max=81.623 sdev=0.327 spread=1.221
> 
> So only around 0.3% overhead - and that may not be conclusive with the
> standard deviations seen.

You should see less overhead with reads respect to a pure write
workload, because with reads we don't need to check if the IO request
occurs in a different IO context. And things should be improved with
v16-rc1
(http://download.systemimager.org/~arighi/linux/patches/io-throttle/cgroup-io-throttle-v16-rc1.patch).

So, it would be also interesting to analyse the overhead of a read
stream compared to a write stream, as well a comparison of random
reads/writes. I'll do that in my next benchmarking session.

> 
> --
> 
> FYI: The test was run on 2.6.30-rc1+your patches on a 16-way x86_64 box
> (128GB RAM) plus a single FC volume off of a 1Gb FC RAID controller.
> 
> Regards,
> Alan D. Brunelle
> Hewlett-Packard

Thanks for posting these results,
-Andrea
