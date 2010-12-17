From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC 0/5] user namespaces: start clamping down
Date: Fri, 17 Dec 2010 15:22:46 +0000
Message-ID: <20101217152246.GA8221__33733.2260249697$1292599413$gmane$org@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Following is the next version of the user namespace patchset.

The core of the set is patch 2, originally conceived of and
implemented by Eric Biederman.  The concept is to target
capabilities at user namespaces.  A task's capabilities are
now contextualized as follows (previously, capabilities had
no context):

1. For a task in the initial user namespace, the calculated
capabilities (pi, pe, pp) are available to act upon any
user namespace.

2. For a task in a child user namespace, the calculated
capabilities are available to act only on its own or any
descendent user namespace.  It has no capabilities to any
parent or unrelated user namespaces.

3. If a user A creates a new user namespace, that user has
all capabilities to that new user namespace and any of its
descendents.  (Contrast this with a user namespace created
by another user B in the same user namespace, to which this
user A has only his calculated capabilities)

All existing 'capable' checks are automatically converted to
checks against the initial user namespace.  This means that
by default, root in a child user namespace is powerless.
Patches 3-5 begin to enable capabilities in child user
namespaces to set hostnames, kill tasks, and do ptrace.

My near-term next goals will be to enable setuid and setgid,
and to provide a way for the filesystem to be usable in child
user namespaces.  At the very least I'd like a fresh loopback
or LVM mount and proc mounts to be supported.

thanks,
-serge
