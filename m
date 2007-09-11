From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container
 infrastructure
Date: Tue, 11 Sep 2007 08:53:01 -0700
Message-ID: <20070911085301.ca3a00e4.randy.dunlap@oracle.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	<20070910172334.GB19100@linux.vnet.ibm.com>
	<20070910102259.dc45a481.akpm@linux-foundation.org>
	<20070910174649.GA16222@linux.vnet.ibm.com>
	<b647ffbd0709101537l9af4dc8x743b25c96e0f5235@mail.gmail.com>
	<6599ad830709101545s66fd338dob6932407db4e1002@mail.gmail.com>
	<46E641C1.8000808@fr.ibm.com>
	<20070911082243.9433c528.randy.dunlap@oracle.com>
	<20070911155119.GE16222@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762072AbXIKPyj@vger.kernel.org>
In-Reply-To: <20070911155119.GE16222@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Cedric Le Goater <clg@fr.ibm.com>, Paul Menage <menage@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Tue, 11 Sep 2007 21:21:19 +0530 Srivatsa Vaddagiri wrote:

> On Tue, Sep 11, 2007 at 08:22:43AM -0700, Randy Dunlap wrote:
> > That looks odd, like it's a filesystem.
> > What does cfs really mean?
> 
> cfs = completely fair scheduler :)
> 
> In this thread, we are talking of hooking the cfs cpu scheduler with the
> task-container framework in -mm tree, so that the scheduler can deal
> with groups of tasks rather than just tasks, while handling fairness of
> cpu allocation.
> 
> I agree "cfs" control subsystem does look odd a bit here. "cpu" control
> subsystem seems better.

Thanks.  I agree that using "cpu" is better.  I.e., don't tie it
to a particular scheduler name.  It would just need to change the
next time we have a new scheduler.  ;)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
