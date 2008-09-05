From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH -mm 0/5] cgroup: block device i/o controller (v9)
Date: Fri, 5 Sep 2008 11:59:44 -0400
Message-ID: <20080905155944.GF13742@redhat.com>
References: <1219853257-11052-1-git-send-email-righi.andrea@gmail.com>
	<20080902180620.GE15847@redhat.com>
	<48BDA704.9040000@gmail.com> <20080902214146.GA3382@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080902214146.GA3382-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 02, 2008 at 05:41:46PM -0400, Vivek Goyal wrote:
> On Tue, Sep 02, 2008 at 10:50:12PM +0200, Andrea Righi wrote:
> > Vivek Goyal wrote:
> > > On Wed, Aug 27, 2008 at 06:07:32PM +0200, Andrea Righi wrote:
> > >> The objective of the i/o controller is to improve i/o performance
> > >> predictability of different cgroups sharing the same block devices.
> > >>
> > >> Respect to other priority/weight-based solutions the approach used by this
> > >> controller is to explicitly choke applications' requests that directly (or
> > >> indirectly) generate i/o activity in the system.
> > >>
> > > 
> > > Hi Andrea,
> > > 
> > > I was checking out the pass discussion on this topic and there seemed to
> > > be two kind of people. One who wanted to control max bandwidth and other
> > > who liked proportional bandwidth approach  (dm-ioband folks).
> > > 
> > > I was just wondering, is it possible to have both the approaches and let
> > > users decide at run time which one do they want to use (something like
> > > the way users can choose io schedulers).
> > > 
> > > Thanks
> > > Vivek
> > 
> > Hi Vivek,
> > 
> > yes, sounds reasonable (adding the proportional bandwidth control to my
> > TODO list).
> > 
> > Right now I've a totally experimental patch to add the ionice-like
> > functionality (it's not the same but it's quite similar to the
> > proportional bandwidth feature) on-top-of my IO controller. See below.
> > 
> > The patch is not very well tested, I don't even know if it applies
> > cleanly to the latest io-throttle patch I posted, or if it have runtime
> > failures, it needs more testing.
> > 
> > Anyway, this adds the file blockio.ionice that can be used to set
> > per-cgroup IO priorities, just like ionice, the difference is that it
> > works per-cgroup instead of per-task (it can be easily improved to
> > also support per-device priority).
> > 
> > The solution I've used is really trivial: all the tasks belonging to a
> > cgroup share the same io_context, so actually it means that they also
> > share the same disk time given by the IO scheduler and the tasks'
> > requests coming from a cgroup are considered as they were issued by a
> > single task. This works only for CFQ and AS, because deadline and noop
> > have no concept of IO contexts.
> > 
> 
> Probably we don't want to share io contexts among the tasks of same cgroup
> because then requests from all the tasks of the cgroup will be queued
> on the same cfq queue and we will loose the notion of task priority.
> 
> (I think you already covered this point in next paragraph.)
> 
> Maybe we need to create cgroup ids (the way bio-cgroup patchset does).
> 
> > I would also like to merge the Satoshi's cfq-cgroup functionalities to
> > provide "fairness" also within each cgroup, but the drawback is that it
> > would work only for CFQ.
> > 
> 
> I thought that implementation at generic layer can provide the fairness
> between various cgroups (based on their weight/priority) and then fairness
> within cgroup will be provided by respecitve IO scheduler (Depending on what
> kind of fairness notion IO scheduler carries, for example task priority in
> cfq.).
> 
> So at generic layer we probably need to just think about how to keep track
> of various cgroups per device (probably in a rb tree like cpu scheduler)
> and how to schedule these cgroups to submit request to IO scheduer, based
> on cgroup weight/priority.
> 

Ok, to be more specific, I was thinking of following.

Currently, all the requests for a block device go into request queue in
a linked list and then associated elevator selects the best request for
dispatch based on various policies as dictated by elevator.

Can we maintan an rb-tree per request queue and all the requests being
queued on that request queue first will go in this rb-tree. Then based on
cgroup grouping and control policy (max bandwidth capping, proportional
bandwidth etc), one can pass the requests to elevator associated with the
queue (which will do the actual job of merging and other things).

So effectively first we provide control at cgroup level and then let
elevator take the best decisions with in that.

This should not require creation of any dm-ioband devices to control the
devices. Each block device will contain one rb-tree (cgroups hanging) as
long has somebody has put a controlling policy on that devices. (We can
probably use your interfaces to create policies on devices through cgroup
files).

This should not require elevator modifications and should work well with
stacked devices. 

I will try to write some prototype patches and see if all the above
gibber makes any sense and is workable or not.

One limitation in this scheme is that we are providing grouping capability
based on cgroups only and it is not as generic what dm-ioband is providing.
Do we really require other ways of creating grouping. Creating another device
for each device you want to control sounds odd to me.

Thanks
Vivek
