From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 15:04:17 -0800
Message-ID: <m1eizg11fy.fsf@frodo.ebiederm.org>
References: <20090106011314.534653345@us.ibm.com>
	<20090106011314.961946803@us.ibm.com>
	<20090106200229.GA17031@us.ibm.com>
	<1231274682.20316.65.camel@heimdal.trondhjem.org>
	<20090106215831.GE18147@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090106215831.GE18147-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue, 6 Jan 2009 15:58:31 -0600")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Trond Myklebust (trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org):
>> On Tue, 2009-01-06 at 14:02 -0600, Serge E. Hallyn wrote:
>> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> > > We can often specify the UTS namespace to use when starting an RPC client.
>> > > However sometimes no UTS namespace is available (specifically during
> system
>> > > shutdown as the last NFS mount in a container is unmounted) so fall
>> > > back to the initial UTS namespace.
>> > 
>> > So what happens if we take this patch and do nothing else?
>> > 
>> > The only potential problem situation will be rpc requests
>> > made on behalf of a container in which the last task has
>> > exited, right?  So let's say a container did an nfs mount
>> > and then exits, causing an nfs umount request.
>> > 
>> > That umount request will now be sent with the wrong nodename.
>> > Does that actually cause problems, will the server use the
>> > nodename to try and determine the client sending the request?
>> 
>> The NFSv2/v3 umount rpc call will be sent by the 'umount' program from
>> userspace, not the kernel. The problem here is that because lazy mounts
>> exist, the lifetime of the RPC client may be longer than that of the
>
> Right that was what i was referring to.
>
>> container. In addition, it may be shared among more than 1 container,
>> because superblocks can be shared.
>
> Good point.  And in that case what do we care about (even though
> apparently we just might not care at all :) - who did the mount,
> or who is using it?
>
> In fact one thing I noticed in Matt's patch 3 was that he copied
> in the nodename verbatim, so a future hostname() by the container
> wouldn't be reflected, again not sure if that would matter.
>
>> One thing you need to be aware of here is that inode dirty data
>> writebacks may be initiated by completely different processes than the
>> one that dirtied the inode.
>
> Right, but I *was* thinking that we wanted to associate the nodename
> on the rpc calls with the hostname of the mounter, not the actor.  Maybe
> you'll tell me above that that is bogus.
>
>> IOW: Aside from being extremely ugly, approaches like [PATCH 4/4] which
>> rely on being able to determine the container-specific node name at RPC
>> generation time are therefore going to return incorrect values.
>
> So should we use patch 2/4, plus (as someone - was it you? - suggested)
> using a DEFAULT instead of init_utsname()->nodename when
> current->utsname() == NULL?

Is there any reason to believe that the kernel helper threads will ever
have a useful namespace value?  I don't think so.

That implies to me you want to capture the value at mount time, and to
pass it in to the rpc_call creation, and only at very specific well
defined points where we interact with user space should we examine
current->utsname().  At which point there should be no question
of current->utsname() is valid as the user space process is alive.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
