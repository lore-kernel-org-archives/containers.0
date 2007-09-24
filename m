From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] Add fair-user scheduler
Date: Mon, 24 Sep 2007 22:46:24 +0530
Message-ID: <20070924171624.GH5657@linux.vnet.ibm.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com> <20070924164059.GE10291@linux.vnet.ibm.com> <20070924095641.12e595b3.randy.dunlap@oracle.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764824AbXIXRGY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070924095641.12e595b3.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org

On Mon, Sep 24, 2007 at 09:56:41AM -0700, Randy Dunlap wrote:
> > +choice
> > +	depends on FAIR_GROUP_SCHED
> > +	prompt "Basis for grouping tasks"
> > +	default FAIR_USER_SCHED
> > +
> > + 	config FAIR_USER_SCHED
> > + 		bool "user id"
> > + 		help
> > + 		  This option will choose userid as the basis for grouping
> > +		  tasks, thus providing equal cpu bandwidth to each user.
> 
> s/cpu/CPU/g please.

ok, sure.

> and the "bool", "help" and help text are indented by one tab too much.

will take care.

-- 
Regards,
vatsa
