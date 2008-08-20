From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Bugme-new] [Bug 11381] New: default shmmax
Date: Wed, 20 Aug 2008 19:55:09 +0100
Message-ID: <20080820195509.00994d51@lxorguk.ukuu.org.uk>
References: <bug-11381-10286@http.bugzilla.kernel.org/>
	<20080820120043.e6e7e436.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756330AbYHTTP3@vger.kernel.org>
In-Reply-To: <20080820120043.e6e7e436.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: peter_e@gmx.net, bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org, Nadia Derbey <Nadia.Derbey@bull.net>, Solofo Ramangalahy <Solofo.Ramangalahy@bull.net>, Manfred Spraul <manfred@colorfullife.com>, Pierre Peiffer <peifferp@gmail.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

> It would be useful to get distro input on this.  Do they override the
> kernel default at boot time?  If so, what do they do?

Red Hat provide a sysctl tuning config file and I believe things like the
Oracle install docs cover this.

There is btw no earthly reason why a postgres package can't include a
tool to do this or postgres can't check and update it as part of its
own set up and config file options


Alan
