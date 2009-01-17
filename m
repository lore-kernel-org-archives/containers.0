From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 7/7][v7] proc: Show SIG_DFL signals to init as
	"ignored" signals
Date: Sat, 17 Jan 2009 23:19:09 +0100
Message-ID: <20090117221909.GB3962@redhat.com>
References: <20090117202638.GA11825@us.ibm.com> <20090117203753.GH11825@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932377AbZAQWWU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090117203753.GH11825@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 01/17, Sukadev Bhattiprolu wrote:
>
> Init processes ignore SIG_DFL signals unless they are from an ancestor
> namespace.  Ensure /proc/pid/status correcly reports these signals.

This is the user-visible change, and I don't really understand why do we
need it.

Imho, this patch can confuse the user-space. Why should we report that,
say, SIGCONT is ignored by the global init?


Even if I am wrong, I believe this change is orthogonal to rhis series,
and should be posted separately.

Oleg.
