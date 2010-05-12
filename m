From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4][cr]: Define __f_setown_uid()
Date: Wed, 12 May 2010 09:59:22 -0700
Message-ID: <20100512165922.GA11144@us.ibm.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100512080629.GB2636@us.ibm.com>
	<20100512084317.GA8842@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100512084317.GA8842-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > 
| > [From patch 2]
| > 
| > > @@ -222,9 +222,16 @@ int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
| > >  	if (err)
| > >  		return err;
| > > 
| > > -	f_modown(filp, pid, type, current_uid(), current_euid(), force);
| > > +	f_modown(filp, pid, type, uid, euid, force);
| > >  	return 0;
| > >  }
| > > +
| > > +int __f_setown(struct file *filp, struct pid *pid, enum pid_type type,
| > > +		int force)
| > > +{
| > > +	return __f_setown_uid(filp, pid, type, current_uid(), current_euid(),
| > > +			force);
| > > +}
| > >  EXPORT_SYMBOL(__f_setown);
| > 
| > [From patch 4]
| > 
| > > +	/*
| > > +	 * TODO: Do we need to force==1 or can it be 0 ? 'force' is used to
| > > +	 * 	 modify the owner, if one is already set. Can it be set when
| > > +	 * 	 we restart an application ?
| > > +	 */
| > > +	ret = __f_setown_uid(file, pid, h->f_owner_pid_type, h->f_owner_uid,
| > > +			h->f_owner_euid, 1);
| > > +	rcu_read_unlock();
| > 
| > I think you need to modify how __f_setown() is calling
| > security_file_set_fowner().  Though I guess noone looks at the
| > current_uid(), so maybe it's not so important at this point.
| > 
| > (I do wonder whether converting fowner to using a struct cred
| > is the way to go)
| 
| Well you can probably skip LSM implications at this point.
| 
| But I'm worried about the fact that you do no check on uid here.
| Note that now if a signal is to be sent, fown->pid will
| get signal fow->signum sent by fown->uid.  So this looks like
| a way for an unprivileged task to use root privs to kill a
| task he shouldn't be able to.

Yes, the uid should not be trusted since the checkpoint image can be
tampered.  Matt pointed it out too.

The process P1 that called fcntl(F_SETOWN) may have exited and hence
may not in the checkpoint-image. So during restart, some other process
will need to act for P1. Would requiring CAP_SETUID, like we do for
restoring creds be an overkill ?
