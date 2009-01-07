From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 19:20:24 -0500
Message-ID: <20090107002024.GJ13785@fieldses.org>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org> <20090106215831.GE18147@us.ibm.com> <1231281732.4173.6.camel@heimdal.trondhjem.org> <1231286930.14345.196.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1231286930.14345.196.camel@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 06, 2009 at 04:08:50PM -0800, Matt Helsley wrote:
> On Tue, 2009-01-06 at 17:42 -0500, Trond Myklebust wrote:
> > On Tue, 2009-01-06 at 15:58 -0600, Serge E. Hallyn wrote:
> > 
> > > So should we use patch 2/4, plus (as someone - was it you? - suggested)
> > > using a DEFAULT instead of init_utsname()->nodename when
> > > current->utsname() == NULL?
> > 
> > No. I'm don't think that 2/4 is correct either. Basically, 2/4 is saying
> > that the container that first mounts the filesystem 'owns' it. However
> > at the same time we know that the lifetime of the filesystem is in no
> > way bounded by the lifetime of the container, and that's what gets you
> > into trouble with 'umount' in the first place.
> >
> > IMO, the current code is the most correct approach, in that it assumes
> > that the filesystems are owned by the 'init' namespace.
> 
> IMHO This seems more incorrect than trying to use a more proximal
> namespace.

If it would be possible, for example, for the 'init' namespace to have
no network interfaces at all, then it would be nicer to use a name
that's at least been used with nfs at *some* point--just on the general
principle of not leaking information to a domain that the user wouldn't
expect it to.

(Assuming it's unlikely anyone would consider init's utsname to be
sensitive information, that's a minor point.)

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
