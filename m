From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH -mm] Hook up group scheduler with control groups
Date: Thu, 27 Sep 2007 21:41:26 +0200
Message-ID: <200709272141.28571.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759983AbXI0Tlm@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: vatsa@linux.vnet.ibm.com, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, efault@gmx.de, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Randy Dunlap <randy.dunlap@oracle.com>
List-Id: containers.vger.kernel.org

Dhaval Giani wrote:
> +config FAIR_CGROUP_SCHED
> +	bool "Control groups"
> + 	depends on CGROUPS
> + 	help

There are also stray spaces before the tab on the last two lines above.

Cheers,
Frans Pop
