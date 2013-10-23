From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Wed, 23 Oct 2013 00:41:30 +0000
Message-ID: <20131023004130.GA12788@mail.hallyn.com>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org> <20130723183841.GA9021@tp>
	<CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> On Tue, Jul 23, 2013 at 2:38 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> > This doesn't delegate it into the container.  It allows me, on the host,
> > to set the cgroup for a container.
> 
> Hmmm? I'm a bit confused. Isn't the description saying that the patch
> allows pseudo-root in userns to change cgroup membership even if it
> isn't actually root?
> 
> Besides, I find the whole check rather bogus and would actually much
> prefer just nuking the check and just follow the standard permission
> checks.

Can we please nuke it like this then?

From b840083ec8fa1f0645ae925c79db3dc51edd019c Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 23 Oct 2013 01:34:00 +0200
Subject: [PATCH 1/1] device_cgroup: remove can_attach

It is really only wanting to duplicate a check which is already done by the
cgroup subsystem.

With this patch, user jdoe still cannot move pid 1 into a devices cgroup
he owns, but now he can move his own other tasks into devices cgroups.

Signed-off-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 security/device_cgroup.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index efc6f68..a37c054 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -64,16 +64,6 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 
 struct cgroup_subsys devices_subsys;
 
-static int devcgroup_can_attach(struct cgroup_subsys_state *new_css,
-				struct cgroup_taskset *set)
-{
-	struct task_struct *task = cgroup_taskset_first(set);
-
-	if (current != task && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
-	return 0;
-}
-
 /*
  * called under devcgroup_mutex
  */
@@ -698,7 +688,6 @@ static struct cftype dev_cgroup_files[] = {
 
 struct cgroup_subsys devices_subsys = {
 	.name = "devices",
-	.can_attach = devcgroup_can_attach,
 	.css_alloc = devcgroup_css_alloc,
 	.css_free = devcgroup_css_free,
 	.css_online = devcgroup_online,
-- 
1.8.3.2
