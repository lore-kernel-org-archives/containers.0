From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Tue, 18 Nov 2008 18:28:17 -0800
Message-ID: <20081119022817.GA20290@us.ibm.com>
References: <20081115212133.GA32140@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752046AbYKSCb4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081115212133.GA32140@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

| @@ -864,6 +902,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
|  		 * and sent by user using something other than kill().
|  		 */
|  			return -EAGAIN;
| +
| +		if (from_ancestor_ns)
| +			return -ENOMEM;
|  	}
| 
|  out_set:

We had wanted to start with a check like above and improve later.

But if sender is from ancestor namespace, we must post the signal even if
we don't have the siginfo right ?  Otherwise, a SIGKILL from ancestor may
get the -ENOMEM ?

Conversely, if a signal from same namespace is being posted to cinit, and
we don't have siginfo, ->si_pid would be 0 and get_signal_to_deliver()
would mistake that the sender is an ancestor ns and process the signal
(which should have been ignored).

So, maybe we should start with the reverse check ?

	if (same_ns && (t->signal->flags & SIGNAL_UNKILLABLE))
		return -ENOMEM;

Sukadev
