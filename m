From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Wed, 30 Apr 2014 00:21:43 +0000
Message-ID: <20140430002143.GB28969@ubuntumail>
References: <20140429220234.GC28410@ubuntumail> <536026B3.1020905@1h.com>
	<20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<536033A9.5070504@1h.com>
	<CALCETrVJY6SWjdbqSSCeOo9oid22TnL83v9oDVg06XLZfPkLCw@mail.gmail.com>
	<20140429234739.GB2997@dakara>
	<CALCETrXK6N8CLjPtnHVXB-BM_bxNU6e1xYGd=_UKcjKMrR3j0g@mail.gmail.com>
	<20140430000101.GC2997@dakara>
	<CALCETrWz2i1xE_t982yA8GG4a-rD4AnU_43YA8cNdC9NpSD4Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWz2i1xE_t982yA8GG4a-rD4AnU_43YA8cNdC9NpSD4Sg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Tue, Apr 29, 2014 at 5:01 PM, St=E9phane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> =
wrote:
> > On Tue, Apr 29, 2014 at 04:51:54PM -0700, Andy Lutomirski wrote:
> >> On Tue, Apr 29, 2014 at 4:47 PM, St=E9phane Graber <stgraber-GeWIH/nMZzJhl2p70BpVqQ@public.gmane.org=
m> wrote:
> >> > On Tue, Apr 29, 2014 at 04:22:55PM -0700, Andy Lutomirski wrote:
> >> >> On Tue, Apr 29, 2014 at 4:20 PM, Marian Marinov <mm-108MBtLGafw@public.gmane.org> wrote:
> >> >> > On 04/30/2014 01:45 AM, Andy Lutomirski wrote:
> >> >> >>
> >> >> >> On 04/29/2014 03:29 PM, Serge Hallyn wrote:
> >> >> >>>
> >> >> >>> Quoting Marian Marinov (mm-108MBtLGafw-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
> >> >> >>>>
> >> >> >>>> On 04/30/2014 01:02 AM, Serge Hallyn wrote:
> >> >> >>>>>
> >> >> >>>>> Quoting Marian Marinov (mm-108MBtLGafw-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
> >> >> >>>>>>
> >> >> >>>>>> On 04/29/2014 09:52 PM, Serge Hallyn wrote:
> >> >> >>>>>>>
> >> >> >>>>>>> Quoting Theodore Ts'o (tytso-3s7WtUTddSA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org):
> >> >> >>>>>>>>
> >> >> >>>>>>>> On Tue, Apr 29, 2014 at 04:49:14PM +0300, Marian Marinov w=
rote:
> >> >> >>>>>>>>>
> >> >> >>>>>>>>>
> >> >> >>>>>>>>> I'm proposing a fix to this, by replacing the
> >> >> >>>>>>>>> capable(CAP_LINUX_IMMUTABLE)
> >> >> >>>>>>>>> check with ns_capable(current_cred()->user_ns,
> >> >> >>>>>>>>> CAP_LINUX_IMMUTABLE).
> >> >> >>>>>>>>
> >> >> >>>>>>>>
> >> >> >>>>>>>> Um, wouldn't it be better to simply fix the capable() func=
tion?
> >> >> >>>>>>>>
> >> >> >>>>>>>> /**
> >> >> >>>>>>>>   * capable - Determine if the current task has a superior
> >> >> >>>>>>>> capability in effect
> >> >> >>>>>>>>   * @cap: The capability to be tested for
> >> >> >>>>>>>>   *
> >> >> >>>>>>>>   * Return true if the current task has the given superior
> >> >> >>>>>>>> capability currently
> >> >> >>>>>>>>   * available for use, false if not.
> >> >> >>>>>>>>   *
> >> >> >>>>>>>>   * This sets PF_SUPERPRIV on the task if the capability is
> >> >> >>>>>>>> available on the
> >> >> >>>>>>>>   * assumption that it's about to be used.
> >> >> >>>>>>>>   */
> >> >> >>>>>>>> bool capable(int cap)
> >> >> >>>>>>>> {
> >> >> >>>>>>>>         return ns_capable(&init_user_ns, cap);
> >> >> >>>>>>>> }
> >> >> >>>>>>>> EXPORT_SYMBOL(capable);
> >> >> >>>>>>>>
> >> >> >>>>>>>> The documentation states that it is for "the current task"=
, and I
> >> >> >>>>>>>> can't imagine any use case, where user namespaces are in e=
ffect,
> >> >> >>>>>>>> where
> >> >> >>>>>>>> using init_user_ns would ever make sense.
> >> >> >>>>>>>
> >> >> >>>>>>>
> >> >> >>>>>>> the init_user_ns represents the user_ns owning the object, =
not the
> >> >> >>>>>>> subject.
> >> >> >>>>>>>
> >> >> >>>>>>> The patch by Marian is wrong.  Anyone can do 'clone(CLONE_N=
EWUSER)',
> >> >> >>>>>>> setuid(0), execve, and end up satisfying
> >> >> >>>>>>> 'ns_capable(current_cred()->userns,
> >> >> >>>>>>> CAP_SYS_IMMUTABLE)' by definition.
> >> >> >>>>>>>
> >> >> >>>>>>> So NACK to that particular patch.  I'm not sure, but IIUC i=
t should
> >> >> >>>>>>> be
> >> >> >>>>>>> safe to check against the userns owning the inode?
> >> >> >>>>>>>
> >> >> >>>>>>
> >> >> >>>>>> So what you are proposing is to replace
> >> >> >>>>>> 'ns_capable(current_cred()->userns, CAP_SYS_IMMUTABLE)' with
> >> >> >>>>>> 'inode_capable(inode, CAP_SYS_IMMUTABLE)' ?
> >> >> >>>>>>
> >> >> >>>>>> I agree that this is more sane.
> >> >> >>>>>
> >> >> >>>>>
> >> >> >>>>> Right, and I think the two operations you're looking at seem =
sane
> >> >> >>>>> to allow.
> >> >> >>>>
> >> >> >>>>
> >> >> >>>> If you are ok with this patch, I will fix all file systems and=
 send
> >> >> >>>> patches.
> >> >> >>>
> >> >> >>>
> >> >> >>> Sounds good, thanks.
> >> >> >>>
> >> >> >>>> Signed-off-by: Marian Marinov <mm-NV7Lj0SOnH0-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
> >> >> >>>
> >> >> >>>
> >> >> >>> Acked-by: Serge E. Hallyn
> >> >> >>> <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
> >> >> >>
> >> >> >>
> >> >> >> Wait, what?
> >> >> >>
> >> >> >> Inodes aren't owned by user namespaces; they're owned by users. =
 And any
> >> >> >> user can arrange to have a user namespace in which they pass an
> >> >> >> inode_capable check on any inode that they own.
> >> >> >>
> >> >> >> Presumably there's a reason that CAP_SYS_IMMUTABLE is needed.  I=
f this
> >> >> >> gets merged, then it would be better to just drop CAP_SYS_IMMUTA=
BLE
> >> >> >> entirely.
> >> >> >
> >> >> >
> >> >> > The problem I'm trying to solve is this:
> >> >> >
> >> >> > container with its own user namespace and CAP_SYS_IMMUTABLE shoul=
d be able
> >> >> > to use chattr on all files witch this container has access to.
> >> >> >
> >> >> > Unfortunately with the capable(CAP_SYS_IMMUTABLE) check this is n=
ot working.
> >> >> >
> >> >> > With the proposed two fixes CAP_SYS_IMMUTABLE started working in =
the
> >> >> > container.
> >> >> >
> >> >> > The first solution got its user namespace from the currently runn=
ing process
> >> >> > and the second gets its user namespace from the currently opened =
inode.
> >> >> >
> >> >> > So what would be the best solution in this case?
> >> >>
> >> >> I'd suggest adding a mount option like fs_owner_uid that names a uid
> >> >> that owns, in the sense of having unlimited access to, a filesystem.
> >> >> Then anyone with caps on a namespace owned by that uid could do
> >> >> whatever.
> >> >>
> >> >> Eric?
> >> >>
> >> >> --Andy
> >> >
> >> > The most obvious problem I can think of with "do whatever" is that t=
his
> >> > will likely include mknod of char and block devices which you can th=
en
> >> > chown/chmod as you wish and use to access any devices on the system =
from
> >> > an unprivileged container.
> >> > This can however be mitigated by using the devices cgroup controller.
> >>
> >> Or 'nodev'.  setuid/setgid may have the same problem, too.
> >>
> >> Implementing something like this would also make CAP_DAC_READ_SEARCH
> >> and CAP_DAC_OVERRIDE work.
> >>
> >> Arguably it should be impossible to mount such a thing in the first
> >> place without global privilege.
> >>
> >> >
> >> > You also probably wouldn't want any unprivileged user from the host =
to
> >> > find a way to access that mounted filesytem but so long as you do the
> >> > mount in a separate mountns and don't share uids between the host and
> >> > the container, that should be fine too.
> >>
> >> This part should be a nonissue -- an unprivileged user who has the
> >> right uid owns the namespace anyway, so this is the least of your
> >> worries.
> >>
> >> --Andy
> >
> > It should be a nonissue so long as we make sure that a file owned by a
> > uid outside the scope of the container may not be changed even though
> > fs_owner_uid is set. Otherwise, it's just a matter of chmod +S on say
> > a shell and anyone who can see the fs from the host will be getting a
> > root shell (assuming said file is owned by the host's uid 0).
> =

> I feel like that's too fragile.  I'd rather add a rule that one of

yeah I don't wnat to rush something like that.  I'd rather stash
the userns of the task which did the mounting and check against
that.  Note that would make it worthless unless and until we allowed
mounting from non-init userns, but then we can only claim "our fs
superblock readers suck and therefore containers can't mount an fs"
so long before we start to feel some shame and audit them...

> these filesystems always acts like it's nosuid unless you're inside a
> user namespace that matches fs_owner_uid.
> =

> Maybe even that is too weird.  How about setuid, setgid, and fcaps
> only work on mounts that are in mount namespaces that are owned by the
> current user namespace or one of its parents?  IOW, a struct mount is
> only trusted if mnt->mnt_ns->user_ns =3D=3D current user ns or one of its
> parents?
> =

> Untrusted mounts would act like they are nosuid,nodev.  Someone can
> try to figure out a safe way to relax nodev at some point.
> =

> --Andy
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
