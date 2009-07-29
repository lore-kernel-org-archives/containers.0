From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 09:59:27 -0500
Message-ID: <20090729145927.GA8377@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com> <1248295301-30930-6-git-send-email-danms@us.ibm.com> <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com> <4A6F6B19.9010508@librato.com> <20090729133606.GB31730@us.ibm.com> <87bpn3o87o.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87bpn3o87o.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org, netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> At the moment you miss out on the security_socket_connect() call. 
> 
> Is that any different than the path involved when a process does a
> socketpair() call?
> 
> SH> Still your code is so customized that perhaps an explicit
> SH> security_socket_connect() call in your sock_unix_join() may be the
> SH> way to go...
> 
> So, when I do the join, I really should run the check on both the
> remote and local addresses, right?  The join operation is not really a
> connect in the sense of being one-sided...

Ok well if a join is not a connect then ignore me.

I'll set a block of time aside to take a closer look on your next
submit.

thanks,
-serge
