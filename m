From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 06 Jan 2010 12:43:41 -0800
Message-ID: <m14omzx8ua.fsf@fess.ebiederm.org>
References: <20100106062809.GA17064@us.ibm.com>
	<m13a2j2q7c.fsf@fess.ebiederm.org> <20100106173056.GC15784@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100106173056.GC15784-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 6 Jan 2010 11\:30\:56 -0600")
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

> But that's only if fred has CAP_KILL in a user namespace which is
> ancestor to joe's process.  Only fred's processes in a child
> userns should have CAP_KILL.

Got it.  What I don't see in your implementation is how you can kill a
child that is in it's own user namespace if you don't have CAP_KILL.

>> Which matters because we can set the hostname through /proc/sys....
>
> Oh, right.  However, utsname doesn't have a creator, and we won't always
> want to use user namespaces to authorize.  For instance, for CAP_NET_ADMIN
> we'll want to compare the net_ns.  That's why I had the switch inside
> capable_to() based on ns type.

I disagree.  For CAP_NET_ADMIN we will want to do:
ns_capable(net->userns, CAP_NET_ADMIN);

Network namespaces do not have a hierarchy so I don't see how they
would be useful in this context.

When we add an unprivileged unshare it is trivial to capture either
the creator or at least the creators user namespace.  Giving us a
usernamespace to compare against.

Eric
