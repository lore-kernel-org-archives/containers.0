From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] cgroup: block device i/o bandwidth controller
Date: Sat, 24 May 2008 23:52:50 +0530
Message-ID: <48385CFA.7010201@linux.vnet.ibm.com>
References: <> <1211648217-13361-1-git-send-email-righi.andrea@gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761480AbYEXSY5@vger.kernel.org>
In-Reply-To: <1211648217-13361-1-git-send-email-righi.andrea@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: menage@google.com, matt@bluehost.com, roberto@unbit.it, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> I'm resending an updated version of the cgroup I/O bandwidth controller
> that I wrote some months ago (http://lwn.net/Articles/265944), since
> someone asked me recently.
> 
> The goal of this patchset is to implement a block device I/O bandwidth
> controller using cgroups.
> 
> Detailed informations about design, its goal and usage are described in
> the documentation.
> 
> Review, comments and feedbacks are welcome.
> 

Hi, Andrea,

There are several parallel efforts for the IO controller? Could you
describe/compare them with yours? Is any consensus building taking place?

CC'ing containers mailing list.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
