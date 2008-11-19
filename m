From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Tue, 18 Nov 2008 17:22:07 -0800
Message-ID: <20081119012207.GA19092@us.ibm.com>
References: <20081115212133.GA32140@us.ibm.com> <20081118175336.GA14178@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752311AbYKSBZw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081118175336.GA14178@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


| 
| > +static inline int siginfo_from_ancestor_ns(siginfo_t *info)
| > +{
| > +	return SI_FROMUSER(info) && (info->si_pid == 0);
| > +}
| 
| Yes, this is problem... I doubt we can rely on !si_pid here.
| More on this later.

BTW, rather than clearing SIG_FROM_USER in send_signal(), can we
keep it till we dequeue the signal ? Yes, collect_signal() would
need to consider this flag. But when we dequeue, we can note that
it was from user and use that in the siginfo_from_ancestor() ?

Sukadev
