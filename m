From: Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Fri, 9 Aug 2013 20:40:35 +0200
Message-ID: <20130809184035.GC13067__17848.2394935147$1376073670$gmane$org@nekral.nekral.homelinux.net>
References: <87d2wxshu0.fsf@xmission.com>
	<20130728171451.GX5670@mykerinos.kheops.frmug.org>
	<87r4eilg6y.fsf@xmission.com>
	<11218395-363e-46cd-b7a1-4488079a4986@email.android.com>
	<20130806145403.GA20913@mail.hallyn.com>
	<20130806225332.GA14109@nekral.nekral.homelinux.net>
	<20130807153352.GA5022@sergelap> <87eha5peb8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87eha5peb8.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Aug 07, 2013 at 11:04:59AM -0700, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org wrote:
> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> > Quoting Nicolas Fran=E7ois (nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org):
> >> On Tue, Aug 06, 2013 at 02:54:03PM +0000, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org wrote:
> >> > =

> >> > I rebased and pushed the patchset yesterday.
> >> =

> >> Thanks (this removes me the burden of finding how to merge a branch).
> >> =

> >> I started to review and read about user namespaces (thanks to Michael!)
> >> o
> >> Here are some questions/remarks:
> >> =

> >>  1] It would be nice to be able to disable the new tools / manpages /
> >>     options on some systems (i.e. they only make sense on Linux, with
> >>     recent Kernel). It would be OK for me if it is enabled by default.
> >>     Do you agree?
> >
> > Makes sense.
> >
> >>  2] I think we can assume that UID/GIDs are (at least) 32 bits, right?
> >>     (or at least when the feature is not disabled - see point 1)
> >
> > Hm, what about systems compiled with CONFIG_UID16?

At config time, we can check that uid_t and gid_t allow for 32 bit IDs.

> >>  3] For PAM versions of shadow, I think it would be nice to authentica=
te
> >>     the caller of newuidmap / newgidmap. Do you agree?
> >
> > I'm not sure what you mean.  Do you mean that pam_something.so could
> > otherwise call newuidmap/newgidmap before being authenticated?
> =

> It sounded to me like he was suggesting newuidmap/newgidmap should make
> an appropriate pam call.  I am not familiar with that part of pam so I
> don't know what would be an appropriate pam call.
> =

> The closest analog I can think of is newgrp, and to my knowledge newgrp
> does not cal into pam.

I was thinking about something like in chsh. But the analogy with newgrp
is better. So lets forget about it.

> >>  4] What happens when newuidmap / newgidmap are used within a new name=
space?
> >>     Is there a risk to do something wrong by recursively creating shel=
ls in
> >>     cascaded namespace and using these tools? (I don't think so)
> >>     Is there a way to enforce that it would only be used in the top-mo=
st
> >>     namespace? (Maybe it's not needed to forbid it)
> >
> > The kernel user namespace implementation is designed to support nesting.
> >
> > Actually I'm not 100% sure, but I think that setuid-root is currently
> > only honored in the initial user namespace.  If that were changed,
> > then calling newuidmap from a child user namespace would only give
> > the caller privilege over his child user namespace.  Therefore he
> > could only delegate userids from his own (non-init) namespace to
> > his own descendent user namespaces.
> >
> > calling newuidmap on a pid in the initial user namespace results in
> > -EPERM (as otherwise an unprivileged user could remap privileged
> > tasks to his permitted subuids :)
> =

> There are slightly funny things with setuid and setcap.
> =

> The short version however is that once in a user namespace you will
> never have more permissions than your the root user in your user
> namespace.
> =

> So from the outside of the user namespace you can't do anything bad even
> with nesting.  Aka there is no defined means to escapte privileges from
> inside a user namespace to anything privileged outside a user namespace.
> =

> From inside the user namespace you can only follow /etc/subuid or
> /etc/subgid (when setting up a nested user namespace).  And if that is a
> concern the root user of a user namespace can just create a new mount
> namespace and mount over the top of them.
> =

> So I don't see anything to concern about.

OK.

> >>     It would be worth to have at least a paragraph about it in the
> >>     manpages. (i.e. IDs in /etc/sub*id are according to the caller's
> >>     namespace)
> >
> > Agreed.

Lets ignore it currently. It will be users/admins' responsibility to setup
the right ranges usable in the caller environment.

> >>  5] It would be worth documenting on which processes newuidmap / newgi=
dmap
> >>     can act.
> >>     With newuidmap, an user can set the UID mapping for any process wi=
th
> >>     restrictions on the process and on the requested ranges.
> >>     We could also mention that the kernel enforce also restriction (5
> >>     lines at most; can only be written once)
> >
> > Note that there are under-development very detailed manpages for
> > namespaces(7) and user_namespaces(7).  I agree the newuidmap
> > manpage should document what it can act, a one or two line addition
> > to DESCRIPTION.  Then it should simply refer to the other manpages.
> =

> Yeah.  I should follow up and see what has happend with all of that.

I will add references to these manpages.


> >>  5.1] The restriction on the caller or processes seems to be the follo=
wings:
> >>     if ((getuid() !=3D pw->pw_uid) ||   // not needed (already enforced
> >>                                       // by get_my_pwent()) - but does=
 not
> >>                                       // harm.
> >>         (getgid() !=3D pw->pw_gid) ||   // I don't understand this
> >>                                       // restriction. If I execute a
> >>                                       // shell with another GID (e.g. =
using
> >>                                       // newgrp) why should it be deni=
ed?
> >
> > I'm not sure.  I don't know whether Eric was following conventions
> > elsewhere in the code, or had specific attacks in mind.
> =

> I don't have the context handy, but I think that was general paranoia.
> On the lines of if something strange is going on don't allow it.

This test ("getgid() !=3D pw->pw_gid") can be bypassed by executing
newuidmap in another shell, with the right gid.
I propose to remove it.

> >>         (pw->pw_uid !=3D st.st_uid) ||

That part is needed.
Is there also the need to check that the process cannot change its
effective UID?

> >>         (pw->pw_gid !=3D st.st_gid)) {  // Is it also needed? What wou=
ld be
> >>                                       // the problem
> >
> > IIUC uid 1000, authorized to use subuids 100000-110000, could otherwise
> > use newuidmap to remap a namespace owned by uid 1001.

OK for the test on UID, but I don't get the point for checking the GID.
Note that we can also put this restriction and wait for a user request.

Also regarding this block, the permission of /proc/<pid> are checked.
I've read that there is the concept of a namespace owner (uid/gid of
/proc/<pid>/uid_map. Is it also something to be checked?

> >>  6]=A0Documenting the APIs would be useful. Especially the ones in
> >>     lib/subordinateio.c (after 5 minutes, I get lost with the
> >>     is_range_free, range_exists, find_range, have_range, ...)
> >
> > In-line (above each function) or elsewhere?

A small paragraph above each function would be perfect.

> >>  7] I'm not sure about the handling of limits of ranges.
> >>     * First, I'm not sure what is intended. (e.g. is SUB_GID_MAX inclu=
ded in
> >>     the range)
> >>     * In libmisc/find_new_sub_uids.c: Is it intended to forbid min =3D=
=3D max
> >>       (I'm not claiming this is very useful, but if
> >>       SUB_GID_MIN=3DSUB_GID_MAX and SUB_GID_COUNT is set to 1, this sh=
ould
> >>       be valid to set a single mapping for one UID)
> >
> > Agreed that sounds like it should be allowed.
> >
> >>     * In find_free_range(), min=3D=3Dmax is also forbidden.
> >>     * In find_free_range(), the check (high > low) forbids to reuse a =
hole
> >>       of just 1 UID starting at min
> >>     ...
> =

> Scratching my head.  When ranges are bounded by two numbers it gets
> weird.  All I remember for certain is I deliberately choose the file
> format of uid, length so that it would be hard to make off by one
> mistakes in the files.

I will create tests for the boundary conditions.

> >>  8] Is there a need to check somewhere that that UID_MAX < SUB_UID_MIN=
 in
> >>     login.defs? Or is it valid to have overlaps?
> >
> > That sounds like a dangerous condition to me, and I had assumed it was
> > already checked somewhere.
> =

> These were fairly arbitrary defines, with no sanity checks and I didn't
> add any.  I just had sensible defaults.  As that tends to be the unix
> way. You can have rope to shoot yourself if you really want it.
> =

> I really have no opinion on the need for sanity checks one way or another.

I can add a warning in pwck (can't find of a better place (useradd?)).

> >>  9]=A0Add manpage NOTE that newuidmap / newgidmap can be used only onc=
e on a
> >>     given process?
> >
> > Agreed.
> >
> >> 10] useradd adds sub*id when the /etc/sub*id files are present, right?
> >>     Is it also correct/intended for system users?
> >>     I think there should be options to enable or disable the feature.
> >>     (I would have chosen the first solution, but I can also understand
> >>     that we consider that the presence of the files is a request to use
> >>     the feature by default)
> >
> > Not sure on both of those.  Actually given the (artificial) definition
> > of a system user in useradd(8), it sounds to me like subuids could be
> > useful for system users on a system where tasks get started in a userns
> > by boot scripts using a system userid.
> =

> I believe the question was.  If /etc/subuid does not exist and we add a
> new user do we want to add an entry in /etc/subuid.  Similarly for
> /etc/subgid.
> =

> I followed convention in shadow and figured that if /etc/subuid and
> /etc/subgid are not present we don't want to add subuids and subgids.
> =

> I don't expect we want to add subuids and subgids for system users by
> default but as Serge says there may be instances where we want to add
> them manually.

OK. That would change useradd (disabling setting sub*id when rflg is set).
We could add options to useradd to change this default, or just let the
user use usermod.

> >> 11]=A0Ranges will be defined for new users. Do you think there would b=
e a
> >>     need for another tool to initialize a system for this feature?
> >>     (similar to pwconv)
> >
> > Do you mean to add ranges for existing users?
> =

> I believe it was either useradd or usermod that I modified so that I
> could add subuids and subgids for an existing user manually.
> =

> As for upgrades I don't know.  Serge with your distro hat on do you see
> a use for automatically giving user on a system subids and subgids when
> they upgrade versions of shadow?
> =

> >> 12]=A0There could be additions in pwck:
> >>      * check that users in /etc/sub*id exist
> >>      * check overlaps?
> >
> > Overlaps may actually be a feature in some cases, as a way to allow
> > users to share data.
> =

> I know I deliberately allowed (but would never create by default)
> multiple users having access to the same range of subordinate uids.
> =

> Shared read-only system images may benefit from such a practice.
> =

> In a similar vein there may be uses of being able to log in to a system
> with what is ordinarily a subordinate uid.
> =

> The distinction is a distinction of use not a distinction made in the
> kernel.
> =

> That said having overlaps is usually a mistake and a warning in the
> manual process may be called for in case someone simply didn't see
> something.

OK.

> >>      * check overlaps with UIDs?
> >>      * ...
> >> =

> >> I do not think that they are blocking points. (i.e. there could be a
> >> release without a solution)
> >
> > I'll wait for comments or ("no time for a comment") on any of these
> > from Eric, then look at addressing those that I can.
> =

> I hope that helps put some context to things.  I am totally not looking
> at the userspace issues around newuidmap and newgidmap right now, and I
> appreciate others being able to look at it and make things better.

Thanks for your feedback.

-- =

Nekral
