From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Cleanup code under CONFIG_FAIR_GROUP_SCHED
Date: Mon, 24 Sep 2007 22:43:24 +0530
Message-ID: <20070924171324.GG5657@linux.vnet.ibm.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com> <20070924163937.GD10291@linux.vnet.ibm.com> <20070924095344.ee9ab10e.randy.dunlap@oracle.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764882AbXIXRDH@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070924095344.ee9ab10e.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org

On Mon, Sep 24, 2007 at 09:53:44AM -0700, Randy Dunlap wrote:
> >  config FAIR_GROUP_SCHED
> > -	bool "Fair group scheduler"
> > -	depends on EXPERIMENTAL && CONTAINERS
> > +	bool "Fair group cpu scheduler"
> 
> Can we have "CPU" instead of "cpu" ?

Sounds good. Will add to my follow-on.patch (and will send out after
others have had a chance to comment).

-- 
Regards,
vatsa
