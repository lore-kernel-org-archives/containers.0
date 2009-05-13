From: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
Date: Tue, 12 May 2009 20:13:24 -0400
Message-ID: <1242173604.5407.82.camel@heimdal.trondhjem.org>
References: <20090512215138.GD3912@us.ibm.com>
	 <1242172010.5407.79.camel@heimdal.trondhjem.org>
	 <m13ab97trc.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m13ab97trc.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-05-12 at 17:04 -0700, Eric W. Biederman wrote:
> Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org> writes:
> 
> > Finally, what happens if someone decides to set up a private socket
> > namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
> > a private mount namespace? Would anyone have even the remotest chance in
> > hell of figuring out what filesystem is mounted where in the ensuing
> > chaos?
> 
> Good question.  Multiple NFS servers with the same ip address reachable
> from the same machine sounds about as nasty pickle as it gets.
> 
> The only way I can even imagine a setup like that is someone connecting
> to a vpn.  So they are behind more than one NAT gateway.
> 
> Bleh NAT sucks.

It is doable, though, and it will affect more than just NFS. Pretty much
all networked filesystems are affected.

It begs the question: is there ever any possible justification for
allowing CLONE_NEWNET without implying CLONE_NEWNS?

Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
