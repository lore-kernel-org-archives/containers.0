From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 16:55:16 -0800
Message-ID: <m1zli4ylxn.fsf@frodo.ebiederm.org>
References: <20090106011314.534653345@us.ibm.com>
	<20090106011314.961946803@us.ibm.com>
	<20090106200229.GA17031@us.ibm.com>
	<1231274682.20316.65.camel@heimdal.trondhjem.org>
	<20090106215831.GE18147@us.ibm.com>
	<m1eizg11fy.fsf@frodo.ebiederm.org>
	<1231283734.8041.6.camel@heimdal.trondhjem.org>
	<20090106233238.GD13785@fieldses.org>
	<1231284943.8041.8.camel@heimdal.trondhjem.org>
	<20090106235322.GE13785@fieldses.org>
	<1231286879.14345.194.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1231286879.14345.194.camel@localhost> (Matt Helsley's message of
	"Tue, 06 Jan 2009 16:07:59 -0800")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, 2009-01-06 at 18:53 -0500, J. Bruce Fields wrote:
>> On Tue, Jan 06, 2009 at 06:35:43PM -0500, Trond Myklebust wrote:
>> > On Tue, 2009-01-06 at 18:32 -0500, J. Bruce Fields wrote:
>> > > On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
>> > > > On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
>> > > > > That implies to me you want to capture the value at mount time, and to
>> > > > > pass it in to the rpc_call creation, and only at very specific well
>> > > > > defined points where we interact with user space should we examine
>> > > > > current->utsname().  At which point there should be no question
>> > > > > of current->utsname() is valid as the user space process is alive.
>> > > > 
>> > > > Why pretend that the filesystem is owned by a particular namespace? It
>> > > > can, and will be shared among many containers...

Sounds right.  Still like the owner of a file it can happen that some
containers are more correct than others.  Especially in the context of
mount merging and the other sophisticated caching that happens in NFS
this increasingly sounds like something that belongs in the cred as
that is where it is used.

>> > > If the only purpose of this is to fill in the auth_unix cred then
>> > > shouldn't it be part of whatever cred structures are passed around?
>> > 
>> > So how does tracking it in a shared structure like the rpc_client help?
>> > If you consider it to be part of the cred, then it needs to be tracked
>> > in the cred...
>> 
>> Right, that's what I meant.
>> 
>> It seems like overkill, though.  Does anyone actually care whether these
>> names are right?
>
> That's certainly a tempting angle. However we may not "control" the
> server code -- couldn't there be some oddball (maybe even proprietary)
> NFS servers out there that users do care about interacting with?

Matt could you look at what it will take to do the right thing from
the network namespace side of things as well?  I believe it is going
to require the same level of understanding of the interactions in the code
to get there.

For the network namespace we should cache it at mount or server
startup and use it until we are done.  In a network namespace context
there are good reasons for that because talking to 10.0.0.1 on one
network may not be the same machine as talking to 10.0.0.1 on another
network.  NFS reestablishes tcp connections if the connection to the
server breaks doesn't it?  Or is that left to user space?

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
