From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 11:07:39 +0900
Message-ID: <20080616110609.7893.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080613214626.9afc892f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757596AbYFPCJB@vger.kernel.org>
In-Reply-To: <20080613214626.9afc892f.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi Randy,

sorry for so late responce.
REALLY REALLY Thank you for your professional review!

I'll merge it.

> > Index: b/init/Kconfig
> > ===================================================================
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -289,6 +289,16 @@ config CGROUP_DEBUG
> >  
> >  	  Say N if unsure
> >  
> > +config CGROUP_TASK
> > +	bool "Simple number of task accounting cgroup subsystem"
> > +	depends on CGROUPS && EXPERIMENTAL
> > +	default n
> > +	help
> > +          Provides a simple number of task accounting cgroup subsystem for
> 
> Indent help test one tab + 2 spaces, please.
> s/for/to/

(snip)
