From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 15:30:33 -0800
Message-ID: <1231284633.14345.152.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090106215831.GE18147-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-01-06 at 15:58 -0600, Serge E. Hallyn wrote:
> Quoting Trond Myklebust (trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org):
> > On Tue, 2009-01-06 at 14:02 -0600, Serge E. Hallyn wrote:
> > > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > > We can often specify the UTS namespace to use when starting an RPC client.
> > > > However sometimes no UTS namespace is available (specifically during system
> > > > shutdown as the last NFS mount in a container is unmounted) so fall
> > > > back to the initial UTS namespace.
> > > 
> > > So what happens if we take this patch and do nothing else?
> > > 
> > > The only potential problem situation will be rpc requests
> > > made on behalf of a container in which the last task has
> > > exited, right?  So let's say a container did an nfs mount
> > > and then exits, causing an nfs umount request.
> > > 
> > > That umount request will now be sent with the wrong nodename.
> > > Does that actually cause problems, will the server use the
> > > nodename to try and determine the client sending the request?
> > 
> > The NFSv2/v3 umount rpc call will be sent by the 'umount' program from
> > userspace, not the kernel. The problem here is that because lazy mounts
> > exist, the lifetime of the RPC client may be longer than that of the
> 
> Right that was what i was referring to.
> 
> > container. In addition, it may be shared among more than 1 container,
> > because superblocks can be shared.
> 
> Good point.  And in that case what do we care about (even though
> apparently we just might not care at all :) - who did the mount,
> or who is using it?
> 
> In fact one thing I noticed in Matt's patch 3 was that he copied
> in the nodename verbatim, so a future hostname() by the container
> wouldn't be reflected, again not sure if that would matter.

I thought of this. I found the patches that added the nodename in the
RPC client struct and the stale nodename was intentional. That's why I
preserved the copy rather than called utsname() each time.

Cheers,
	-Matt

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
