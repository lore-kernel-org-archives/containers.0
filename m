From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: userns: targeted capabilities v4
Date: Tue, 11 Jan 2011 06:43:42 +0000
Message-ID: <20110111064342.GA27515__44867.5364292741$1294728245$gmane$org@mail.hallyn.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This version addresses feedback from and bugs pointed out by
Bastian.  It also adds user namespace checks in fs/namei.c.
If a task reads a file owned by another user_ns, it gets the
world access rights to that file.  Since inodes don't yet have
a user namespace, we just declare that init_user_ns owns them all.
So if you are root in a child user namespace, you effectively
are roaming the system as user nobody.  See 
http://www.spinics.net/lists/linux-containers/msg09716.html
and
http://www.spinics.net/lists/linux-containers/msg08486.html
for prior discussions.

[ Intro to v3 follows ]

The core of the set is patch 2, originally conceived and
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
checks against the initial user namespace.  The rest of the
patches begin to enable capabilities in child user namespaces
to setuid, setgid, set hostnames, kill tasks, and do ptrace.

My next step would be to re-introduce a part of a several year
old patchset which assigns a userns to a superblock (and hence
to inodes), and grants 'user other' permissions to any task
whose uid does not map to the target userns.  (By default, this
will be all but the initial userns)

thanks,
-serge
