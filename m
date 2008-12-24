From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 7/7][v4] SI_TKILL: Masquerade si_pid when crossing
	pid ns boundary
Date: Wed, 24 Dec 2008 22:34:41 +0100
Message-ID: <20081224213441.GA2769@redhat.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115331.GG8020@us.ibm.com> <20081224155529.GB11593@redhat.com> <20081224210404.GA13502@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751897AbYLXVgp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224210404.GA13502@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 12/24, Sukadev Bhattiprolu wrote:
>
> Oleg Nesterov [oleg@redhat.com] wrote:
>
> | >  	if (p && (tgid <= 0 || task_tgid_vnr(p) == tgid)) {
> | > +		ns = task_active_pid_ns(p);
> | > +		if (ns)
> | > +			info.si_pid = task_tgid_nr_ns(current, ns);
> | > +		else
> | > +			info.si_pid = task_tgid_vnr(current);
> |
> | if ns == 0, "p" won't see the signal anyway, so all we need is
>
> Yes, p won't see the signal, but task_tgid_nr_ns() is not safe if ns == NULL.

Yes, I forgot that task_tgid_nr_ns() assumes ns != NULL.

> | like we do in __do_notify().
>
> Yes, I had a question about ns == 0 in this patch and was wondering if I
> should add a check in __do_notify() too.

I guess  __do_notify() is fine, ns_of_pid() can't be NULL.

> | But. this of course doesn't work for sys_kill(). Can't we change the helpers
> | which send SI_FROMUSER() signals so that they do not fill .si_pid at all?
>
> SI_FROMUSER() basically comes down to SI_USER and SI_TKILL (SI_QUEUE,
> SI_SIGIO, SI_DETHREAD are unused ?)

Yes, I was going to kill them many times but always forget.

> SI_USER has to be masqueraded in
> send_signal(). That leaves us with SI_TKILL.
>
> I was trying to have all si_pid settings done at origin and so the change
> here for SI_TKILL. But yes, SI_USER (sys_kill() case) can't be done at
> origin hence the special case for it in send_signal().
>
> | Then send_signal() can do:
> |
> | 	default:
> | 		copy_siginfo(&q->info, info);
> | 		info.si_pid = 0;
> | 		if (!from_ancestot_ns)
> | 			info.si_pid = task_tgid_nr_ns(current, ...);
> |
> | ?
>
> My preference was to address SI_TKILL also at origin, but am not
> particular.  Yes, that will work too.

... and the code becomes more clean and simple.

I really dislike the fact that sys_kill() relies on send_signal()
(this is correct), but do_tkill() and __do_notify() play with pid ns
themselves. And this complicates send_signal() too.

Unless the kernel has a user which sends the "strange" SI_FROMUSER()
signal without ->si_pid, of course...

Oleg.
