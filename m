From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 18:37:14 -0800
Message-ID: <m1r63fzvs5.fsf@frodo.ebiederm.org>
References: <20090106200229.GA17031@us.ibm.com>
	<1231274682.20316.65.camel@heimdal.trondhjem.org>
	<20090106215831.GE18147@us.ibm.com>
	<m1eizg11fy.fsf@frodo.ebiederm.org>
	<1231283734.8041.6.camel@heimdal.trondhjem.org>
	<20090106233238.GD13785@fieldses.org>
	<1231284943.8041.8.camel@heimdal.trondhjem.org>
	<1231287607.11487.0.camel@heimdal.trondhjem.org>
	<20090107002608.GK13785@fieldses.org>
	<1231288706.11487.15.camel@heimdal.trondhjem.org>
	<20090107014422.GA17913@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090107014422.GA17913-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Tue, 6 Jan 2009 20:44:22 -0500")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:

> If people seem to think they can do live process and container
> migration:
>
> 	http://ols.fedoraproject.org/OLS/Reprints-2008/mirkin-reprint.pdf
>
> then moving the NFS state strikes me as not the greatest of their
> troubles.
>
> I'm not volunteering!

Reasonable.  There are a lot easier cases than NFS, and migration is
not the biggest use case.

A lot of this work we can do incrementally and simply not support
doing everything in a container.  Which is where we are today.

The whole hostname in NFS packets isn't something that makes much sense
to me in the first place, so I can't comment on a good use case for that.

Sorting out the details so we can get NFS working in multiple network namespaces
makes a lot of sense to me.   It allows things like VPNing into work isolating the
VPN process in a network namespace, and still being able to use all of the kernel
networking including NFS like normal sounds fun to me.

There may also be some fun things you can do with testing having both an NFS
server and the client on the same box and not go through the loopback device.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
