From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Mon, 8 Apr 2013 11:16:07 -0700
Message-ID: <20130408181607.GI3021@htj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130408175925.GE28292@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130408175925.GE28292-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Vivek.

On Mon, Apr 08, 2013 at 01:59:26PM -0400, Vivek Goyal wrote:
> But using the library admin application should be able to query the
> full "paritition" hierarchy and their weigths and calculate % system
> resources. I think one problem there is cpu controller where % resoruce
> of a cgroup depends on tasks entities which are peer to group. But that's
> a kernel issue and not user space thing.

Yeah, we're gonna have to implement a different operation mode.

> So I am not sure what are potential problems with proposed model of
> configuration in workman. All the consumer managers still follow what
> libarary has told them to do.

Sure, if we assume everyone follows the rules and behaves nicely.
It's more about the general approach.  Allowing / encouraging sharing
or distributing control of cgroup hierarchy without forcing structure
and rigid control over it is likely to lead to confusion and
fragility.

> >  or maybe some other program just happened to choose the
> >   same name.
> 
> Two programs ideally would have their own sub hiearchy. And if not one
> of the programs should get the conflict when trying to create cgroup and
> should back-off or fail or give warning...

And who's responsible for deleting it?  What if the program crashes?

> > Who owns config knobs in that directory?
> 
> IIUC, workman was looking at two types of cgroups. Once called
> "partitions" which will be created by library at startup time and
> library manages the configuration (something like cgconfig.conf).
> 
> And individual managers create their own children groups for various
> services under that partition and control the config knobs for those
> services.
> 
> 			user-defined-partition
> 			     /    |    \
>                            virt1  virt2 virt3  
> 
> So user should be able to define a partition and control the configuration
> using workman lib. And if multiple virtual machines are being run in
> the partition, then they create their own cgroups and libvirt controls
> the properties of virt1, virt2, virt3 cgroups. I thought that was the
> the understanding when we dicussed ownership of config knobs las time.
> But things might have changed since last time. Workman folks should
> be able to shed light on this.

I just read the introduction doc and haven't delved into the API or
code so I could be off but why should there be multiple managers?
What's the benefit of that?  Wouldn't it make more sense to just have
a central arbitrator that everyone talks to?  What's the benefit of
distributing the responsiblities here?  It's not like we can put them
in different security domains.

> > * In many cases, resource distribution is system-wide policy decisions
> >   and determining what to do often requires system-wide knowledge.
> >   You can't provision memory limits without knowing what's available
> >   in the system and what else is going on in the system, and you want
> >   to be able to adjust them as situation and configuration changes.
> >   Without anybody having full picture of how resources are
> >   provisioned, how would any of that be possible?
> 
> I thought workman library will provide interfaces so that one can query
> and be able to construct the full system view.
> 
> Their doc says.
> 
> GList *workmanager_partition_get_children(WorkmanPartition *partition,
>                                             GError **error);
> 
> So I am assuming this can be used to construct the full partition
> hierarchy and associated resource allocation.

Sure, maybe it can be used as a building block.

> [..]
> > I think the only logical thing to do is creating a centralized
> > userland authority which takes full ownership of the cgroup filesystem
> > interface, gives it a sane structure,
> 
> Right now systemd seems to be giving initial structure. I guess we will
> require some changes where systemd itself runs in a cgroup and that
> allows one to create peer groups. Something like.
> 				
> 				root
> 				/  \
> 			   systemd other-groups

No, we need a single structured hierarchy which everyone uses
*including* systemd.

> > represents available resources
> > in a sane form, and makes policy decisions based on configuration and
> > requests.
> 
> Given the fact that library has view of full system resoruces (both
> persistent view and active view), shouldn't we just be able to extend
> the API to meet additional configuration or resource needs.

Maybe, I don't know.  It just looks like a weird approach to me.
Wouldn't it make more sense to implement it as a dbus service that
everyone talks to?  That's how our base system is structured these
days.  Why should this be any different?

Thanks.

-- 
tejun
