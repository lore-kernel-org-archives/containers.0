From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Mon, 8 Apr 2013 13:59:26 -0400
Message-ID: <20130408175925.GE28292@redhat.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 05, 2013 at 06:21:59PM -0700, Tejun Heo wrote:

[..]
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
> 
> * The configurations aren't independent.  e.g. for weight-based
>   controllers, your weight is only meaningful in relation to other
>   weights at that level.  Distributing configuration to whatever
>   entities which may write to cgroupfs simply cannot work.  It's
>   fundamentally flawed.

Hi Tejun,

I thought in workman, "partition" configuration was still centralized
while individual "consumer" configuration was with consumer manger 
(systemd, libvirt, .. etc). IOW, library can tell consumer manger to
which partition to associate consumer with at startup time. (consumer
manager can assume their own defaults if nothing has been told).

Agreed, that weight is meaningful only if one as full hierarchy view
and then one should be able to calculate effective % share of resoures
of a group.

But using the library admin application should be able to query the
full "paritition" hierarchy and their weigths and calculate % system
resources. I think one problem there is cpu controller where % resoruce
of a cgroup depends on tasks entities which are peer to group. But that's
a kernel issue and not user space thing.

So I am not sure what are potential problems with proposed model of
configuration in workman. All the consumer managers still follow what
libarary has told them to do.

> 
> * It's fragile like hell.  There's no accountability.  Nobody really
>   knows what's going on.  Is this subdirectory still there due to a
>   bug in this program, or something or someone else created it and
>   crashed / forgot to remove it, or what?

I thought any directory under a consumer manger is managed by that
manager and nobody is supposed to dynamically create resource
partition/cgroup there. So that takes away a bit of confusion.

>  Oh, the cgroup I wanted to
>   create already exists.  Maybe the previous instance created it and
>   then crashed

This should be the case as long as we stick to the notion of a manger
managing its own sub-hierarchy.

>  or maybe some other program just happened to choose the
>   same name.

Two programs ideally would have their own sub hiearchy. And if not one
of the programs should get the conflict when trying to create cgroup and
should back-off or fail or give warning...

> Who owns config knobs in that directory?

IIUC, workman was looking at two types of cgroups. Once called
"partitions" which will be created by library at startup time and
library manages the configuration (something like cgconfig.conf).

And individual managers create their own children groups for various
services under that partition and control the config knobs for those
services.

			user-defined-partition
			     /    |    \
                           virt1  virt2 virt3  

So user should be able to define a partition and control the configuration
using workman lib. And if multiple virtual machines are being run in
the partition, then they create their own cgroups and libvirt controls
the properties of virt1, virt2, virt3 cgroups. I thought that was the
the understanding when we dicussed ownership of config knobs las time.
But things might have changed since last time. Workman folks should
be able to shed light on this.

>  This way lies
>   madness.  I understand why the Pax doc exists but I'm not sure its
>   long-term effect would be positive - best practices which ultimately
>   lead to utter confusion and fragility.
> 
> * In many cases, resource distribution is system-wide policy decisions
>   and determining what to do often requires system-wide knowledge.
>   You can't provision memory limits without knowing what's available
>   in the system and what else is going on in the system, and you want
>   to be able to adjust them as situation and configuration changes.
>   Without anybody having full picture of how resources are
>   provisioned, how would any of that be possible?

I thought workman library will provide interfaces so that one can query
and be able to construct the full system view.

Their doc says.

GList *workmanager_partition_get_children(WorkmanPartition *partition,
                                            GError **error);


So I am assuming this can be used to construct the full partition
hierarchy and associated resource allocation.

> 
> I think this anything-goes approach is prevalent largely because the
> cgroup filesystem interface encourages such usage.  From the looks of
> it, the filesystem permissions combined with hierarchy should be able
> to handle delegation perfectly.  Well, as it currently stands, it's
> anything but and the interface is just misleading.  Hierarchy support
> was an utter mess, configuration schemes aren't uniform across
> controllers, and, more fundamentally, hierarchy itself is expensive -
> we can't delegate hierarchy creation to unpriviledged users or
> programs safely.
> 
> It is in the realm of possibility to make all cgroup operations and
> controllers to do all that; however, it's a very tall order.  Just
> think about how much effort it has been to achieve and maintain proper
> delegation in the core elements of the kernel - processes and
> filesystems, and there will be security implications with cgroup
> likely involving a lot of gotchas and extensions of security
> infrastructures, and, even then, I'm pretty sure it's gonna require
> helps from userland to effect proper policy decisions and config
> changes.  We have things like polkit for a reason and are likely to
> need finer-grained, domain-aware access control than is possible with
> tweaking directory permissions.
> 
> Given the above and how relatively marginal cgroup is, I'm extremely
> skeptical that implementing full delegation in kernel is the right
> course of action and likely to scream like a banshee at any attempt
> driving things that way.
> 

[..]
> I think the only logical thing to do is creating a centralized
> userland authority which takes full ownership of the cgroup filesystem
> interface, gives it a sane structure,

Right now systemd seems to be giving initial structure. I guess we will
require some changes where systemd itself runs in a cgroup and that
allows one to create peer groups. Something like.
				
				root
				/  \
			   systemd other-groups
	
So currently no central authority is enforcing it. It seems to be just
a matter of right defaults in systemd.
	
> represents available resources
> in a sane form, and makes policy decisions based on configuration and
> requests.

Given the fact that library has view of full system resoruces (both
persistent view and active view), shouldn't we just be able to extend
the API to meet additional configuration or resource needs.

>  I don't have a concerete idea what that authority should be
> like, but I think there already are pretty similar facilities in our
> userland, and don't see why this should be much different.


Thanks
Vivek
