From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: netns45
Date: Wed, 12 Sep 2007 10:47:55 -0600
Message-ID: <m1wsuv96f8.fsf_-_@ebiederm.dsl.xmission.com>
References: <m11wefgfl0.fsf@ebiederm.dsl.xmission.com>
	<m1wsw7f0r0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1wsw7f0r0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric W. Biederman's
	message of "Tue, 07 Aug 2007 16:17:23 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org


Ok just to keep everyone in sync.

I just uploaded a version of my netns tree up to kernel.org rebased
on top of what David Miller has just merged.

git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git#netns/v2.6.23-rc5netns45

Once things have settled down a bit I will figure out what needs to be
sent next.

I will probably concentrate on my miscellaneous bug fixes and the
sysfs work.

Daniel if you guys have any bug fixes for me I will be happy to apply
them, so the don't get forgotten.

Eric
