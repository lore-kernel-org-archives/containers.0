From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9][cr][v2]: Restore file_owner info
Date: Wed, 28 Jul 2010 15:20:32 -0700
Message-ID: <20100728222032.GB5657__31662.7986533151$1280355747$gmane$org@count0.beaverton.ibm.com>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-5-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C16FC14.1090001@cs.columbia.edu>
	<20100728192503.GA14570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100728192503.GA14570-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 28, 2010 at 12:25:03PM -0700, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | > +
> | > +	rcu_read_lock();
> | > +	pid = find_vpid(h->f_owner_pid);
> | 
> | What if this fails - the pid is invalid/non-existent ?
> 
> Good point. ->f_owner_pid can be 0 (in the normal case) and __fsetown()
> below will set the owner to NULL pid. But if ->f_owner_pid is non-zero,
> we should ensure we found a valid pid - added a check for this.
> 
> | 
> | > +	/*
> | > +	 * TODO: Do we need to force==1 or can it be 0 ? 'force' is used to
> | > +	 * 	 modify the owner, if one is already set. Can it be set when
> | > +	 * 	 we restart an application ?
> | > +	 */
> | > +	ret = __f_setown(file, pid, h->f_owner_pid_type, uid, euid, 1);
> | > +	rcu_read_unlock();
> | 
> | I wonder if this would be a problem in terms of security on a
> | non-container restart (e.g. not in a new pid-ns): one could set
> | any pid as owner and any signal to be sent, and cause an arbitrary
> | signal to be sent to an arbitrary process ?
> 
> Yes, Matt and Serge pointed it out and for now we need CAP_KILL
> capability to restore an application that has file-leases.

I looked at this some.

The pid and the signal are looked up when the signal is generated. Then
permissions are checked. See sigio_perm() called from send_sigio_to_task().

Thus I think the main thing we need to be certain of are the uid and euid
to pass in to own the file. Those are going to require some userns bits
I think. Then the signal number and recipient will be checked as normal
-- we don't need to do anything special during restart.

For reference, here's sigio_perm():

static inline int sigio_perm(struct task_struct *p,
                             struct fown_struct *fown, int sig)
{ 
        const struct cred *cred;
        int ret;

        rcu_read_lock();
        cred = __task_cred(p);
        ret = ((fown->euid == 0 ||
                fown->euid == cred->suid || fown->euid == cred->uid ||
                fown->uid  == cred->suid || fown->uid  == cred->uid) &&
               !security_file_send_sigiotask(p, fown, sig));
        rcu_read_unlock();
        return ret;
}

[ My Notes: unlike check_kill_permission() it does not check CAP_KILL.
Also check_kill_permission() calls audit as if the signal is about to be
delivered but sigio_perm() does not. ]

Cheers,
	-Matt Helsley
