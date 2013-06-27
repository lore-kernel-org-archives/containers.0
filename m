From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup access daemon
Date: Thu, 27 Jun 2013 13:11:08 -0500
Message-ID: <20130627181108.GA26334@sergelap>
References: <CAAAKZwuKxxYoVRn6Ye72Vs7vSd_T4cbvEwiU6Q3j4D-Z+VAPrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAAAKZwuKxxYoVRn6Ye72Vs7vSd_T4cbvEwiU6Q3j4D-Z+VAPrw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tim Hockin (thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org):
> Changing the subject, so as not to mix two discussions
> 
> On Thu, Jun 27, 2013 at 9:18 AM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> > FWIW, the code is too embarassing yet to see daylight, but I'm playing
> >> > with a very lowlevel cgroup manager which supports nesting itself.
> >> > Access in this POC is low-level ("set freezer.state to THAWED for cgroup
> >> > /c1/c2", "Create /c3"), but the key feature is that it can run in two
> >> > modes - native mode in which it uses cgroupfs, and child mode where it
> >> > talks to a parent manager to make the changes.
> >>
> >> In this world, are users able to read cgroup files, or do they have to
> >> go through a central agent, too?
> >
> > The agent won't itself do anything to stop access through cgroupfs, but
> > the idea would be that cgroupfs would only be mounted in the agent's
> > mntns.  My hope would be that the libcgroup commands (like cgexec,
> > cgcreate, etc) would know to talk to the agent when possible, and users
> > would use those.
> 
> For our use case this is a huge problem.  We have people who access
> cgroup files in a fairly tight loops, polling for information.  We
> have literally hundeds of jobs running on sub-second frequencies -
> plumbing all of that through a daemon is going to be a disaster.
> Either your daemon becomes a bottleneck, or we have to build something
> far more scalable than you really want to.  Not to mention the
> inefficiency of inserting a layer.

Currently you can trivially create a container which has the
container's cgroups bind-mounted to the expected places
(/sys/fs/cgroup/$controller) by uncommenting two lines in the
configuration file, and handle cgroups through cgroupfs there.
(This is what the management agent wants to be an alternative
for)  The main deficiency there is that /proc/self/cgroups is
not filtered, so it will show /lxc/c1 for init's cgroup, while
the host's /sys/fs/cgroup/devices/lxc/c1/c1.real will be what
is seen under the container's /sys/fs/cgroup/devices (for
instance).  Not ideal.

> We also need the ability to set up eventfds for users or to let them
> poll() on the socket from this daemon.

So you'd want to be able to request updates when any cgroup value
is changed, right?

That's currently not in my very limited set of commands, but I can
certainly add it, and yes it would be a simple unix sock so you can
set up eventfd, select/poll, etc.

> >> > So then the idea would be that userspace (like libvirt and lxc) would
> >> > talk over /dev/cgroup to its manager.  Userspace inside a container
> >> > (which can't actually mount cgroups itself) would talk to its own
> >> > manager which is talking over a passed-in socket to the host manager,
> >> > which in turn runs natively (uses cgroupfs, and nests "create /c1" under
> >> > the requestor's cgroup).
> >>
> >> How do you handle updates of this agent?  Suppose I have hundreds of
> >> running containers, and I want to release a new version of the cgroupd
> >> ?
> >
> > This may change (which is part of what I want to investigate with some
> > POC), but right now I'm building any controller-aware smarts into it.  I
> > think that's what you're asking about?  The agent doesn't do "slices"
> > etc.  This may turn out to be insufficient, we'll see.
> 
> No, what I am asking is a release-engineering problem.  Suppose we
> need to roll out a new version of this daemon (some new feature or a
> bug or something).  We have hundreds of these "child" agents running
> in the job containers.

When I say "container" I mean an lxc container, with it's own isolated
rootfs and mntns.  I'm not sure what your "containers" are, but I if
they're not that, then they shouldn't need to run a child agent.  They
can just talk over the host cgroup agent's socket.

> How do I bring down all these children, and then bring them back up on
> a new version in a way that does not disrupt user jobs (much)?
> 
> Similarly, what happens when one of these child agents crashes?  Does
> someone restart it?  Do user jobs just stop working?

An upstart^W$init_system job will restart it...

-serge
