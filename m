From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 6/6][v3] Protect cinit from blocked fatal signals
Date: Mon, 22 Dec 2008 15:38:55 -0800
Message-ID: <20081222233855.GA13079@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com> <20081221005529.GF5025@us.ibm.com> <20081222225825.GC1536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756509AbYLVXkd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081222225825.GC1536@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| > @@ -1907,9 +1943,10 @@ relock:
| >
| >  		/*
| >  		 * Global init gets no signals it doesn't want.
| > +		 * Container-init gets no signals it doesn't want from same
| > +		 * container.
| >  		 */
| > -		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
| > -		    !signal_group_exit(signal))
| > +		if (sig_unkillable(signal, signr) && !signal_group_exit(signal))
| >  			continue;
| 
| Again, I do not understand why do we need SIGNAL_UNKILLABLE_FROM_NS.
| 
| I thought about the change in get_signal_to_deliver() during the
| previous discussion, and I think what we need is:
| 
| 		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
| 		    !sig_kernel_only(sig))
| 			continue;
| 
| and this was yet another reason for "protect init from unwanted signals more".

I was trying to avoid the clearing of the SIGNAL_UNKILLABLE in
send_signal() that we had last time.

But yes, you are right. I even had a BUG_ON() to confirm SIGKILL/SIGSTOP
will never happen for global-init :-). If so, SIGKLL/SIGSTOP to an init
can come only from parent ns.

So, yes, we can drop this flag.
