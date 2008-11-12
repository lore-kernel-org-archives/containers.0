From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: Signals to cinit
Date: Wed, 12 Nov 2008 11:04:21 -0800
Message-ID: <20081112190421.GE3230@us.ibm.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com> <20081111022405.GB20891@us.ibm.com> <20081112150555.GB13269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755062AbYKLTIN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081112150555.GB13269@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, serue@us.ibm.com, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 11/10, sukadev@linux.vnet.ibm.com wrote:
| >
| > Also, what happens if a fatal signal is first received from a descendant
| > and while that is still pending, the same signal is received from ancestor
| > ns ?  Won't the second one be ignored by legacy_queue() for the non-rt case ?

On second thoughts, cinit is a normal process in its ancestor ns so it
might very well ignore the second instance of the signal (as long as it
does not ignore SIGKILL/SIGSTOP)

| 
| Please see my another email:
| 
| 	We must also change sig_ignored() to drop SIGKILL/SIGSTOP early when
| 	it comes from the same ns. Otherwise, it can mask the next SIGKILL
| 	from the parent ns.

Ok.

| 
| 	But this perhaps makes sense anyway, even without containers.
| 	Currently, when the global init has the pending SIGKILL, we can't
| 	trust __wait_event_killable/etc, and this is actually wrong.
| 
| We can drop other SIG_DFL signals from the same namespace early as well.

I think Eric's patchset did this and iirc, we ran into the problem of
blocked SIG_DFL signals ?

| I seem to already did something like sig_init_ignored(), but I forgot.

Yes, I think we had that in the patchset but that was not merged.

| 
| Or, we can just ignore this (imho) minor problem.

I think so too.

| The ancestor ns
| must know it can't reliably kill cinit with (say) SIGTERM. It can
| be ignored, or it can have have a handler, and it can be lost because
| SIGTERM is already pending. Only SIGKILL is special.
| 
| Actually. I personally think that if we manage to achieve that
| 
| 	- the sub-namespace can't kill its init
| 
| 	- the ancestor can always kill cinit with SIGKILL

Yep.

| 
| then imho we should not worry very much about other issues ;)
| 
| Oleg.
