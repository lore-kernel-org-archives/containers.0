From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Thoughts on virtualizing task containers
Date: Mon, 1 Oct 2007 12:24:47 -0500
Message-ID: <20071001172447.GA20870@sergelap.austin.ibm.com>
References: <6599ad830708231718x7b63f993vdfef5b503668989d@mail.gmail.com>
	<20070827144025.GE4505@sergelap.austin.ibm.com>
	<6599ad830708281411x32fd0ca4u22464430d14bd990@mail.gmail.com>
	<20070911135925.GB15217@sergelap.austin.ibm.com>
	<6599ad830709252223r4b319d8dxa326aef8ff444606@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830709252223r4b319d8dxa326aef8ff444606-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On 9/11/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Hi Paul,
> >
> > did any good ideas come up at the mini-summit or k-s, or were any
> > decisions made?
> >
> 
> Discussions were had, but decisions weren't really made.
> 
> My vague thoughts on how to do virtualization are below.

Thanks.  Actually doesn't seem that vague, and makes sense.
I'd advocate following this path.  Have you started any
patches for this?

> 1) Add support for a subsystem state object to be shared with its
> children. specifically:
> - for each subsystem, have a <subsystem.inherit> control file, which
> defaults to 0. This can only be changed when the cgroup has no
> children
> - any children of a cgroup will share subsystem state with the parent
> for any subsystems whose <inherit> file is 1
> 
> This ties in with a request that Balbir made for being able to share
> resource limits between different levels of cgroups, but it's also
> useful for virtualization. It's something I wanted to describe in my
> OLS talk but didn't really have time for.
> 
> 2) have a virtualization cgroup subsystem, which like other subsystems
> can be included in at most one hierarchy. The virtualization subsystem
> might perhaps be the same thing as the nsproxy subsystem?
> 
> 3) when mounting a cgroup filesystem, if the virtualization subsystem
> is mounted, and the caller is not in its root cgroup (i.e. it's a
> guest), then:
> 
> - the guest can only see subsystems in the same hierarchy, which

same hierarchy as the virtualization cgroup subsystem, right?

> additionally have <inherit> set to 0
> 
> - the vfsmount returned from cgroup_get_sb() doesn't refer to the root
> of the hierarchy, but instead to the cgroup directory that the guest
> is in
> 
> - the guest can only mount a single hierarchy, (which therefore must
> be a subset of the hierarchy that the guest is running in)
> 
> - at the time of mount, the <inherit> bits for any subsystems *not*
> selected by the guest get set to 1, thus any guest processes share the
> same subsystem state for those subsystems (this is analagous to having
> the subsystem not be mounted, at the root/host level).

So then for subsystems which the guest did select, are there
default values inherited from the parent cgroup, and restrictions based
on those?  Or does the guest get to set any values it wants for those
subsystems?

> This approach is a little more restrictive than I'd like, but I think
> it should support the basic nested virtual server model reasonable
> well.
> 
> These changes are going to require a little bit of plumbing in the
> core cgroup code, but should have very little effect on any subsystems
> themselves, except for a few ways:
> 
> - each subsystem will now have a private parent/child tree running
> through its subsystem states, rather than having to use the main
> cgroup tree
> 
> - there will no longer be a direct mapping from a subsystem state to a
> cgroup. I'm not sure that this will cause anyone a problem. we'll have
> to tweak the current cgroup iteration interfaces to instead iterate
> across all the processes in a subsystem state, which may include
> multiple cgroups
> 
> Paul
