From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Thu, 22 Jun 2017 20:19:24 -0500
Message-ID: <20170623011924.GA4560__20450.0846601606$1498180770$gmane$org@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1498174161.7636.4.camel@HansenPartnership.com>
	<20170622233619.GC2894@mail.hallyn.com>
	<1498176787.7636.11.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1498176787.7636.11.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
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
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> On Thu, 2017-06-22 at 18:36 -0500, Serge E. Hallyn wrote:
> > Yes, the use case is: to allow root in the container to set the
> > privilege itself, without endangering any resources not owned by
> > that root.
> 
> OK, so you envisage the same filesystem being mounted in different user
> namespaces

Well no - in lxd we have a separate filesystem for each container.
The filesystems are not shared.

>  and being able to see their own value for the xattr.  It
> still seems a bit weird that they'd be able to change file contents and
> have that seen by the other userns but not xattrs.

Not sure what you mean.  If they have privilege over the inode, they
can write a xattr targeted at their own root userid.

> >   If you're going to have a root owned host-wide
> > orchestration system setting up the rootfs, then you don't
> > necessary need this at all.
> 
> I wasn't thinking it would be root owned, just that it would have a
> predefined range of allowed uids and be able to map multiple containers
> to subsets of these.

Hm. In that case they should not be allowed to write your proposed
'security.capability@uid' capability, because that would also grant
capabilities over subuids which they were not delegated.

(but see below)

> > As you say a @uid to say "any unprivileged userns" might be useful.
> > The implication is that root on the host doesn't trust the image
> > enough to write a real global file capability, but trusts it enough
> > to 'endanger' all containers on the host.  If that's the case, I have
> > no objection to adding this as a feature.
> 
> Yes, precisely.  The filesystem is certified as permitted to override
> the xattr whatever unprivileged mapping for root is in place.
> 
> How would we effect the switch?  I suppose some global flag because I
> can't see we'd be mixing use cases in a physical system.

I might be confused.  But thought CAP_SETFCAP against init_user_ns would
be required to set 'security.capability@uid'.  That, or you could create
a user namespace mapping [ 1 - 4294967295 ] to [ 0 = 4294967294 ], and
have CAP_SETFCAP against that namespace.  Which would allow you to run
without host root privilege.

-serge
