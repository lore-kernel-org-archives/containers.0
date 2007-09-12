From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: netns45
Date: Wed, 12 Sep 2007 18:57:26 +0200
Message-ID: <46E81A76.3040103@fr.ibm.com>
References: <m11wefgfl0.fsf@ebiederm.dsl.xmission.com>
	<m1wsw7f0r0.fsf@ebiederm.dsl.xmission.com>
	<m1wsuv96f8.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1wsuv96f8.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Ok just to keep everyone in sync.
>=20
> I just uploaded a version of my netns tree up to kernel.org rebased
> on top of what David Miller has just merged.
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.=
git#netns/v2.6.23-rc5netns45
>=20
> Once things have settled down a bit I will figure out what needs to be
> sent next.
>=20
> I will probably concentrate on my miscellaneous bug fixes and the
> sysfs work.
>=20
> Daniel if you guys have any bug fixes for me I will be happy to apply
> them, so the don't get forgotten.

Thanks Eric for the update.

We checked with Benjamin all the fixes, a few are missing. Some of them=20
are already sent and merged to net-2.6.24. We will port the missing ones=20
to netns45 and send them to you asap.

Regards=CB=99
	-- Daniel
