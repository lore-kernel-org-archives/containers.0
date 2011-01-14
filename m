From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 05/08] Allow ptrace from non-init user namespaces
Date: Fri, 14 Jan 2011 16:00:55 +0100
Message-ID: <20110114150055.GA22496__15135.9328105629$1295017424$gmane$org@wavehammer.waldi.eu.org>
References: <20110111064342.GA27515@mail.hallyn.com>
	<20110111064439.GF27515@mail.hallyn.com>
	<20110114144608.GA20945@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110114144608.GA20945-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TaqPxH82wqD4g@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 14, 2011 at 03:46:09PM +0100, Bastian Blank wrote:
> On Tue, Jan 11, 2011 at 06:44:39AM +0000, Serge E. Hallyn wrote:
> > diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> > index 99bbaa3..ec7605d 100644
> > --- a/kernel/ptrace.c
> > +++ b/kernel/ptrace.c
> > @@ -134,21 +134,24 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
> >  		return 0;
> >  	rcu_read_lock();
> >  	tcred = __task_cred(task);
> > -	if ((cred->uid != tcred->euid ||
> > -	     cred->uid != tcred->suid ||
> > -	     cred->uid != tcred->uid  ||
> > -	     cred->gid != tcred->egid ||
> > -	     cred->gid != tcred->sgid ||
> > -	     cred->gid != tcred->gid) &&
> > -	    !capable(CAP_SYS_PTRACE)) {
> > -		rcu_read_unlock();
> > -		return -EPERM;
> > -	}
> > +	if (cred->user->user_ns == tcred->user->user_ns &&
> > +	    (cred->uid == tcred->euid &&
> > +	     cred->uid == tcred->suid &&
> > +	     cred->uid == tcred->uid  &&
> > +	     cred->gid == tcred->egid &&
> > +	     cred->gid == tcred->sgid &&
> > +	     cred->gid == tcred->gid))
> > +		goto ok;
> > +	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
> > +		goto ok;
> > +	rcu_read_unlock();
> > +	return -EPERM;
> > +ok:
> 
> This is wrong.

Whoops, it _is_ right. However the nested parenthes is unnecessary and
can lead to other conclusions.

Bastian

-- 
Lots of people drink from the wrong bottle sometimes.
		-- Edith Keeler, "The City on the Edge of Forever",
		   stardate unknown
