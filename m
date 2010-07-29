From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9][cr][v2]: Restore file_owner info
Date: Thu, 29 Jul 2010 14:00:59 -0500
Message-ID: <20100729190059.GA12891__29067.1210540042$1280430289$gmane$org@hallyn.com>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-5-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C16FC14.1090001@cs.columbia.edu>
	<20100728192503.GA14570@us.ibm.com>
	<20100728222032.GB5657@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100728222032.GB5657-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> For reference, here's sigio_perm():
> 
> static inline int sigio_perm(struct task_struct *p,
>                              struct fown_struct *fown, int sig)
> { 
>         const struct cred *cred;
>         int ret;
> 
>         rcu_read_lock();
>         cred = __task_cred(p);
>         ret = ((fown->euid == 0 ||
>                 fown->euid == cred->suid || fown->euid == cred->uid ||
>                 fown->uid  == cred->suid || fown->uid  == cred->uid) &&
>                !security_file_send_sigiotask(p, fown, sig));
>         rcu_read_unlock();
>         return ret;
> }
> 
> [ My Notes: unlike check_kill_permission() it does not check CAP_KILL.

Right, that's bc we don't store capabilities in the fown_struct.
So fown->euid==0 is all we can do.  Since this can be called from
interrupt, current is not useful.

> Also check_kill_permission() calls audit as if the signal is about to be
> delivered but sigio_perm() does not. ]

-serge
