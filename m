From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
Date: Tue, 12 May 2009 17:44:52 -0700
Message-ID: <20090513004452.GF3912@us.ibm.com>
References: <20090512215138.GD3912@us.ibm.com> <1242172010.5407.79.camel@heimdal.trondhjem.org> <m13ab97trc.fsf@fess.ebiederm.org> <1242173604.5407.82.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1242173604.5407.82.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 12, 2009 at 08:13:24PM -0400, Trond Myklebust wrote:
> On Tue, 2009-05-12 at 17:04 -0700, Eric W. Biederman wrote:
> > Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org> writes:
> > 
> > > Finally, what happens if someone decides to set up a private socket
> > > namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
> > > a private mount namespace? Would anyone have even the remotest chance in
> > > hell of figuring out what filesystem is mounted where in the ensuing
> > > chaos?
> > 
> > Good question.  Multiple NFS servers with the same ip address reachable
> > from the same machine sounds about as nasty pickle as it gets.
> > 
> > The only way I can even imagine a setup like that is someone connecting
> > to a vpn.  So they are behind more than one NAT gateway.
> > 
> > Bleh NAT sucks.
> 
> It is doable, though, and it will affect more than just NFS. Pretty much
> all networked filesystems are affected.
> 
> It begs the question: is there ever any possible justification for
> allowing CLONE_NEWNET without implying CLONE_NEWNS?

There are so many filesystem-based kernel APIs that this is a pervasive
problem IMHO -- not just with CLONE_NEWNET. However, even if we required
CLONE_NEWNET|CLONE_NEWNS network namespaces still present a problem to
network filesystems in general.

-Matt
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
