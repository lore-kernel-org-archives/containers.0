From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: bind mounting namespace inodes for unprivileged users
Date: Wed, 04 May 2016 09:38:03 -0500
Message-ID: <87oa8lc2ic.fsf@x220.int.ebiederm.org>
References: <1462299656.16133.51.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1462299656.16133.51.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> (James
	Bottomley's message of "Tue, 03 May 2016 14:20:56 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> writes:

> Right at the moment, unprivileged users cannot call mount --bind to
> create a permanent copy of any of their namespaces.  This is annoying
> because it means that for entry to long running containers you have to
> spawn an undying process and use nsenter via the /proc/<pid>/ns files.
>
> The first question is:  assuming we restrict it to bind mounting only
> nsfs inodes, is there any reason an unprivileged user shouldn't be able
> to bind a namespace they've created to a file they own in the initial
> mount namespace?

Own, have read/write and unlink privileges.

My big concern would be the fact that a bind mount today makes a file
immune from unlink.  So it would mess up rm -rf.

That might not be worse than what a setuid fuse mount binary allows
today.

I wonder if there might is a way to setup a
user namespace and mount namespace combination so users could manage
mounts in their own login shells, just like is allowed in plan 9.
Long term I think that would be more satisfactory.


> So, does anyone have any strong (or even weak) opinions about this
> before I start coding patches?

The mount namespace is complex and getting it right is a pain in the
rear.  So adding yet another path and piece in to the existing
complexity makes me cringe a little.

Eric
