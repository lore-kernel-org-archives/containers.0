From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Tue, 29 Apr 2008 14:42:08 +0900
Message-ID: <20080429144208.396a8075.kamezawa.hiroyu@jp.fujitsu.com>
References: <200804052340.02386.balajirrao@gmail.com>
	<48036CB4.5050700@linux.vnet.ibm.com>
	<200804282130.30188.balajirrao@gmail.com>
	<20080428094026.bc78ccc7.akpm@linux-foundation.org>
	<48161159.6010802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757130AbYD2Fhn@vger.kernel.org>
In-Reply-To: <48161159.6010802@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, Balaji Rao <balajirrao@gmail.com>
List-Id: containers.vger.kernel.org

On Mon, 28 Apr 2008 23:33:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> The statistics was added as a part of git commit
> d52aa412d43827033a8e2ce4415ef6e8f8d53635. I'll go ahead and try to document
> them. These patches piggy back on the statistics patches and add pagein/pageout
> counts, which is a useful statistic for the memory controller.
> 
I'm sorry for lack of documentation.
BTW, when you adds documentation on this pagein/pageout, please make it clear

1. pagein means a new page is newly acconted to this cgrop, doesn't means
   a page is read from disk.
2. pageout means a page is dropped from this cgroup, doesn't means a page
   is written into disk.

So, pagein/pageout is a bit ambiguous. I'm happy if you find better names.


Thanks,
-Kame
