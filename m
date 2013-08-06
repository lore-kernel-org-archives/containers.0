From: Nicolas =?iso-8859-1?Q?Fran=E7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Wed, 7 Aug 2013 00:53:32 +0200
Message-ID: <20130806225332.GA14109@nekral.nekral.homelinux.net>
References: <87d2wxshu0.fsf@xmission.com>
	<20130728171451.GX5670@mykerinos.kheops.frmug.org>
	<87r4eilg6y.fsf@xmission.com>
	<11218395-363e-46cd-b7a1-4488079a4986@email.android.com>
	<20130806145403.GA20913@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130806145403.GA20913-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Tue, Aug 06, 2013 at 02:54:03PM +0000, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org wrote:
> =

> I rebased and pushed the patchset yesterday.

Thanks (this removes me the burden of finding how to merge a branch).

I started to review and read about user namespaces (thanks to Michael!)
o
Here are some questions/remarks:

 1] It would be nice to be able to disable the new tools / manpages /
    options on some systems (i.e. they only make sense on Linux, with
    recent Kernel). It would be OK for me if it is enabled by default.
    Do you agree?

 2] I think we can assume that UID/GIDs are (at least) 32 bits, right?
    (or at least when the feature is not disabled - see point 1)

 3] For PAM versions of shadow, I think it would be nice to authenticate
    the caller of newuidmap / newgidmap. Do you agree?

 4] What happens when newuidmap / newgidmap are used within a new namespace?
    Is there a risk to do something wrong by recursively creating shells in
    cascaded namespace and using these tools? (I don't think so)
    Is there a way to enforce that it would only be used in the top-most
    namespace? (Maybe it's not needed to forbid it)
    It would be worth to have at least a paragraph about it in the
    manpages. (i.e. IDs in /etc/sub*id are according to the caller's
    namespace)

 5] It would be worth documenting on which processes newuidmap / newgidmap
    can act.
    With newuidmap, an user can set the UID mapping for any process with
    restrictions on the process and on the requested ranges.
    We could also mention that the kernel enforce also restriction (5
    lines at most; can only be written once)

 5.1] The restriction on the caller or processes seems to be the followings:
    if ((getuid() !=3D pw->pw_uid) ||   // not needed (already enforced
                                      // by get_my_pwent()) - but does not
                                      // harm.
        (getgid() !=3D pw->pw_gid) ||   // I don't understand this
                                      // restriction. If I execute a
                                      // shell with another GID (e.g. using
                                      // newgrp) why should it be denied?
        (pw->pw_uid !=3D st.st_uid) ||
        (pw->pw_gid !=3D st.st_gid)) {  // Is it also needed? What would be
                                      // the problem

 6]=A0Documenting the APIs would be useful. Especially the ones in
    lib/subordinateio.c (after 5 minutes, I get lost with the
    is_range_free, range_exists, find_range, have_range, ...)

 7] I'm not sure about the handling of limits of ranges.
    * First, I'm not sure what is intended. (e.g. is SUB_GID_MAX included in
    the range)
    * In libmisc/find_new_sub_uids.c: Is it intended to forbid min =3D=3D m=
ax
      (I'm not claiming this is very useful, but if
      SUB_GID_MIN=3DSUB_GID_MAX and SUB_GID_COUNT is set to 1, this should
      be valid to set a single mapping for one UID)
    * In find_free_range(), min=3D=3Dmax is also forbidden.
    * In find_free_range(), the check (high > low) forbids to reuse a hole
      of just 1 UID starting at min
    ...

 8] Is there a need to check somewhere that that UID_MAX < SUB_UID_MIN in
    login.defs? Or is it valid to have overlaps?

 9]=A0Add manpage NOTE that newuidmap / newgidmap can be used only once on a
    given process?

10] useradd adds sub*id when the /etc/sub*id files are present, right?
    Is it also correct/intended for system users?
    I think there should be options to enable or disable the feature.
    (I would have chosen the first solution, but I can also understand
    that we consider that the presence of the files is a request to use
    the feature by default)

11]=A0Ranges will be defined for new users. Do you think there would be a
    need for another tool to initialize a system for this feature?
    (similar to pwconv)

12]=A0There could be additions in pwck:
     * check that users in /etc/sub*id exist
     * check overlaps?
     * check overlaps with UIDs?
     * ...

I do not think that they are blocking points. (i.e. there could be a
release without a solution)

Best Regards,
-- =

Nekral
