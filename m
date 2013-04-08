From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Mon, 8 Apr 2013 15:11:05 -0400
Message-ID: <20130408191105.GG28292@redhat.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130408175925.GE28292@redhat.com>
	<20130408181607.GI3021@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130408181607.GI3021-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On Mon, Apr 08, 2013 at 11:16:07AM -0700, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Mon, Apr 08, 2013 at 01:59:26PM -0400, Vivek Goyal wrote:
> > But using the library admin application should be able to query the
> > full "paritition" hierarchy and their weigths and calculate % system
> > resources. I think one problem there is cpu controller where % resoruce
> > of a cgroup depends on tasks entities which are peer to group. But that's
> > a kernel issue and not user space thing.
> 
> Yeah, we're gonna have to implement a different operation mode.
> 
> > So I am not sure what are potential problems with proposed model of
> > configuration in workman. All the consumer managers still follow what
> > libarary has told them to do.
> 
> Sure, if we assume everyone follows the rules and behaves nicely.
> It's more about the general approach.  Allowing / encouraging sharing
> or distributing control of cgroup hierarchy without forcing structure
> and rigid control over it is likely to lead to confusion and
> fragility.
> 
> > >  or maybe some other program just happened to choose the
> > >   same name.
> > 
> > Two programs ideally would have their own sub hiearchy. And if not one
> > of the programs should get the conflict when trying to create cgroup and
> > should back-off or fail or give warning...
> 
> And who's responsible for deleting it?

I think "consumer" manager should delete its own cgroup directories when
associated consumer[s] stop running.

And partitions created by workman will just remain there until and unless
user wanted to delete these explicitly.

>  What if the program crashes?

I am not sure about this. I guess when applications comes back after crash,
it can go through all the children cgroups and reclaim empty cgroups.

> 
> > > Who owns config knobs in that directory?
> > 
> > IIUC, workman was looking at two types of cgroups. Once called
> > "partitions" which will be created by library at startup time and
> > library manages the configuration (something like cgconfig.conf).
> > 
> > And individual managers create their own children groups for various
> > services under that partition and control the config knobs for those
> > services.
> > 
> > 			user-defined-partition
> > 			     /    |    \
> >                            virt1  virt2 virt3  
> > 
> > So user should be able to define a partition and control the configuration
> > using workman lib. And if multiple virtual machines are being run in
> > the partition, then they create their own cgroups and libvirt controls
> > the properties of virt1, virt2, virt3 cgroups. I thought that was the
> > the understanding when we dicussed ownership of config knobs las time.
> > But things might have changed since last time. Workman folks should
> > be able to shed light on this.
> 
> I just read the introduction doc and haven't delved into the API or
> code so I could be off but why should there be multiple managers?
> What's the benefit of that?

A centralized authority does not know about all the managed objects.
Only respective manager knows about what objects it is managing and
what are the controllable attributes of that object.

systemd is managing services and libvirt is managing virtual machines,
containers etc. Some people view associated resource group as just one
additional attribute of the managed service. These managers already
maintain multiple attributes of a service and can store one additional
attribute easily.

>  Wouldn't it make more sense to just have
> a central arbitrator that everyone talks to?

May be. Just that in the past folks have not liked the idea of talking
to central authority to figure out resource group of an object they are
managing.

>  What's the benefit of
> distributing the responsiblities here?  It's not like we can put them
> in different security domains.

To me it makes sense in a way, as these resources associated with the
service is just one another property and there does not seem to be
anything special about this property that it should be managed using
a single centralized authority.

For example, one might want to say that maximum IO bandwidth for 
virtual machine virt1 on disk sda should be 10MB/s. Now libvirt
should be able to save it in virtual machine specific configuration
easily and whenever virtual machine is started, create a children
cgroup, set the limits as specified.

If a central authority keeps track of all this, I am not sure how 
would it look like and might get messy.

[..]
> > > I think the only logical thing to do is creating a centralized
> > > userland authority which takes full ownership of the cgroup filesystem
> > > interface, gives it a sane structure,
> > 
> > Right now systemd seems to be giving initial structure. I guess we will
> > require some changes where systemd itself runs in a cgroup and that
> > allows one to create peer groups. Something like.
> > 				
> > 				root
> > 				/  \
> > 			   systemd other-groups
> 
> No, we need a single structured hierarchy which everyone uses
> *including* systemd.

That would make sense. systemd had this conflict with cgconfig
too. Problem is that systemd starts first and sets up everything. Now
if there is a service which sets up cgroups, after systemd startup,
it is already late.

Thanks
Vivek
