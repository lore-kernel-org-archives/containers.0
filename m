From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] devcgroup: avoid using cgroup_lock
Date: Fri, 13 Mar 2009 14:57:13 -0500
Message-ID: <20090313195712.GA18439__27877.8205429719$1236974421$gmane$org@us.ibm.com>
References: <49B869BB.7030907@cn.fujitsu.com>
	<20090312181912.GA20144@us.ibm.com>
	<49B9BCC7.7090908@cn.fujitsu.com>
	<20090313134139.GB32304@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090313134139.GB32304-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> > >> @@ -426,11 +431,11 @@ static int devcgroup_access_write(struct cgroup *cgrp, struct cftype *cft,
> > >>  				  const char *buffer)
> > >>  {
> > >>  	int retval;
> > >> -	if (!cgroup_lock_live_group(cgrp))
> > > 
> > > Does it matter that we no longer check for cgroup_is_removed()?
> > > 
> > 
> > No, this means in a rare case that the write handler is called when the cgroup
> > is dead, we still do the update work instead of returning ENODEV.
> > 
> > This is ok, since at that time, accessing cgroup and devcgroup is still valid,
> > but will have no effect since there is no task in this cgroup and the cgroup
> > will be destroyed soon.
> 
> Ok, just wanted to make sure the devcgroup couldn't be partially torn
> down and risking NULL or freed-memory derefs...

Ok, so the cgroup's files will be deleted first, then on the directory
removal the cgroup's data (each whitelist entry) is deleted.  So we can
let that ordering (by cgroup_clear_directory) ensure that nothing inside
a file write can happen while the destroy handler is called, right?

(That's why I was worried about not using the cgroup_lock: we need some
way of synchronizing those.  But I guess we're fine)

> BTW is that against linux-next?  (didn't seem to apply cleanly against
> my 2.6.29-rc9)  I guess I'd like to do a little test before acking,
> though it looks ok based on your answer.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-serge
