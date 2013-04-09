From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 9 Apr 2013 10:50:25 +0100
Message-ID: <20130409095024.GI25576@redhat.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130406012159.GA17159-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 05, 2013 at 06:21:59PM -0700, Tejun Heo wrote:
>  Userland efforts
>  ================
> 
> There are currently a few userland efforts trying to make interfacing
> with cgroup less painful.
> 
> * libcg: Make cgroup interface accessible from programming languages
>   with support for configuration persistency, which also brings its
>   own config files to remember what to do on the next boot.  Sans the
>   persistence part, it just seems to directly translate the filesystem
>   interface to function interface.
> 
>   http://libcg.sourceforge.net/
> 
> * Workman: It's a rather young project but as its name (workload
>   management) implies, its aims are higher level than that of libcg.
>   It aims to provide high-level resource allocation and management and
>   introduces new concepts like resource partitions to represent its
>   view of resource hierarchy.  Like libcg, this one is implemented as
>   a library but provides bindings for more languages.
> 
>   https://gitorious.org/workman/pages/Home
> 
> * Pax Controla Groupiana: A document on how not to step on other's
>   toes while using cgroup.  It's not a software project but tries to
>   define precautions that a software or user can take to avoid
>   breaking or confusing other users of the cgroup filesystem.
> 
>   http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
> 
> All try to play nice with other possible users of the cgroup
> filesystem - be it libvirt cgroup, applications doing their own cgroup
> tricks, or hand-crafted custom scripts.  While the approach is
> understandable given that those usages already exist, I don't think
> it's a workable solution in the long term.  There are several reasons
> for that.

Actually libcg doesn't really try to play nice with anything - being
just a direct representation of the cgroups filesystem, it allows for
absolutely anything to be done with no regard for best practice or
co-operation.

The PaxControlGroups document is the key piece to making distributed
management work. This document does need updating, since some of what
it describes doesn't really work, but its goal is sound IMHO.

The Workman library is presuming that apps will follow the PaxControlGroups
guidelines for use of cgroups, and from there aims to provide system
administrators with a "single world view" and tools to then configure
this. It does not, however, attempt to force itself underneath the
apps like systemd / libvirt, since there is no need todo that. It
just aggregates information from system/libvirt/etc so that admin has
the complete picture of what the cgroups are being used for.

> * The configurations aren't independent.  e.g. for weight-based
>   controllers, your weight is only meaningful in relation to other
>   weights at that level.  Distributing configuration to whatever
>   entities which may write to cgroupfs simply cannot work.  It's
>   fundamentally flawed.

I agree that whatever is setting weight values needs to be aware of
what other weight values are set at the same point in the hiearchy.
This doesn't imply we have to have a single authority setting these
values though, just that anything that wants to set them, needs to
be aware of the bigger picture.

> * It's fragile like hell.  There's no accountability.  Nobody really
>   knows what's going on.  Is this subdirectory still there due to a
>   bug in this program, or something or someone else created it and
>   crashed / forgot to remove it, or what?  Oh, the cgroup I wanted to
>   create already exists.  Maybe the previous instance created it and
>   then crashed or maybe some other program just happened to choose the
>   same name.  Who owns config knobs in that directory?  This way lies
>   madness.  I understand why the Pax doc exists but I'm not sure its
>   long-term effect would be positive - best practices which ultimately
>   lead to utter confusion and fragility.

I don't see that creating a "single authority" magically solves any
of the problems you describe. For example, such an authority can't
know whether it should delete a cgroup just because an application
exits. It is quite possible an application would want the cgroup to
continue to exist, so that it is still there when it restarts.

> * In many cases, resource distribution is system-wide policy decisions
>   and determining what to do often requires system-wide knowledge.
>   You can't provision memory limits without knowing what's available
>   in the system and what else is going on in the system, and you want
>   to be able to adjust them as situation and configuration changes.
>   Without anybody having full picture of how resources are
>   provisioned, how would any of that be possible?

Ultimately it is the end admin or top level management tool that has
the whole picture. The Workman library / cli is aiming to provide
admins / apps with the complete picture of everything that is using
resources on the system, so they can adjust policies dynamically.

> I think this anything-goes approach is prevalent largely because the
> cgroup filesystem interface encourages such usage.  From the looks of
> it, the filesystem permissions combined with hierarchy should be able
> to handle delegation perfectly.  Well, as it currently stands, it's
> anything but and the interface is just misleading.  Hierarchy support
> was an utter mess, configuration schemes aren't uniform across
> controllers, and, more fundamentally, hierarchy itself is expensive -
> we can't delegate hierarchy creation to unpriviledged users or
> programs safely.

You seem to be implying that 'distributed == anything goes', which is
certainly not what I consider to be the case. Indeed the main point
of having the PaxControlGroups guidelines is explicitly because we do
*not* want an "anything goes" approach.

We ultimately do need the ability to delegate hierarchy creation to
unprivileged users / programs, in order to allow containerized OS to
have the ability to use cgroups. Requiring any applications inside a
container to talk to a cgroups "authority" existing on the host OS is
not a satisfactory architecture. We need to allow for a container to
be self-contained in its usage of cgroups.

At the same time, we don't need/want to give them unrestricted ability
to create arbitarily complex hiearchies - we need some limits on it
to avoid them exposing pathelogically bad kernel behaviour.

This could be as simple as saying that each cgroup controller directory
has a tunable "cgroups.max_children" and/or "cgroups.max_depth" which
allow limits to be placed when delegating administration of part of a
cgroups tree to an unprivileged user.

> I think the only logical thing to do is creating a centralized
> userland authority which takes full ownership of the cgroup filesystem
> interface, gives it a sane structure, represents available resources
> in a sane form, and makes policy decisions based on configuration and
> requests.  I don't have a concerete idea what that authority should be
> like, but I think there already are pretty similar facilities in our
> userland, and don't see why this should be much different.

I don't think that requiring a single userspace authority is
satisfactory. We need to be able to delegate this to containers,
without them needing to talk to some authority back in the
host OS, so that they remain 100% isolated from processes in
the host OS.

> Another reason why this could be helpful is that we're gonna be
> morphing towards unified hierarchy and it'd very nice to have
> something which can match impedance between the old and new ways and
> not require each individual consumer of cgroup to handle such changes.
> As for the unified hierarchy, we just have to.  It's currently
> fundamentally broken in that it's impossible to tell which cgroup a
> resource belongs to independent of which task is looking at it.  It's
> like this damn thing is designed to honor Hisenberg and Einstein.  No
> disrespect for the great minds, but it just doens't look like the
> proper place.

I've no disagreement that we need a unified hiearchy. The workman
app explicitly does /not/ expose the concept of differing hiearchies
per controller. Likewise libvirt will not allow the user to configure
non-unified hiearchies. 

> So, umm, that's what I want.  When I first heard of WorkMan, I was
> excited thinking maybe the universe is being really nice and making
> things happen to my wishes without me actually doing anything. :) Oh
> well, one can dream, but everything is still early, so hopefully we
> have enough time to figure things out.
> 
> What do you guys think?

We need to make the distribute approach work in order to support
containers, which requiring them to have a back-channel open to
the host userspace. If we can do that, then we've solved the problem
of delegated to unprivileged users in non-container environments too.
IMHO with a sufficiently specified PaxControlGroups the distributed
approach is just fine. If applications are badly behaved and don't
follow the rules, then so be it, file bugs against those apps. Both
libvirt & systemd are committed to following rules for co-operating
in usage of cgroups & Workman can provide a "single unified view"
for the administrator without requiring a single authority too.

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
