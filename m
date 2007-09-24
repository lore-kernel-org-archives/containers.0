From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: [PATCH 0/5] Fair group scheduler - various fixes
Date: Mon, 24 Sep 2007 22:03:26 +0530
Message-ID: <20070924163326.GA10291@linux.vnet.ibm.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760105AbXIXQXP@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>
Cc: dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org

Hello Ingo and Andrew,
	Here are various patches to fair group scheduler code present in
sched-devel and in 2.6.23-rc7-mm1. These patches should apply against
both sched-devel git tree and 2.6.23-rc7-mm1 (as they are both in sync
now).

Pls consider for inclusion after review.

[there is still room for improving group fairness obtained on smp
systems. By sending out these patches, i am hoping more folks can test
and improve that aspect]

Ingo,
	You may want to avoid picking Patch 5/5 as it makes sense only in
-mm tree atm.

-- 
Regards,
vatsa
