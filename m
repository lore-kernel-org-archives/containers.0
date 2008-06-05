From: "Daniel Hokka Zakrisson" <daniel@hozac.com>
Subject: Re: [RFC][PATCH] introduce task cgroup (#task restrictioon for
     prevent fork bomb by cgroup)
Date: Thu, 5 Jun 2008 23:52:36 +0200 (CEST)
Message-ID: <41480.192.168.101.12.1212702756.squirrel@intranet>
References: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760640AbYFEVwt@vger.kernel.org>
In-Reply-To: <20080605132512.9C31.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

KOSAKI Motohiro wrote:
> Hi
>
> I create new cgroup of number task restriction.
> Please any comments!

Would it make more sense to implement this as part of an rlimit subsystem,
which also supports limiting e.g. address space, CPU time, number of open
files, etc.? If we create one subsystem per resource, I'm afraid we're
going to see quite some time spent in all those loops, and the options for
cgroupfs is going to become pretty long if you want to exclude just one or
two of the subsystems for one particular mount point.

-- 
Daniel Hokka Zakrisson
