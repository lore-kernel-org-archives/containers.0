From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Wed, 30 Apr 2014 00:44:53 +0000
Message-ID: <20140430004453.GD28969@ubuntumail>
References: <20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<536033A9.5070504@1h.com>
	<CALCETrVJY6SWjdbqSSCeOo9oid22TnL83v9oDVg06XLZfPkLCw@mail.gmail.com>
	<20140429234739.GB2997@dakara>
	<CALCETrXK6N8CLjPtnHVXB-BM_bxNU6e1xYGd=_UKcjKMrR3j0g@mail.gmail.com>
	<20140430000101.GC2997@dakara>
	<CALCETrWz2i1xE_t982yA8GG4a-rD4AnU_43YA8cNdC9NpSD4Sg@mail.gmail.com>
	<20140430002143.GB28969@ubuntumail>
	<CALCETrVh0hCtiK=9fmEYfUWuz4C1dPq22kvyd=OWFMH5pXGaZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVh0hCtiK=9fmEYfUWuz4C1dPq22kvyd=OWFMH5pXGaZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> On Tue, Apr 29, 2014 at 5:21 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> >> > It should be a nonissue so long as we make sure that a file owned by a
> >> > uid outside the scope of the container may not be changed even though
> >> > fs_owner_uid is set. Otherwise, it's just a matter of chmod +S on say
> >> > a shell and anyone who can see the fs from the host will be getting a
> >> > root shell (assuming said file is owned by the host's uid 0).
> >>
> >> I feel like that's too fragile.  I'd rather add a rule that one of
> >
> > yeah I don't wnat to rush something like that.  I'd rather stash
> > the userns of the task which did the mounting and check against
> > that.  Note that would make it worthless unless and until we allowed
> > mounting from non-init userns, but then we can only claim "our fs
> > superblock readers suck and therefore containers can't mount an fs"
> > so long before we start to feel some shame and audit them...
> >
> >> these filesystems always acts like it's nosuid unless you're inside a
> >> user namespace that matches fs_owner_uid.
> >>
> >> Maybe even that is too weird.  How about setuid, setgid, and fcaps
> >> only work on mounts that are in mount namespaces that are owned by the
> >> current user namespace or one of its parents?  IOW, a struct mount is
> >> only trusted if mnt->mnt_ns->user_ns == current user ns or one of its
> >> parents?
> >>
> >> Untrusted mounts would act like they are nosuid,nodev.  Someone can
> >> try to figure out a safe way to relax nodev at some point.
> 
> Do you like this variant?  We could add a way for global root to mount
> an fs on behalf of a userns.  I'd rather this be more explicit than
> just mounting it in a mount ns owned by the user namespace, though.

I'm missing something.  Which mnt are you talking about?  A user
can just clone a new userns and then clone(CLONE_NEWNS) to get a set
of mounts owned by himself...  We need to get a mnt (or a cred or
straight to a userns) tied to the first mount of the superblock, istm.

-serge
