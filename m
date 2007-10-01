From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/3] capabilities: per-process capbset
Date: Mon, 1 Oct 2007 09:49:09 -0500
Message-ID: <20071001144909.GA26322@sergelap.austin.ibm.com>
References: <20071001144031.GA24683@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071001144031.GA24683@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: linux-security-module@vger.kernel.org, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Here is a new per-process capability bounding set patchset
> which I expect to send to linux-kernel soon.  It makes
> the capbset per-process.  A process can only permanently
> remove bits from it's bounding set, not add them.  To
> remove bits, CAP_SYS_ADMIN is currently needed.  Maybe
> that's not the best choice, but some privilege should
> probably be required.
> 
> The intent is to allow a process tree to start with
> certain capabilities, i.e. CAP_MKNOD, permanently
> removed, so that running a setuid binary or one with
> file capabilities will still not result in those
> capabilities.  The immediate use case for this is
> containers/virtual servers.
> 
> I am not taking the task_capability_lock during
> cap_prctl_setbset(), just as it is not taken when
> capabilities are calculated during fork.  That means

Where by fork I of course mean exec.

-serge

> it can race with another task doing capsetp() on it,
> and with capgetp().  I'm still looking for comments
> on whether the fix I sent out last week is correct.
> If it is, then I'll take the task_capability_lock
> during cap_prctl_setbset().
> 
> thanks,
> -serge
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
