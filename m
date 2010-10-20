From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup debug seems dead?
Date: Tue, 19 Oct 2010 18:37:05 -0700
Message-ID: <20101019183705.04a11816@nehalam>
References: <20101019085139.1ccb22bc@nehalam> <4CBE41AE.2020101@cn.fujitsu.com>
	<20101019181245.7902113a@nehalam>
	<AANLkTinH2t41jvGG_D9qAdN5MvRHg7aR+J2mKV5ifMfC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinH2t41jvGG_D9qAdN5MvRHg7aR+J2mKV5ifMfC-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 19 Oct 2010 18:14:10 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, Oct 19, 2010 at 6:12 PM, Stephen Hemminger
> <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
> >
> > Where is it stored in an array?
> >
> > ~/kernel/linux-2.6$ git grep debug_subsys
> > kernel/cgroup.c: =A0 =A0 =A0 =A0kfree(cont->subsys[debug_subsys_id]);
> > kernel/cgroup.c:struct cgroup_subsys debug_subsys =3D {
> > kernel/cgroup.c: =A0 =A0 =A0 =A0.subsys_id =3D debug_subsys_id,
> =

> It's via the include of cgroup_subsys.h at the start of kernel/cgroup.c
> =

> Paul

That would work but doesn't because the following is missing
in cgroup_subsys.h!

#ifdef CONFIG_CGROUP_DEBUG
SUBSYS(debug)
#endif

/* */
