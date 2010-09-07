From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup : add clone_children control file
Date: Tue, 7 Sep 2010 12:34:07 -0700
Message-ID: <AANLkTi=hM66-F-U2-ZoiDgksh51hq3MLb5aSLmwsShwi@mail.gmail.com>
References: <1283585466-30265-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1283585466-30265-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Sep 4, 2010 at 12:31 AM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wr=
ote:
> @@ -229,6 +229,7 @@ inline int cgroup_is_removed(const struct cgroup *cgr=
p)
> =A0/* bits in struct cgroupfs_root flags field */
> =A0enum {
> =A0 =A0 =A0 =A0ROOT_NOPREFIX, /* mounted subsystems have no named prefix =
*/
> + =A0 =A0 =A0 ROOT_CLONE_CHILDREN, /* mounted subsystems will inherit fro=
m parent */
> =A0};

This bit is awkward - you're storing the original value of the
clone_children flag to report in the mount options, but this isn't
necessarily the current state. Might it be better to not store this
and just report the current value of the root cgroup's
CGRP_CLONE_CHILDREN flag?

Paul
