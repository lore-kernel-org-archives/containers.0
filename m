From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Hookup group-scheduler with task container
 infrastructure
Date: Mon, 10 Sep 2007 10:22:59 -0700
Message-ID: <20070910102259.dc45a481.akpm@linux-foundation.org>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	<20070910172334.GB19100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755903AbXIJRYU@vger.kernel.org>
In-Reply-To: <20070910172334.GB19100@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, ckrm-tech@lists.sourceforge.net, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Mon, 10 Sep 2007 22:53:34 +0530 Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:

> On Mon, Sep 10, 2007 at 07:05:00PM +0200, Jan Engelhardt wrote:
> > On Sep 10 2007 22:40, Srivatsa Vaddagiri wrote:
> > >+#ifdef CONFIG_FAIR_GROUP_SCHED
> > >+SUBSYS(cpuctlr)
> > >+#endif
> > 
> > cpuctl, cpuctrl, cpu_controller?
> 
> *shrug* .. I used "cpuctlr" to mean "CPU Controller". Any other short names
> would do. From your list, cpuctl or cpuctrl both qualifies IMO!
> 
> Unless folks have strong objection to it, I prefer "cptctlr", the way it is.
> 

objection ;)  "cpuctlr" isn't memorable.  Kernel code is write-rarely,
read-often.  "cpu_controller", please.  The extra typing is worth it ;)
