From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 7/7][v4] SI_TKILL: Masquerade si_pid when crossing
	pid ns boundary
Date: Wed, 24 Dec 2008 13:04:04 -0800
Message-ID: <20081224210404.GA13502@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115331.GG8020@us.ibm.com> <20081224155529.GB11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751897AbYLXVFt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224155529.GB11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 12/24, Sukadev Bhattiprolu wrote:
| >
| > --- a/kernel/signal.c
| > +++ b/kernel/signal.c
| > @@ -2385,17 +2385,22 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
| >  	struct siginfo info;
| >  	struct task_struct *p;
| >  	unsigned long flags;
| > +	struct pid_namespace *ns;
| >
| >  	error = -ESRCH;
| >  	info.si_signo = sig;
| >  	info.si_errno = 0;
| >  	info.si_code = SI_TKILL;
| > -	info.si_pid = task_tgid_vnr(current);
| >  	info.si_uid = current_uid();
| >
| >  	rcu_read_lock();
| >  	p = find_task_by_vpid(pid);
| >  	if (p && (tgid <= 0 || task_tgid_vnr(p) == tgid)) {
| > +		ns = task_active_pid_ns(p);
| > +		if (ns)
| > +			info.si_pid = task_tgid_nr_ns(current, ns);
| > +		else
| > +			info.si_pid = task_tgid_vnr(current);
| 
| if ns == 0, "p" won't see the signal anyway, so all we need is

Yes, p won't see the signal, but task_tgid_nr_ns() is not safe if ns == NULL.
We should either check ns or make task_tgid_nr_ns() and friends safe with
ns == NULL ?

| 
| 	-	info.si_pid = task_tgid_vnr(current);
| 	+	info.si_pid = task_tgid_nr_ns(current, task_active_ns(p));
| 
| like we do in __do_notify().

Yes, I had a question about ns == 0 in this patch and was wondering if I
should add a check in __do_notify() too.

| 
| 
| But. this of course doesn't work for sys_kill(). Can't we change the helpers
| which send SI_FROMUSER() signals so that they do not fill .si_pid at all?

SI_FROMUSER() basically comes down to SI_USER and SI_TKILL (SI_QUEUE,
SI_SIGIO, SI_DETHREAD are unused ?)  SI_USER has to be masqueraded in
send_signal(). That leaves us with SI_TKILL. 

I was trying to have all si_pid settings done at origin and so the change
here for SI_TKILL. But yes, SI_USER (sys_kill() case) can't be done at
origin hence the special case for it in send_signal().

| Then send_signal() can do:
| 
| 	default:
| 		copy_siginfo(&q->info, info);
| 		info.si_pid = 0;
| 		if (!from_ancestot_ns)
| 			info.si_pid = task_tgid_nr_ns(current, ...);
| 
| ?


My preference was to address SI_TKILL also at origin, but am not
particular.  Yes, that will work too.


| 
| Yes, we use "current". But we already used it in siginfo_from_ancestor_ns().
| 
| Oleg.
| 
| --
| To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
| the body of a message to majordomo@vger.kernel.org
| More majordomo info at  http://vger.kernel.org/majordomo-info.html
| Please read the FAQ at  http://www.tux.org/lkml/
