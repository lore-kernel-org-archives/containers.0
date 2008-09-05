From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH -mm 0/5] cgroup: block device i/o controller (v9)
Date: Fri, 05 Sep 2008 19:38:26 +0200
Message-ID: <48C16E92.5000402__27625.1402953223$1220636533$gmane$org@gmail.com>
References: <1219853257-11052-1-git-send-email-righi.andrea@gmail.com>
	<20080902180620.GE15847@redhat.com>
	<48BDA704.9040000@gmail.com> <20080902214146.GA3382@redhat.com>
	<20080905155944.GF13742@redhat.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080905155944.GF13742-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> Ok, to be more specific, I was thinking of following.
> 
> Currently, all the requests for a block device go into request queue in
> a linked list and then associated elevator selects the best request for
> dispatch based on various policies as dictated by elevator.
> 
> Can we maintan an rb-tree per request queue and all the requests being
> queued on that request queue first will go in this rb-tree. Then based on
> cgroup grouping and control policy (max bandwidth capping, proportional
> bandwidth etc), one can pass the requests to elevator associated with the
> queue (which will do the actual job of merging and other things).

Could a workqueue like kblockd move requests from rb-tree to the equivalent
request queue?

> 
> So effectively first we provide control at cgroup level and then let
> elevator take the best decisions with in that.

I think I've to figure better all the implementation details, but yes,
sounds good. This seems to be the right approach to provide any kind of
IO controlling: bandwidth throttling, proportional bandwidth,
ionice-like approach, etc.

> This should not require creation of any dm-ioband devices to control the
> devices. Each block device will contain one rb-tree (cgroups hanging) as
> long has somebody has put a controlling policy on that devices. (We can
> probably use your interfaces to create policies on devices through cgroup
> files).
> 
> This should not require elevator modifications and should work well with
> stacked devices. 
> 
> I will try to write some prototype patches and see if all the above
> gibber makes any sense and is workable or not.

That would be great!

> 
> One limitation in this scheme is that we are providing grouping capability
> based on cgroups only and it is not as generic what dm-ioband is providing.
> Do we really require other ways of creating grouping. Creating another device
> for each device you want to control sounds odd to me.

In any case libcgroup could help here to define any grouping policy
(uid, gid, pid, ...). So, IMHO the grouping capability provided by
cgroups is in perspective generic as well as what dm-ioband provides.

Thanks,
-Andrea
