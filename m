From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Mon, 2 Dec 2013 07:29:06 +0000
Message-ID: <20131202072906.GD10323@ZenIV.linux.org.uk>
References: <20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
	<20131130224340.GA10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131130224340.GA10323-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
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

BTW, this "just use nd->path.mnt" is *not* guaranteed to work - sadly,
it's possible to get a _symlink_ bound somewhere.  I'm not sure whether
we should allow that or not, but as it is that's doable.  And with
your ->follow_link() that means ending up with (vfsmount,dentry) pair
that has dentry completely unrelated to vfsmount.  The thing is,
nd->path is where we would start the traversal for a normal symlink, i.e.
the directory where that thing had been found.  Which almost always gets
covered by the vfsmount as the symlink itself, with one exception - when
that symlink is bound there.

_Normally_ namei can cope with that just fine - if that's a normal symlink,
everything ends up working and we only have to take a bit of care about
link->mnt in fs/namei.c:follow_link().  With procfs-style symlinks it
also happens to work.  With one exception - /proc/<pid>/ns/*

Hell knows; my preference would be to ban that kind of crap, especially
since it comes from a rather convoluted loophole...

BTW, Linus, remember the thread back in March when I was grumbling about
procfs-symlinks-to-symlinks?  We ended up killing that BUG_ON() in
nd_jump_link() and back then I hadn't found sufficiently convincing breakage
to require failing such suckers with -ELOOP.  Looks like now I have a
reasonably good argument - pathname lookups with LOOKUP_FOLLOW should _not_
yield symlinks.  That's the loophole refered to above...

If you have happily flushed that memory, the problem was that following
a procfs symlink gives us location in the tree, but that's not enough
when that location itself happens to be a symlink; to resolve a normal
symlink we need both the symlink itself *and* where had it been found.
When we'd arrived to that symlink by following a procfs-style symlink,
the second part is missing.

Now, normally that's not an issue - to hit that case you need O_PATH|O_NOFOLLOW
open of a symlink (giving you an O_PATH descriptor of symlink itself) and
try to follow /proc/<pid>/fd/<that descriptor>.  No other way to get that
kind of symlink-to-symlink in procfs.  I argued for ELOOP on following
those guys; you replied with
<quote>
Why? That's what I did last week, it seemed to be the RightThing(tm)
to do. It somebody has opened a symlink, opening that again through
/proc gives you the same symlink. That would be the natural semantics,
no? You do *not* want to follow it any further, afaik.
</quote>

The trouble is, there is code assuming that LOOKUP_FOLLOW pathname
resolution will stop at non-symlink or fail.  One such example is
do_loopback(), aka. mount --bind old new, which uses LOOKUP_FOLLOW to
resolve old.  However, using the trick above (open a symlink with
O_PATH|O_NOFOLLOW, then pass /proc/self/fd/<descriptor> to mount(2)
with MS_BIND in flags) you can actually have it yield a symlink.
It mostly works (Eric's proc_ns_follow_link() is actually the only
instance that has problems with that setup), but it's certainly
unexpected.

And I'm not at all sure that we have no other place using LOOKUP_FOLLOW
and breaking if what it gets is a symlink...  I can buy your argument
about opening them (O_PATH open of /proc/self/fd/something yields
O_PATH descriptor of whatever's opened there, and if it's a symlink,
so be it - you've asked for it, you've got it), but I would like to have
path_lookupat() with LOOKUP_FOLLOW fail if it's ended up in a symlink.
With ELOOP, probably.

I agree that nd_jump_link() is not a good place for that; I would add
        if (!err && nd->flags & LOOKUP_FOLLOW) {
                if (unlikely(d_is_symlink(nd->path.dentry))) {
                        path_put(&nd->path);
                        err = -ELOOP;
                }
        }
next to similar check for LOOKUP_DIRECTORY in path_lookupat().  Objections?
