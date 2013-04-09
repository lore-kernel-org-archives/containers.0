From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 9 Apr 2013 12:38:51 -0700
Message-ID: <20130409193851.GJ6186@mtj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<20130409095024.GI25576@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130409095024.GI25576-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Daniel.

On Tue, Apr 09, 2013 at 10:50:25AM +0100, Daniel P. Berrange wrote:
> The PaxControlGroups document is the key piece to making distributed
> management work. This document does need updating, since some of what
> it describes doesn't really work, but its goal is sound IMHO.

I think we should add a comment to the doc saying "this is how to keep
things from falling apart completely but in no way is a long term
solution."

> The Workman library is presuming that apps will follow the PaxControlGroups
> guidelines for use of cgroups, and from there aims to provide system
> administrators with a "single world view" and tools to then configure
> this. It does not, however, attempt to force itself underneath the
> apps like systemd / libvirt, since there is no need todo that. It
> just aggregates information from system/libvirt/etc so that admin has
> the complete picture of what the cgroups are being used for.

I suppose that can be useful for now but pretty strongly disagree it
would be acceptable as long term solution.

> I don't see that creating a "single authority" magically solves any
> of the problems you describe. For example, such an authority can't
> know whether it should delete a cgroup just because an application
> exits. It is quite possible an application would want the cgroup to
> continue to exist, so that it is still there when it restarts.

Sure, then make it request the persistency explicitly.  The debate is
not whether trusting each individual player can show similar result.
Sure, that's in the realm of possibility.  If you push it as far as
"everyone" should and would behave properly even on edge cases, I
would have to add "theoretical" there tho.  The debate is which is the
better way to achieve the desired goals and up until now I don't see
any pros for the distributed approach other than "this is what we've
been doing till now".

> Ultimately it is the end admin or top level management tool that has
> the whole picture. The Workman library / cli is aiming to provide
> admins / apps with the complete picture of everything that is using
> resources on the system, so they can adjust policies dynamically.

Again, I don't know.  It can be useful for now I suppose.  I just
can't see it being the long term solution.

> You seem to be implying that 'distributed == anything goes', which is
> certainly not what I consider to be the case. Indeed the main point
> of having the PaxControlGroups guidelines is explicitly because we do
> *not* want an "anything goes" approach.

Yeah, by asking cooperations from individual players without any way
to monitor or police them.

> We ultimately do need the ability to delegate hierarchy creation to
> unprivileged users / programs, in order to allow containerized OS to
> have the ability to use cgroups. Requiring any applications inside a
> container to talk to a cgroups "authority" existing on the host OS is
> not a satisfactory architecture. We need to allow for a container to
> be self-contained in its usage of cgroups.

I'm not sure about this one.  Yeah, we might need delegation there at
least for now.  That said, it's not gonna be completely consistent.
Root cgroup is special for several controllers and we even have
controllers which propagate config changes down the hierarchy.  It
just isn't built for proper delegation.

> I don't think that requiring a single userspace authority is
> satisfactory. We need to be able to delegate this to containers,
> without them needing to talk to some authority back in the
> host OS, so that they remain 100% isolated from processes in
> the host OS.

It's unlikely to work that well.  I think a good mental image to have
for cgroup is that of sysctl rather than a generic file system.  You
can't go delegate sysctl control knobs to containers or !root users.
You need an extra layer of control to do that.  It's true that such
policing could happen in the kernel, but something in the kernel being
exposed to untrusted entities has a lot of implications as the kernel
now becomes heavily involved in *policy* decisions as to what can be
allowed and what can't be and the kernel has a lot less latitude in
making those decisions compared to userland base system.

There are also security implications.  memcg control knobs directly
regulate the operation of memory reclaim and writeback.  I wouldn't be
surprised if there are pretty easy ways to make them go bonkers while
staying inside the limits from the parent.  Again, think of sysctl.
You don't wanna hand these out to untrusted entities.

> We need to make the distribute approach work in order to support
> containers, which requiring them to have a back-channel open to
> the host userspace. If we can do that, then we've solved the problem
> of delegated to unprivileged users in non-container environments too.
> IMHO with a sufficiently specified PaxControlGroups the distributed
> approach is just fine. If applications are badly behaved and don't
> follow the rules, then so be it, file bugs against those apps. Both
> libvirt & systemd are committed to following rules for co-operating
> in usage of cgroups & Workman can provide a "single unified view"
> for the administrator without requiring a single authority too.

Well, you guys can try I guess.  Maybe I'm wrong and workman turns out
to be awesome.  I'll be happy to switch my position then, but for now,
the kernel isn't moving towards that direction.

Thanks.

-- 
tejun
