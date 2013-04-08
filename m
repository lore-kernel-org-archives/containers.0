From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Mon, 8 Apr 2013 12:20:24 -0700
Message-ID: <20130408192024.GL3021@htj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130408175925.GE28292@redhat.com>
	<20130408181607.GI3021@htj.dyndns.org>
	<20130408191105.GG28292@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130408191105.GG28292-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hey,

On Mon, Apr 08, 2013 at 03:11:05PM -0400, Vivek Goyal wrote:
> >  What if the program crashes?
> 
> I am not sure about this. I guess when applications comes back after crash,
> it can go through all the children cgroups and reclaim empty cgroups.

Fragile, right?  What are you arguing here?

> >  Wouldn't it make more sense to just have
> > a central arbitrator that everyone talks to?
> 
> May be. Just that in the past folks have not liked the idea of talking
> to central authority to figure out resource group of an object they are
> managing.

What we've been doing seems tragically broken to me, so I'm not sure
"people didn't use to do it that way" is a good point.

> >  What's the benefit of
> > distributing the responsiblities here?  It's not like we can put them
> > in different security domains.
> 
> To me it makes sense in a way, as these resources associated with the
> service is just one another property and there does not seem to be
> anything special about this property that it should be managed using
> a single centralized authority.
> 
> For example, one might want to say that maximum IO bandwidth for 
> virtual machine virt1 on disk sda should be 10MB/s. Now libvirt
> should be able to save it in virtual machine specific configuration
> easily and whenever virtual machine is started, create a children
> cgroup, set the limits as specified.

Yes, sure, libvirt can *request* whatever it seems appropriate to the
central authority, which will decide whether it'll be able to honor
the request and grant it if possible and allowed by policies in
effect.

> That would make sense. systemd had this conflict with cgconfig
> too. Problem is that systemd starts first and sets up everything. Now
> if there is a service which sets up cgroups, after systemd startup,
> it is already late.

Come on, that's not a difficult or fundamental problem.  Whatever the
central authority may be, systemd can use it to setup the initial
hierarchy or set up bare-bone hierarchy in compatible manner.  This
isn't that different from udev.

Thanks.

-- 
tejun
