From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC PATCH 3/4] Container Freezer: Implement freezer cgroup
	subsystem
Date: Fri, 11 Apr 2008 13:49:47 +0200
Message-ID: <20080411114947.GD1740__46375.1109586612$1207914723$gmane$org@elf.ucw.cz>
References: <20080403210316.397506379@us.ibm.com>
	<20080403210317.160210906@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080403210317.160210906-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi!

> This patch implements a new freezer subsystem for Paul Menage's 
> control groups framework. It provides a way to stop and resume 
> execution of all tasks in a cgroup by writing in the cgroup 
> filesystem.
> 
> This is the basic mechanism which should do the right thing for 
> user space tasks in a simple scenario. This will require more work 
> to get the freezing right (cf. try_to_freeze_tasks()) for ptraced
> tasks.

> --- /dev/null
> +++ linux-2.6.25-rc8-mm1/include/linux/cgroup_freezer.h
> @@ -0,0 +1,57 @@
> +#ifndef _LINUX_CGROUP_FREEZER_H
> +#define _LINUX_CGROUP_FREEZER_H
> +/*
> + * cgroup_freezer.h -  control group freezer subsystem interface
> + *
> + * Copyright IBM Corp. 2007
> + *
> + * Author : Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> + */

If you have copyright, add GPL.

> --- /dev/null
> +++ linux-2.6.25-rc8-mm1/kernel/cgroup_freezer.c
> @@ -0,0 +1,280 @@
> +/*
> + * cgroup_freezer.c -  control group freezer subsystem
> + *
> + * Copyright IBM Corp. 2007
> + *
> + * Author : Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> + */

Same here.

>+static struct cgroup_subsys_state *freezer_create(
>+       struct cgroup_subsys *ss, struct cgroup *cgroup)
>+{

Function headers are somehow non-traditional.

+       struct freezer *freezer;
+
+       if (!capable(CAP_SYS_ADMIN))
+               return ERR_PTR(-EPERM);
+
+       freezer = kzalloc(sizeof(struct freezer), GFP_KERNEL);
+       if (!freezer)
+               return ERR_PTR(-ENOMEM);
+
+       spin_lock_init(&freezer->lock);
+       freezer->state = STATE_RUNNING;
+       return  &freezer->css;
+}

One space too many after "return" :-).

Hmm, returning pointer inside struct freezer is rather ugly, right?
Could you just pass struct freezer around?
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
