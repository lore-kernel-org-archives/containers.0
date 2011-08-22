From: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] cgroups: update documentation on task moving restriction
Date: Sun, 21 Aug 2011 21:15:25 -0700
Message-ID: <20110821211525.26e793c9.rdunlap__1802.47845496542$1313986594$gmane$org@xenotime.net>
References: <4E4C7E16.9090905@cn.fujitsu.com>
	<CALdu-PC5_J2-Ss6se8LnoWDf5Ltt3Y9__RXKyTZUXvgBmv60Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALdu-PC5_J2-Ss6se8LnoWDf5Ltt3Y9__RXKyTZUXvgBmv60Tg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 18 Aug 2011 00:44:35 -0700 Paul Menage wrote:

> On Wed, Aug 17, 2011 at 7:51 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> > - ns cgroup has been removed.
> > - it's true moving a task to another cgroup can fail.
> >
> > Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> =

> Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>

Applied, thanks.


> > ---
> > =A0Documentation/cgroups/cgroups.txt | =A0 =A04 ++--
> > =A01 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/=
cgroups.txt
> > index cd67e90..9c452ef 100644
> > --- a/Documentation/cgroups/cgroups.txt
> > +++ b/Documentation/cgroups/cgroups.txt
> > @@ -454,8 +454,8 @@ mounted hierarchy, to remove a task from its curren=
t cgroup you must
> > =A0move it into a new cgroup (possibly the root cgroup) by writing to t=
he
> > =A0new cgroup's tasks file.
> >
> > -Note: If the ns cgroup is active, moving a process to another cgroup c=
an
> > -fail.
> > +Note: Due to some restrictions enforced by some cgroup subsystems, mov=
ing
> > +a process to another cgroup can fail.
> >
> > =A02.3 Mounting hierarchies by name
> > =A0--------------------------------
> > --


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
