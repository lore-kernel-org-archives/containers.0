From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: userns: targeted capabilities v5
Date: Thu, 17 Feb 2011 15:02:24 +0000
Message-ID: <20110217150224.GA26334__22786.7324873388$1297955010$gmane$org@mail.hallyn.com>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Here is a repost of my previous user namespace patch, ported onto
last night's git head.

It fixes several things I was doing wrong in the last (v4)
posting, in particular:

	1. don't set uts_ns->user_ns to current's when !CLONE_NEWUTS
	2. add a ipc_ns->user_ns which owns ipc_ns, and use that to
	   decide CAP_IPC_OWNER
	3. fix logic flaw caused by bad parantheses
	4. allow do_prlimit to current
	5. don't always give root full privs to init_user_ns

The expected course of development for user namespaces is laid out
at https://wiki.ubuntu.com/UserNamespace.  Bugs aside, this
patchset is supposed to not at all affect systems which are not
actively using user namespaces, and only restrict what tasks in
child user namespace can do.  They begin to limit privilege to
a user namespace, so that root in a container cannot kill or
ptrace tasks in the parent user namespace, and can only get
world access rights to files.  Since all files currently belong
to the initila user namespace, that means that child user
namespaces can only get world access rights to *all* files.
While this temporarily makes user namespaces bad for system
containers, it starts to get useful for some sandboxing.

I've run the 'runltplite.sh' with and without this patchset and
found no difference.  So all in all, this is the first version
of this patchset for which I feel comfortable asking:  please
consider applying.

thanks,
-serge
