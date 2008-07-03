From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 06/11] sysfs: Implement sysfs tagged directory support.
Date: Thu, 03 Jul 2008 12:56:17 +0200
Message-ID: <486CB051.5000507@fr.ibm.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.002784342@theryb.frec.bull.fr>
	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1hcb7o8lv.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> =

>> There is rather large possibility that I'm just being dumb here
>> especially because I haven't reviewed the users of this facility, so all
>> the comments I'm making are from the POV of interfaces of sysfs and the
>> related layers.  I think I've made my concerns clear by now.  If you
>> still think the callbacks are the best way to go, please try to
>> enlighten me.  I really don't wanna be stopping something which is
>> better from ignorance.  Just give me some concrete examples or point me
>> to codes which show how and why the current interface is the best for
>> the users and switching isn't a good idea.
> =

> Currently I think a callback on to get the tag from a kobject is the
> best way to go.  That way we don't need to add a field to struct
> kobject (and don't need the associated redundancy), and we can lookup
> up the tag when we need it.

The kobject events are sent through a netlink message which is not =

currently per network namespace. Shouldn't be useful to have a way to =

retrieve from the kobject the network namespace or the uevent socket =

associated with it ? IMHO having idr in the kobject + netns pointer =

associated may help to handle the sysfs isolation and makes the uevent =

per namespace trivial, no ?

> I have been playing with the code and just about have it ready
> to go.  I just need to refactor all of my changes into clean
> patches at this point, plus a bit of review and test.  Ben & Daniel
> have given me a version of the previous patchset rebased unto the
> latest -mm so that should help for the unchanged parts.
> =

> Introducing the sysfs_tag_type thing and pushing the functions to
> the edges helps.  It especially cleans up the ugly mount/umount
> situation allowing us to handle that with generic code.
> =

> Moving the kobject_tag into struct ktype works and looks roughly
> as clean as what happens with attributes.  So I that seems reasonable,
> and doesn't result in a significant change in the users.
> =

> The result of which means that I only have the helper function sysfs_crea=
tion_tag
> left in sysfs/dir.c  Left in there are some of the nasties in dealing wit=
h symlinks.
> =

> At this point I believe I have achieved a nice degree of simplifying the =
sysfs
> code in the current patches without really changing the users or
> making it more complex for them.
> =

> I have not implemented ida tags, and I don't plan to.  That is just
> unnecessary work right now.  The users are simple and the meat of the
> logic would not change so it should be simple to add.
> =

>>> It looks to me like the clean solution is move kobject_tag into
>>> kobj_type, and have it call some higher level function.
>>>
>>> We also need to remove the maintenance disaster that is
>>> kobject_set_name from sysfs_rename_dir.  And push it into
>>> kobject_rename instead.  The error handling is harder in
>>> that case but otherwise we should be in good shape.
>> Heh... I personally think kobject layer as a whole should just be hidden
>> under the cabinet of device driver model but I'm having difficult time
>> convincing other people of it.  Anyways, fully agree the interaction
>> between kobject and sysfs is ugly at a lot of places.
> =

> I would be happy if we could remove all nonsense kobject that are there j=
ust
> for structural purposes but have no purpose otherwise.  Things like kobje=
cts
> for symlinks.  The kobject layer doesn't seem to have a clear identity
> and purpose that I can see right now.
> =

>> Thanks a lot for your patience.
> =

> Welcome.  The code reached a point a while ago where it didn't make sense
> to change it without review feedback.
> =

> Eric
> =

> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> =



-- =























































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92400
Courbevoie
RCS Nanterre 552 118 465
Forme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
