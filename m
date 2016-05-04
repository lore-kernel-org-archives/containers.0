From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: bind mounting namespace inodes for unprivileged users
Date: Wed, 04 May 2016 13:28:10 -0400
Message-ID: <1462382890.14310.67.camel@HansenPartnership.com>
References: <1462299656.16133.51.camel@HansenPartnership.com>
	<87oa8lc2ic.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87oa8lc2ic.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2016-05-04 at 09:38 -0500, Eric W. Biederman wrote:
> James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> writes:
> 
> > Right at the moment, unprivileged users cannot call mount --bind to
> > create a permanent copy of any of their namespaces.  This is
> > annoying
> > because it means that for entry to long running containers you have
> > to
> > spawn an undying process and use nsenter via the /proc/<pid>/ns
> > files.
> > 
> > The first question is:  assuming we restrict it to bind mounting
> > only
> > nsfs inodes, is there any reason an unprivileged user shouldn't be
> > able
> > to bind a namespace they've created to a file they own in the
> > initial
> > mount namespace?
> 
> Own, have read/write and unlink privileges.
> 
> My big concern would be the fact that a bind mount today makes a file
> immune from unlink.  So it would mess up rm -rf.

Yes, that's true.  You have to unmount a bind mount, even of a file,
before you can remove it.  The way me mostly cope with this today is to
install the bind mounts on a tmpfs ... however, the unprivileged user
can't mount a tmpfs either ...

However, when I experimented, it seems that the rm isn't hard and fast.
 If I create a file outside the mount namespace, but then bind mount it
within the mount namespace, I can still remove it from the outside, in
which case the binding also disappears. The is_locally_mounted() check
in vfs_unlink() returns false because the file isn't covered outside
the child mount namespace.  It doesn't look like too much bother to
make unlink do the same for bind mounted files regardless of whether
the mount point is covered by another bind mounted file (although
obviously keeping the same semantics for directories).

> That might not be worse than what a setuid fuse mount binary allows
> today.

It's about the same: you can't remove the fuse mount point until it
gets unmounted.  If you have gvfs, you can see this by looking at
/run/user/<uid>/gvfs

> I wonder if there might is a way to setup a user namespace and mount 
> namespace combination so users could manage mounts in their own login 
> shells, just like is allowed in plan 9. Long term I think that would
> be more satisfactory.

So I thought about this as well.  However, you do want a single user
and mount namespace for all logins, which means it would have to be
managed by the login process itself.  That seemed to be quite a large
thing to parametrise to login.

> > So, does anyone have any strong (or even weak) opinions about this
> > before I start coding patches?
> 
> The mount namespace is complex and getting it right is a pain in the
> rear.  So adding yet another path and piece in to the existing
> complexity makes me cringe a little.

Yes, well which is worse: having no way to bind unprivileged containers
without spawning a long running process or having a way to bind them
which may lead to unremovable files.  Since I just use sudo mount -
-bind anyway for my containers, I don't see the file removal argument
as too daunting.

James
