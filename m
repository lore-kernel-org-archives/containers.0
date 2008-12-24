From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/7][v4] SI_USER: Masquerade si_pid when crossing
	pid ns boundary
Date: Wed, 24 Dec 2008 13:08:55 -0800
Message-ID: <20081224210855.GB13502@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115301.GF8020@us.ibm.com> <20081224154310.GA11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751948AbYLXVKj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224154310.GA11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 12/24, Sukadev Bhattiprolu wrote:
| >
| > +static void masquerade_si_pid(struct task_struct *t, siginfo_t *info)
| > +{
| > +	if (is_si_special(info) || SI_FROMKERNEL(info))
| > +		return;

Grr, This needs to go. I started with a general function but then
got specific to SI_USER.

| > +
| > +	/*
| > +	 * When crossing pid namespace boundary, SI_USER signal can only
| > +	 * go from ancestor to descendant ns but not the other way. So,
| > +	 * just ->si_pid to 0 since, the sender will not have a pid in
| > +	 * the receiver's namespace.
| > +	 */
| > +	if (info->si_code == SI_USER)
| > +		info->si_pid = 0;
| > +}
| > +
| >  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
| >  			int group)
| >  {
| > @@ -946,6 +974,8 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
| >  			break;
| >  		default:
| >  			copy_siginfo(&q->info, info);
| > +			if (from_ancestor_ns)
| > +				masquerade_si_pid(t, &q->info);
| >  			break;
| >  		}
| >  	} else if (!is_si_special(info)) {
| > @@ -2343,7 +2373,7 @@ sys_kill(pid_t pid, int sig)
| >  	info.si_signo = sig;
| >  	info.si_errno = 0;
| >  	info.si_code = SI_USER;
| > -	info.si_pid = task_tgid_vnr(current);
| > +	info.si_pid = 0;	/* masquerade in send_signal() */
| >  	info.si_uid = current_uid();

Yes, I will undo this...

| 
| Can't understand this patch. First of all, it looks wrong. Looks like
| we never set .si_pid != 0 when the signal is set by sys_kill() ?
| 
| But more importantly, unless I missed something, this patch is unnecessary
| complication.
| 
| We call masquerade_si_pid() only when from_ancestor_ns == T, this is correct.
| But this means that (!is_si_special(info) && SI_FROMUSER(info)) == T, why
| do we re-check in masquerade_si_pid() ?
| 
| And why can't we just do
| 
| 	 default:
| 	 	copy_siginfo(&q->info, info);
| 	 	if (from_ancestor_ns)
| 	 		info->si_pid = 0;

and go with this.

| 
| ? Why should we check SI_USER and change sys_kill() ?
| 
| see also the comment for the next 7/7 patch.
| 
| Oleg.
