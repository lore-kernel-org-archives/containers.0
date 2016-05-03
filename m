From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: bind mounting namespace inodes for unprivileged users
Date: Tue, 03 May 2016 14:20:56 -0400
Message-ID: <1462299656.16133.51.camel__28921.195495832$1462299688$gmane$org@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Right at the moment, unprivileged users cannot call mount --bind to
create a permanent copy of any of their namespaces.  This is annoying
because it means that for entry to long running containers you have to
spawn an undying process and use nsenter via the /proc/<pid>/ns files.

The first question is:  assuming we restrict it to bind mounting only
nsfs inodes, is there any reason an unprivileged user shouldn't be able
to bind a namespace they've created to a file they own in the initial
mount namespace?

Assuming the answer to this is no, then how to implement it becomes the
next problem.  Right at the moment, util-linux/mount will deny a non
-root user the ability to use --bind.  This check could be relaxed and,
since mount is setuid root, it could be modified to force the binding
as root meaning this could be implemented entirely within the util
-linux package.

Doing this from within the kernel sys_mount is much more problematic:
no root users are forbidden from calling any type of mount by the
may_mount() check, which makes sure you only have root capability in
the user_ns attached to the current mnt_ns.  Overriding that simply to
allow nsfs binding looks like a recipe for introducing unexpected
security problems.

So, does anyone have any strong (or even weak) opinions about this
before I start coding patches?

James
