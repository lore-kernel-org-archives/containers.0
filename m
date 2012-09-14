From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 10:10:32 +0100
Message-ID: <20120914091032.GA6819@redhat.com>
References: <20120913205827.GO7677@google.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913205827.GO7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 13, 2012 at 01:58:27PM -0700, Tejun Heo wrote:
> 5. I CAN HAZ HIERARCHIES?
> 
>   The cpu ones handle nesting correctly - parent's accounting includes
>   children's, parent's configuration affects children's unless
>   explicitly overridden, and children's limits nest inside parent's.
> 
>   memcg asked itself the existential question of to be hierarchical or
>   not and then got confused and decided to become both.
> 
>   When faced with the same question, blkio and cgroup_freezer just
>   gave up and decided to allow nesting and then ignore it - brilliant.
> 
>   And there are others which kinda sorta try to handle hierarchy but
>   only goes way-half.
> 
>   This one is screwed up embarrassingly badly.  We failed to establish
>   one of the most basic semantics and can't even define what a cgroup
>   hierarchy is - it depends on each controller and they're mostly
>   wacky!
> 
>   Fortunately, I don't think it will be prohibitively difficult to dig
>   ourselves out of this hole.
> 
>   Solution:
> 
>   * cpu ones seem fine.
> 
>   * For broken controllers, cgroup core will be generating warning
>     messages if the user tries to nest cgroups so that the user at
>     least can know that the behavior may change underneath them later
>     on.  For more details,
> 
>     http://thread.gmane.org/gmane.linux.kernel/1356264/focus=3902
> 
>   * memcg can be fully hierarchical but we need to phase out the flat
>     hierarchy support.  Unfortunately, this involves flipping the
>     behavior for the existing users.  Upstream will try to nudge users
>     with warning messages.  Most burden would be on the distros and at
>     least SUSE seems to be on board with it.  Needs coordination with
>     other distros.
> 
>   * blkio is the most problematic.  It has two sub-controllers - cfq
>     and blk-throttle.  Both are utterly broken in terms of hierarchy
>     support and the former is known to have pretty hairy code base.  I
>     don't see any other way than just biting the bullet and fixing it.
> 
>   * cgroup_freezer and others shouldn't be too difficult to fix.
> 
>   Who:
> 
>   memcg can be handled by memcg people and I can handle cgroup_freezer
>   and others with help from the authors.  The problematic one is
>   blkio.  If anyone is interested in working on blkio, please be my
>   guest.  Vivek?  Glauber?
> 
> 6. Multiple hierarchies
> 
>   Apart from the apparent wheeeeeeeeness of it (I think I talked about
>   that enough the last time[1]), there's a basic problem when more
>   than one controllers interact - it's impossible to define a resource
>   group when more than two controllers are involved because the
>   intersection of different controllers is only defined in terms of
>   tasks.
> 
>   IOW, if an entity X is of interest to two controllers, there's no
>   way to map X to the cgroups of the two controllers.  X may belong to
>   A and B when viewed by one task but A' and B when viewed by another.
>   This already is a head scratcher in writeback where blkcg and memcg
>   have to interact.
> 
>   While I am pushing for unified hierarchy, I think it's necessary to
>   have different levels of granularities depending on controllers
>   given that nesting involves significant overhead and noticeable
>   controller-dependent behavior changes.
> 
>   Solution:
> 
>   I think a unified hierarchy with the ability to ignore subtrees
>   depending on controllers should work.  For example, let's assume the
>   following hierarchy.
> 
>           R
> 	/   \
>        A     B
>       / \
>      AA AB
> 
>   All controllers are co-mounted.  There is per-cgroup knob which
>   controls which controllers nest beyond it.  If blkio doesn't want to
>   distinguish AA and AB, the user can specify that blkio doesn't nest
>   beyond A and blkio would see the tree as,
> 
>           R
> 	/   \
>        A     B
> 
>   While other controllers keep seeing the original tree.  The exact
>   form of interface, I don't know yet.  It could be a single file
>   which the user echoes [-]controller name into it or per-controller
>   boolean file.
> 
>   I think this level of flexibility should be enough for most use
>   cases.  If someone disagrees, please voice your objections now.
> 
>   I *think* this can be achieved by changing where css_set is bound.
>   Currently, a css_set is (conceptually) owned by a task.  After the
>   change, a cgroup in the unified hierarchy has its own css_set which
>   tasks point to and can also be used to tag resources as necessary.
>   This way, it should be achieveable without introducing a lot of new
>   code or affecting individual controllers too much.
> 
>   The headache will be the transition period where we'll probably have
>   to support both modes of operation.  Oh well....
> 
>   Who:
> 
>   Li, Glauber and me, I guess?

FWIW, from the POV of libvirt and its KVM/LXC drivers, I think that
co-mounting all controllers is just fine. In our usage model we
always want to have exactly the same hierarchy for all of them. It
rather complicates life to have to deal with multiple hierarchies,
so I'd be happy if they went away.

libvirtd will always create its own cgroups starting at the location
where libvirtd itself has been placed. This is to co-operate with
systemd / initscripts which may place each system service in a
dedicated group. Thus historically we usually end up in a layout:

 $CG_MOUNT_ROOT
  |
  +- apache.service
  +- mysql.service
  +- sendmail.service
  +- ....service
  +- libvirtd.service (if systemd has put us in an isolated group)
      |
      +- libvirt
          |
          +- lxc
          |   |
          |   +- container1
          |   +- container2
          |   +- container3
          |   ...
          +- qemu
              |
              +- machine1
              +- machine2
              +- machine3
              ...

Now we know that many controllers don't respect this hiearchy and
will flatten it so all those leaf nodes (container1, container2,
machine1, machine2...etc) are immediately at the root level. While
this is clearly sub-optimal, for our current needs that does not
actually harm us really. While we did intend that a sysadmin could
place controls on the 'libvirt', 'lxc' or 'qemu' cgroups, I'm not
aware of anyone who actually does this currently. Everyone, so far,
only cares about placing controls in individual virtual machines
and containers.

Thus given what we now know about the performance problems wrt
hierarchies we're planning to flatten that significantly to look
closer to this:

 $CG_MOUNT_ROOT
  |
  +- apache.service
  +- mysql.service
  +- sendmail.service
  +- ....service
  +- libvirtd.service (if systemd has put us in an isolated group)
      |
      +- libvirt-lxc-container1
      +- libvirt-lxc-container2
      +- libvirt-lxc-container3
      +- libvirt-lxc-...
      +- libvirt-qemu-machine1
      +- libvirt-qemu-machine2
      +- libvirt-qemu-machine3
      +- libvirt-qemu-...

(though we'll have config option to retain the old style hiearchy
too for backwards compatibility)

Also bear in mind that with containers, the processes inside
the containers may want to use cgroups too. eg if runnning
systemd inside a container too

 $CG_MOUNT_ROOT
  |
  +- apache.service
  +- mysql.service
  +- sendmail.service
  +- ....service
  +- libvirtd.service (if systemd has put us in an isolated group)
      |
      +- libvirt-lxc-container1
      |   |
      |   +- apache.service
      |   +- mysql.service
      |   +- sendmail.service
      |   ...
      +- libvirt-lxc-container2
      +- libvirt-lxc-container3
      +- libvirt-lxc-...
      +- libvirt-qemu-machine1
      +- libvirt-qemu-machine2
      +- libvirt-qemu-machine3
      +- libvirt-qemu-...

Or if each user login session has been given a cgroup and we are
running libvirtd as a non-root user, we can end up with something
like this:

 $CG_MOUNT_ROOT
  |
  +- fred.user
  +- joe.user
  +- bob.user
      |
      +- libvirtd.service (if systemd has put us in an isolated group)
          |
          +- libvirt-qemu-machine1
          +- libvirt-qemu-machine2
          +- libvirt-qemu-machine3
          +- libvirt-qemu-...

In essence what I'm saying is that I'm fine with co-mounting. What
we care about is being able to create the kind of hiearchies outlined
above, and have all controllers actually work sensibly with them.

The systemd & libvirt folks came up with the following recommendations
to try to get good co-operation between different user space apps who
want to use cgroups. Basically the idea is that if each app follows the
guidelines, then no individual app should need to have a global world
of all cgroups.

  http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups

I think everything you describe is compatible with what we've documented
there.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
