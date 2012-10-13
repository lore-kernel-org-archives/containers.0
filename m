From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: uevent when moving nic between network namespaces?
Date: Sat, 13 Oct 2012 00:17:22 -0500
Message-ID: <20121013051722.GA13589@sergelap>
References: <20121012031328.GA5472@sergelap> <871uh4pdzd.fsf@xmission.com>
	<20121012191828.GA12200@sergelap> <87sj9jmqew.fsf@xmission.com>
	<20121012215650.GA22665@sergelap> <87bog7mjhm.fsf@xmission.com>
	<20121012221711.GA23227@sergelap> <87626fmihz.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87626fmihz.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Dan Kegel <dank-XdDNpL9cdsoAvxtiuMwx3w@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> =

> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> >> =

> >> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> >> I am not currently working on a patch for this, but I will be happy=
 to
> >> >> review one. At a quick glance it looks like this could just be as
> >> >> simple as calling kobject_uevent at the proper time, but testing and
> >> >> reading through the relevant code paths is probably a good idea as =
there
> >> >> always seems to be gotchas in that code.
> >> >> =

> >> >> Eric
> >> >
> >> > This (the simple fix) works for me, actually.
> >> >
> >> > I do notice the ifdef shouldn't be needed, all the better.
> >> =

> >> Should we have a KOBJ_ADD in the new network namespace or is the
> >> KOBJ_MOVE sufficient?
> >
> > I was wondering about that...  the KOBJ_ADD is technically not sufficie=
nt
> > imo, since a MOVE (for a device which udev/upstart has never seen befor=
e)
> > doesn't necessarily mean "configure this."  So when I pass one end of a
> > veth into a running ubuntu container, there is no network-interface or
> > network-interface-security upstart job for it, whereas if I do a
> > ip link add type veth inside the container, those do get the jobs.
> >
> > Now, ISTM passing an endpoing into a container is mainly done at
> > startup, and upstart will end up configuring it anyway.  Nothing is
> > really breaking in any of the container usages I've seen because of thi=
s.
> > But it would definately be cleaner to pass a KOBJ_ADD before the KOBJ_M=
OVE.
> > Otherwise, udev has to guess what the MOVE meant.
> >
> > If there's no objection, I'll add that (and test it) and send to netdev
> > on monday.
> =

> Sounds good.  Right now I have the suspicion we might want our own
> variant on sysfs_move that sends these instead of the move...
> =

> But let's confirm things work better with add/remove before we go crazy
> on the best way to generate maintainable code.

Yup all still looks good with the following trivial patch.  And now when
I pass a netdev into a running container, it gets a network-interface
upstart job just as it does on a real host.

And no network-interface jobs stick around after the container shuts
down, meaning this solves the kernel part of bug 1065589
(https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1065589).

(Pre-existing nics don't get a network-interface job - the fact that lxc
first passes in the netdevs and then execs init therefore still causes
some asymmetry wrt a real host, where netdevs always come up after init
starts.  AFAIK we don't care, but St=E9phane might know of a reason why we
do  - in either case it's not the kernel's problem)

From 01dc08273fa63a50f6dbb7377397ec52a7a337f8 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Fri, 12 Oct 2012 21:42:05 +0100
Subject: [PATCH 1/1] dev_change_net_namespace: send a KOBJ_REMOVED to
 original netns

v2: also send KOBJ_ADD to new netns.  There will then be a
_MOVE event from the device_rename() call, but that should
be innocuous.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/core/dev.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index e2215ee..2c43aaf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6172,6 +6172,9 @@ int dev_change_net_namespace(struct net_device *dev, =
struct net *net, const char
 	dev_uc_flush(dev);
 	dev_mc_flush(dev);
 =

+	/* Send a netdev-removed uevent to the old namespace */
+	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 =

@@ -6183,6 +6186,9 @@ int dev_change_net_namespace(struct net_device *dev, =
struct net *net, const char
 			dev->iflink =3D dev->ifindex;
 	}
 =

+	/* Send a netdev-add uevent to the new namespace */
+	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+
 	/* Fixup kobjects */
 	err =3D device_rename(&dev->dev, dev->name);
 	WARN_ON(err);
-- =

1.7.10.4
