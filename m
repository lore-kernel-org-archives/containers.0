From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [0/10] User namespaces: introduction
Date: Fri, 22 Aug 2008 13:41:14 -0700
Message-ID: <m1d4k0ixzp.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 14:45:13 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Hi Eric,
>
> so here is a start to a userns patchset trying to follow your ideas
> about how to have user namespaces and filesystems interact.  Ignore
> the bookkeeping crap or you'll pull your hair out.  Lots of stuff
> remains unimplemented - i.e. chown (setattr) and proper handling of
> capabilities.  But you can do some fun things with this patchset.
> I.e.
>
> 	(log in as root)
> 	setcap cap_sys_admin=ep ns_exec
> 	setcap cap_sys_admin=ep usernsmount
> 	ns_exec -U /bin/sh
> 	ls /root (fails)
> 	ls / (succeeds)
> 	(log in as hallyn)
> 	ns_exec -U /bin/sh
> 	id
> 		(uid=0, gid=0)
> 	ls (fails, can't descend /home/hallyn)
> 	usernsmount / nsid=4
> 	ls (succeeds)
> 	touch ab
> 	ls -l ab
> 		(ab is owned by root)
> 	exit
> 	(we're logged in as hallyn in the init_user_ns again)
> 	ls -l ab
> 		(ab is owned by hallyn)
>
> The only supported fs is ext3.  Only a few operations are supported.
> So if, above, when we are hallyn in the init_user_ns but root in
> the child user ns,
> 	when we create a file, it is properly handled, so
> 		inode->i_uid=500, but an xattr (nsid=4,uid=0) is added
> 	when we chown the file to root, it is not properly handled,
> 		so inode->i_uid = 0
> it's just a matter of hooking all the places at this point.
>
> Capabilities remain a problem.  Right now I think capabilities will
> need to be split up into system-wide caps, and container-safe caps.
> So CAP_NET_ADMIN, CAP_NET_RAW, CAP_DAC_OVERRIDE, those are container-safe.
> CAP_REBOOT may become container-safe one day, but for now is very
> much system-wide.
>
> So if I'm uid 500 on the host and create a user namespace where I'm
> uid=0, I should be able to acquire container-safe caps (perhaps
> contingent on whether I unshared all other namespaces), but not
> system-wide ones.  Or, whether I can acquire them would depend
> on whether the suid bit was set in a user_ns or not.  sigh.

Serge at first glance this looks like a good start, especially for thinking
through how things will work.

It has just occurred to me that from a dependency point of view it
makes an enormous amount of sense to sort out capable with
respect to namespaces before we get to the filesystems.

There is no one else working in the area of capabilities so there won't
be conflicts, and we need a firm understanding of how capabilities are
going to work with respect to namespaces before we start embedding
the logic in filesystems.

With respect to your separation of capabilities in namespaces I don't think
you have quite grasped the simple idea that is sitting in my head and makes
all of this clear.  Let me see if I can explain it better.

A fully qualified capability name would be of the form:
userns:capability_name

For each operation we will check for one specific capability.
For the network namespace in particular we will check for:
userns_of_network_namespace_creator:CAP_NET_ADMIN

The check for a capability will succeed if:
- We have the exact fully qualified capability. 
- We are outside the user namespace but are the owner of
  the user namespace.
- We are outside the user namespace but have the appropriate
  capability over the owner of the user namespace  CAP_PTRACE?

  This last test would recurses.

I'm less certain than I like about which permissions we allow someone outside
of a container to posses and still control the container.

This has two very useful implications.
- We can have all capabilities in a new user namespace and be completely
  impotent.
- Allowing the capabilities of a user namespace to do something useful
  can come gradually.

Which means we need to extend the classic capable check to become.
capable(userns, capability).  Or possibly we extend the capability
parameter to be a structure that can hold both userns and the capability,
whichever turns out to be more maintainable.

Once we have done that we can allow something to be under the power
of creator_user_ns:capability instead of init_user_ns:capability.

So the CAP_SYS_REBOOT test will be init_user_ns:capability for the 
foreseeable future.  While the CAP_NET_ADMIN test will shortly
become creator_of_netns:CAP_NET_ADMIN.

Of course none of that will happen until we relax the test to create a
new namespace from init_user_ns:CAP_SYS_ADMIN to
current_user_ns:CAP_SYS_ADMIN.

Eric
