From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9] allow killing tasks in your own or child userns
Date: Thu, 24 Feb 2011 00:48:18 +0000
Message-ID: <20110224004818.GA11822__30766.9601440013$1298508748$gmane$org@mail.hallyn.com>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150325.GD26395@mail.hallyn.com>
	<20110218155921.440f1137.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110218155921.440f1137.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Thu, 17 Feb 2011 15:03:25 +0000
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> >  /*
> > + * called with RCU read lock from check_kill_permission()
> > + */
> > +static inline int kill_ok_by_cred(struct task_struct *t)
> > +{
> > +	const struct cred *cred = current_cred();
> > +	const struct cred *tcred = __task_cred(t);
> > +
> > +	if (cred->user->user_ns == tcred->user->user_ns &&
> > +	    (cred->euid == tcred->suid ||
> > +	     cred->euid == tcred->uid ||
> > +	     cred->uid  == tcred->suid ||
> > +	     cred->uid  == tcred->uid))
> > +		return 1;
> > +
> > +	if (ns_capable(tcred->user->user_ns, CAP_KILL))
> > +		return 1;
> > +
> > +	return 0;
> > +}
> 
> The compiler will inline this for us.

Is that simply true with everything (worth inlining) nowadays, or is
there a particular implicit hint to the compiler that'll make that
happen?

Not that I guess it's even particularly important in this case.

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Thu, 24 Feb 2011 00:26:02 +0000
Subject: [PATCH 1/2] userns: let compiler inline kill_ok_by_cred (per akpm)

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 kernel/signal.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index ffe4bdf..12702b4 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -638,7 +638,7 @@ static inline bool si_fromuser(const struct siginfo *info)
 /*
  * called with RCU read lock from check_kill_permission()
  */
-static inline int kill_ok_by_cred(struct task_struct *t)
+static int kill_ok_by_cred(struct task_struct *t)
 {
 	const struct cred *cred = current_cred();
 	const struct cred *tcred = __task_cred(t);
-- 
1.7.0.4
