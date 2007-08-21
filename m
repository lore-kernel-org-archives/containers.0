From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [RFC,PATCH] fix /sbin/init signal handling
Date: Tue, 21 Aug 2007 14:30:02 +0400
Message-ID: <20070821103002.GA164@tv-sign.ru>
References: <20070819150822.GA7772@tv-sign.ru> <20070821071019.GA8641@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758009AbXHUKae@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070821071019.GA8641@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Daniel Pittman <daniel@rimspace.net>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, Kirill Korotaev <dev@sw.ru>, Pavel Emelyanov <xemul@sw.ru>, Roland McGrath <roland@redhat.com>, "Serge E. Hallyn" <serue@us.ibm.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 08/21, sukadev@us.ibm.com wrote:
> 
> I am still reviewing this patch and will try to plug in the multiple
> pid ns code and play with it some more in the next couple of days.

Thanks!

> But am curious why we need the in_interrupt() check and that too only
> for the container-init process.

For example, send_sigio(). We shouldn't send this signal to /sbin/init.
But what if the interrupted process is from the parent namespace?

> Also, maybe a dumb que, are the checks for SIG_IGN and SIG_DFL required
> both on sender side and the receiver side (get_signal_to_deliver())

get_signal_to_deliver() checks SIG_IGN/SIG_DFL, but I guess you meant
a special check for init.

Unless the patch is wrong, this is not needed. And, in fact we can't do
this anyway. Because get_signal_to_deliver() can't know if the signal
comes from parent namespace or not.

Oleg.
