From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: uevent when moving nic between network namespaces?
Date: Fri, 12 Oct 2012 16:56:50 -0500
Message-ID: <20121012215650.GA22665@sergelap>
References: <20121012031328.GA5472@sergelap> <871uh4pdzd.fsf@xmission.com>
	<20121012191828.GA12200@sergelap> <87sj9jmqew.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87sj9jmqew.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
> I am not currently working on a patch for this, but I will be happy to
> review one. At a quick glance it looks like this could just be as
> simple as calling kobject_uevent at the proper time, but testing and
> reading through the relevant code paths is probably a good idea as there
> always seems to be gotchas in that code.
> 
> Eric

This (the simple fix) works for me, actually.

I do notice the ifdef shouldn't be needed, all the better.

From b436802aa8ae80f699b3d7bcf584d3e86af7355a Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Fri, 12 Oct 2012 21:42:05 +0100
Subject: [PATCH 1/1] dev_change_net_namespace: send a KOBJ_REMOVED to
 original netns

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/core/dev.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index e2215ee..8062a5a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6172,6 +6172,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_uc_flush(dev);
 	dev_mc_flush(dev);
 
+	/* Send a netdev-removed uevent to the old namespace */
+#ifdef CONFIG_HOTPLUG
+	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+#endif
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
-- 
1.7.9.5
