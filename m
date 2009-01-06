From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 15:35:23 -0800
Message-ID: <1231284923.14345.158.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <20090106202046.GF5901@fieldses.org>  <20090106215324.GD18147@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090106215324.GD18147-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-01-06 at 15:53 -0600, Serge E. Hallyn wrote:
> Quoting J. Bruce Fields (bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org):
> > On Tue, Jan 06, 2009 at 02:02:29PM -0600, Serge E. Hallyn wrote:
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
> > This is just the machine name in the auth_unix credential?  The linux
> > server ignores that completely (for the purpose of auth_unix
> > authenication, it identifies clients only by source ip address).  I
> > suspect other servers also ignore it, but I don't know.
> 
> Thanks, that's what i was hoping...
> 
> Matt, have you audited the other rpc-based services?  Do any
> of them care?

Frankly, I did not audit any of the RPC-based services to see if any
truly cared about the node name. That's actually a rather large scope
when you consider it -- I'd have to look at much more than just "Linux"
RPC clients. It seemed unsafe to assume _nobody_ would care after they
bothered to put it into the spec.

Hopefully I'm wrong though :).

Cheers,
	-Matt

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
