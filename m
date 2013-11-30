From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Sat, 30 Nov 2013 17:02:26 +0000
Message-ID: <20131130170226.GZ10323@ZenIV.linux.org.uk>
References: <20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131130061525.GY10323-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
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

On Sat, Nov 30, 2013 at 06:15:26AM +0000, Al Viro wrote:

> There's a bunch of unpleasant details around the handling of "what if
> the final vfsmount is detached or internal" (and induced weirdness
> with d_absolute_path(), etc. callers deciding whether they want to
> call ->d_dname() manually, since only d_path() calls it); I'll look into
> that.

FWIW, the other callers of prepend_path() boil down to /proc/mountinfo
handling, apparmour d_namespace_path() (separate handling of MNT_INTERNAL,
__d_path() or d_absolute_path() for the rest) and tomoyo_get_absolute_path()
(this one directly calls ->d_dname() itself).  Note that /proc/mountinfo
will spew garbage for your case (binding /proc/<pid>/ns/mnt somewhere);
the mountpoint will show correctly, but the relative name won't - it
goes through seq_dentry()->dentry_path() (this and apparmour d_namespace_path()
being the only codepaths to dentry_path(), BTW).  Eric, what behaviour
do you want there?

While we are at it: lustre contains this gem:
static char* ll_d_path(struct dentry *dentry, char *buf, int bufsize)
{
        char *path = NULL;

        struct path p;

        p.dentry = dentry;
        p.mnt = current->fs->root.mnt;
        path_get(&p);
        path = d_path(&p, buf, bufsize);
        path_put(&p);

        return path;
}
That should've been dentry_path(), reimplemented here with the usual braino.
Think what this hack produces if current is chrooted into fs in question;
the "clever" trick fails and instead of intended path from fs root we get
path from wherever current's chrooted to.  There's a reason why dentry_path()
had been introduced...

<looks at the callers of that wonder>
        /* this can be called inside spin lock so use GFP_ATOMIC. */
        buf = (char *)__get_free_page(GFP_ATOMIC);
        if (buf != NULL) {
                dentry = d_find_alias(page->mapping->host);
                if (dentry != NULL)
                        path = ll_d_path(dentry, buf, PAGE_SIZE);
        }
	...
	if (dentry)
		dput(dentry);

Good luck if it ever gets called under spinlock - dput() is not a thing you
should call in such place, ditto for path_put() from ll_d_path() itself...
What are the callchains leading there?  I've tried to track them, but gave
up after a while ;-/  I really hope that it's just "called under spinlock"
and not "called from softirq" or something like that...  Who maintains
that thing, anyway?

BTW, what happens if svc_export_request() ends up with pathname filling
almost all space left, so that qword_add(bpp, blen, pth) right after the
call of d_path() in there overwrites the beginning of d_path() output?
Neil?  And while we are at it, handling of overflow in there looks also
looks fishy...
