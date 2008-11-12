From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Signals to cinit
Date: Wed, 12 Nov 2008 16:05:55 +0100
Message-ID: <20081112150555.GB13269@redhat.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com> <20081111022405.GB20891@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753360AbYKLOGJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081111022405.GB20891@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@linux.vnet.ibm.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, serue@us.ibm.com, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 11/10, sukadev@linux.vnet.ibm.com wrote:
>
> Also, what happens if a fatal signal is first received from a descendant
> and while that is still pending, the same signal is received from ancestor
> ns ?  Won't the second one be ignored by legacy_queue() for the non-rt case ?

Please see my another email:

	We must also change sig_ignored() to drop SIGKILL/SIGSTOP early when
	it comes from the same ns. Otherwise, it can mask the next SIGKILL
	from the parent ns.

	But this perhaps makes sense anyway, even without containers.
	Currently, when the global init has the pending SIGKILL, we can't
	trust __wait_event_killable/etc, and this is actually wrong.

We can drop other SIG_DFL signals from the same namespace early as well.
I seem to already did something like sig_init_ignored(), but I forgot.

Or, we can just ignore this (imho) minor problem. The ancestor ns
must know it can't reliably kill cinit with (say) SIGTERM. It can
be ignored, or it can have have a handler, and it can be lost because
SIGTERM is already pending. Only SIGKILL is special.

Actually. I personally think that if we manage to achieve that

	- the sub-namespace can't kill its init

	- the ancestor can always kill cinit with SIGKILL

then imho we should not worry very much about other issues ;)

Oleg.
