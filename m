From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Fri, 17 Jan 2014 08:39:01 +0000
Message-ID: <20140117083901.GA10323@ZenIV.linux.org.uk>
References: <20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
	<20131130224340.GA10323@ZenIV.linux.org.uk>
	<874n53gub7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <874n53gub7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 16, 2014 at 07:29:16PM -0800, Eric W. Biederman wrote:

> However it would be nice to see:
> 28 13 0:3 net:[4026532127] /var/run/netns/foo rw,nosuid,nodev,noexec,relatime - proc proc rw
> 
> Not having the path be the magical floating path is not causing
> regressions for people so I don't care much at the moment.

> >> Any dentry allocated with d_alloc_pseudo will have the same problem if
> >> it is ever in a context where it can be bind mounted.  So this is a
> >> general issue with d_name.
> >
> > Yes, ->d_dname() is called in a wrong place.  It should be in prepend_path
> > if not deeper.  What you are doing is growing a kludge on top of that
> > mistake.
> 
> I disagree. I am not growing a kludge on of a mistake.  I am refining
> the logic at the call site of d_dname.  The logic to not call d_dname
> on a mountpoint should be there wherever we call d_dname.

What, in your opinion does the word "kludge" mean?  The usual meaning is
"a change that might work, but depends on too many easy-to-break
accidental details of the current construction".  If you want to use
a different term, fine, but the problem doesn't disappear from renaming
things.

I agree that your patch doesn't break things and I've said so from the
very beginning.

[snip the obvious analysis]

> At a practical level there are improvements to be had by calling d_dname
> in dentry_path and by adding my avoidance of calling d_dname on a
> mountpoint into tomoyo_realpath_from_path.

... i.e. making things even more convoluted.  Congratulations, that's
just what we need.

> So while I see what you mean by prepend_path needing cleaning up that is
> really orthogonal to the acidental regression that I am fixing.
> 
> > As for redesign...  That's exactly what is needed in that area, instead of
> > letting it fester.
> 
> I can't backport a redesign to fix the regression, and a redesign
> results in no practical benefit for me.  So I might be persuaded later
> if I can find the time but right now a redesign is the wrong place to
> start.

Gotta love the style, but... I'm not persuaded by the above.  At all.

> > As for check_mnt(old) in do_loopback()...  I wonder if we shouldn't just
> > turn that puppy into (check_mnt(old) || (old->mnt.mnt_flags & MNT_INTERNAL)).
> > Note that MS_NOUSER in superblock flags would prevent binding pipefs and
> > all mount_pseudo() users, so we wouldn't change existing behaviour...
> 
> Strictly speaking behavior would change for the proc namespace files, as
> now you could do things by finding a mount of proc in another mount
> namespace where the namespace files were available.

Er...  Yes, and?  If you can do that, you can bloody well just open them
there and then do exact same thing.

The visible change would be different - it would be the ability to bind
hugetlbfs and shmem anon mappings via /proc/*/map_files/*

> I would be a lot more comfortable with changing do_loopback if we could
> safely remove the check_mnt(old) test altogether.  Why do we have the
> check_mnt(old) test in do_loopback?   If we can't remove the
> check_mnt(old) test I need verify that the reasons for that test don't
> apply to my namespace file descriptor case.  Otherwise I can't see any
> real problems with making that change (time permitting).

Sigh...  You do realize that right now your proc_ns_follow_link() violates
a pretty basic assert: nd->path.mnt->mnt_sb == nd->path.dentry->d_sb,
right?  IOW, that dentry belongs to the filesystem pointed to be vfsmount.

At ->follow_link() time we have two objects to keep track of: where we are
in pathname resolution (i.e. which directory had we reached) and what
symlink are we resolving.  nd->path points to the former; the first
argument of ->follow_link() - to the latter.  _Usually_ the parent is
on the same vfsmount as the symlink, so your shortcut doesn't blow up
all the time.  However, that is not guaranteed - it *is* possible to
bind a symlink.  Not conveniently at the moment, but it can be done and
there's no fundamental reasons why it should be forbidden.  And in that
setup proc_ns_follow_link() is in trouble.

The reasons for check_mnt() there are, IIRC, more about playing silly buggers
with propagation trees from some other namespace.  IOW, they do not apply
to cloning stuff off the internal vfsmounts.

/proc/*/map_files/* is potentially a problem, though - being able to
create a binding to something on hugetlbfs might have interesting implications.
