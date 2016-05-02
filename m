From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Sun, 1 May 2016 23:13:28 -0500
Message-ID: <20160502041328.GB31837@mail.hallyn.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<1461968310.16292.20.camel@HansenPartnership.com>
	<1462120674.1411.2.camel@Nokia-N900>
	<1462145366.2337.18.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1462145366.2337.18.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, May 01, 2016 at 04:29:26PM -0700, James Bottomley wrote:
> On Sun, 2016-05-01 at 12:37 -0400, Serge Hallyn wrote:
> > > > It looks like the only addition it needs is the setgroups flag
> > > > for
> > > > newgidmap, which the security people will need, so I can patch
> > > > that. 
> > > 
> > > How does this look for a patch?
> > 
> > Certainly deny is a terrible keyword for this, given the somewhat
> > convoluted case it represents.  Maybe lockgroups or nosetgroup?
> 
> OK, nosegroups seems to be less scary.
> 
> >   And of course it'll need a clear explanation of what it does in the
> > subgid manpage. But really i don't know that this can work the way
> > you want it to.
> 
> Yes, docs and tests were to be added after everyone was happy with the
> implementation.
> 
> >   Can you describe your use case?
> 
> basically not getting a CVE filed against this utility for allowing the
> dropping of groups.  I don't have a use case for group membership
> denying permissions.
> 
> > The intent of setgroups is to keep *unprivileged* writers of gid_map
> > from dropping a gid which is blocking a file access from the user. 
> 
> 
> You can't do that with the map write.  Even if you set no gid_map at
> all, the attributes checks are done on the kernel side groups (i.e. the
> ones you possess outside the namespace even if they have no interior
> mapping).  The only way to drop groups is with the setgroups() system
> call.
> 
> >  But newgidmap runs suid root (or cap_gid when you are through :), so
> > the user can trivially assign just one authorized gid, not the whole
> > range, and bypass the acls that way.
> 
> It does more than that: it also blocks the sys_setgroups() call in the
> namespace, even for the namespace owner, which is the primary CVE
> preventing use case.
> 
> > At the very least you would want to enforce the use of a whole range
> > in the lockgroup case, but even there i question it's value.
> 
> I think, if you were going to enforce deny sys_setgroups() on a user
> you otherwise trusted, you'd probably only allow them a single range. 
>  But I suppose the flag should be or'd over all ranges.

Ok, yeah.  My thought this afternoon was that the point of the CVE was
that an unprivileged user, in the absence of any admin-provided
/etc/sub{u,g}id or new{u,g}idmap at all, and who was being denied a file
access through one of his aux groups, could use a user namespace to drop
the aux group and access the file.  That if an admin went to the trouble
to grant subuid and subgids then it wasn't an issue.  But of course
allocations are being done automatically now so that's not a valid
point.

So let's proceed with the patch :)

A PR using nosetgroups against git://github.com/shadow-maint/shadow would
be great.

thanks,
-serge
