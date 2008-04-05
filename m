From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] [1/2] Simple stats for cpu resource controller
Date: Sun, 6 Apr 2008 00:39:02 +0530
Message-ID: <200804060039.03083.balajirrao@gmail.com>
References: <200804052339.46632.balajirrao@gmail.com> <20080405185616.GA21279@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754376AbYDETPh@vger.kernel.org>
In-Reply-To: <20080405185616.GA21279@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, a.p.zijlstra@chello.nl, balbir@in.ibm.com, Ingo Molnar <mingo@elte.hu>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Sunday 06 April 2008 12:26:16 am Dhaval Giani wrote:
> On Sat, Apr 05, 2008 at 11:39:46PM +0530, Balaji Rao wrote:
> > This patch implements some trivial statistics for the CPU controller.
> > 
> > As per our current requirements, we have decided to keep the stats tick 
based as opposed to using CFS precise accounting.
> > 
> 
> A quick question? Why? Everywhere in the CFS we use precise accounting,
> (even within the CPU controller). Doesn't make sense using ticks here
> then.
> 
Using CFS precise accounting has a cost (see task_utime and task_stime). 
Currently our requirements don't call for precise statistics.

-- 
regards,
Balaji Rao
Dept. of Mechanical Engineering,
National Institute of Technology Karnataka, India
