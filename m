From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Improve NFS use of network and mount namespaces
Date: Tue, 12 May 2009 18:11:41 -0700
Message-ID: <m1zldh4xiq.fsf@fess.ebiederm.org>
References: <20090512215138.GD3912@us.ibm.com>
	<1242172010.5407.79.camel@heimdal.trondhjem.org>
	<m13ab97trc.fsf@fess.ebiederm.org>
	<1242173604.5407.82.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1242173604.5407.82.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (Trond Myklebust's message of "Tue\, 12 May 2009 20\:13\:24 -0400")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org> writes:

> On Tue, 2009-05-12 at 17:04 -0700, Eric W. Biederman wrote:
>> Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org> writes:
>> 
>> > Finally, what happens if someone decides to set up a private socket
>> > namespace, using CLONE_NEWNET, without also using CLONE_NEWNS to create
>> > a private mount namespace? Would anyone have even the remotest chance in
>> > hell of figuring out what filesystem is mounted where in the ensuing
>> > chaos?
>> 
>> Good question.  Multiple NFS servers with the same ip address reachable
>> from the same machine sounds about as nasty pickle as it gets.
>> 
>> The only way I can even imagine a setup like that is someone connecting
>> to a vpn.  So they are behind more than one NAT gateway.
>> 
>> Bleh NAT sucks.
>
> It is doable, though, and it will affect more than just NFS. Pretty much
> all networked filesystems are affected.

Good point.  That was an oversight when I did the initial round of patches
to deny the unsupported cases in other than the initial network namespace.

> It begs the question: is there ever any possible justification for
> allowing CLONE_NEWNET without implying CLONE_NEWNS?

Superblocks and the like are independent of the mount namespace.  So I
don't even seeing CONE_NEWNS helping except for looking in
/proc/mounts.

If network filesystems have a path based identity.  AKA ip address.  This
is a problem.  If there is some kind of other identity like a uuid
this problem might not even matter.

As for the original question.

We have test setups at work where we have tests running in different
network namespaces but they don't conflict in the filesystem so
CLONE_NEWNS would be redundant.  As well as unhelpful.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
