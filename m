From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 09:58:30 -0400
Message-ID: <20120914135830.GB6221@redhat.com>
References: <20120913205827.GO7677@google.com>
	<20120914091032.GA6819@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120914091032.GA6819-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 14, 2012 at 10:10:32AM +0100, Daniel P. Berrange wrote:

[..]
> > 6. Multiple hierarchies
> > 
> >   Apart from the apparent wheeeeeeeeness of it (I think I talked about
> >   that enough the last time[1]), there's a basic problem when more
> >   than one controllers interact - it's impossible to define a resource
> >   group when more than two controllers are involved because the
> >   intersection of different controllers is only defined in terms of
> >   tasks.
> > 
> >   IOW, if an entity X is of interest to two controllers, there's no
> >   way to map X to the cgroups of the two controllers.  X may belong to
> >   A and B when viewed by one task but A' and B when viewed by another.
> >   This already is a head scratcher in writeback where blkcg and memcg
> >   have to interact.
> > 
> >   While I am pushing for unified hierarchy, I think it's necessary to
> >   have different levels of granularities depending on controllers
> >   given that nesting involves significant overhead and noticeable
> >   controller-dependent behavior changes.
> > 
> >   Solution:
> > 
> >   I think a unified hierarchy with the ability to ignore subtrees
> >   depending on controllers should work.  For example, let's assume the
> >   following hierarchy.
> > 
> >           R
> > 	/   \
> >        A     B
> >       / \
> >      AA AB
> > 
> >   All controllers are co-mounted.  There is per-cgroup knob which
> >   controls which controllers nest beyond it.  If blkio doesn't want to
> >   distinguish AA and AB, the user can specify that blkio doesn't nest
> >   beyond A and blkio would see the tree as,
> > 
> >           R
> > 	/   \
> >        A     B
> > 
> >   While other controllers keep seeing the original tree.  The exact
> >   form of interface, I don't know yet.  It could be a single file
> >   which the user echoes [-]controller name into it or per-controller
> >   boolean file.
> > 
> >   I think this level of flexibility should be enough for most use
> >   cases.  If someone disagrees, please voice your objections now.

Tejun, Daniel,

I am little concerned about above and wondering how systemd and libvirt
will interact and behave out of the box.

Currently systemd does not create its own hierarchy under blkio and
libvirt does. So putting all together means there is no way to avoid
the overhead of systemd created hierarchy.

\
|
+- system
     |
     +- libvirtd.service
              |
              +- virt-machine1
              +- virt-machine2

So there is now way to avoid the overhead of two levels of hierarchy
created by systemd. I really wish that systemd gets rid of "system"
cgroup and puts services directly in top level group. Creating deeper
hieararchices is expensive.

I just want to mention it clearly that with above model, it will not
be possible for libvirt to avoid hierarchy levels created by systemd.
So solution would be to keep depth of hierarchy as low as possible and
to keep controller overhead as low as possible.

Now I know that with blkio idling kills performance. So one solution
could be that on anything fast, don't use CFQ. Use deadline and then
group idling overhead goes away and tools like systemd and libvirt don't
have to worry about keeping track of disks and what scheduler is running.
They don't want to do it and expect kernel to get it right.

But getting that right out of box does not happen as of today as CFQ
is default on everything. Distributions can carry their own patches
to do some approximation, but it would be better to have a better
mechanism in kernel to select better IO scheduler out of box for a
storage lun. It is more important now then even since blkio controller
has come into picture.

Above is the scenario I am most worried about where CFQ shows up by default
on all the luns, systemd and libvirt create 4-5 level deep hierarchies
by default and IO performance sucks out of the box. Already CFQ underforms
for fast storage and with group creation problem becomes worse.

Thanks
Vivek
