From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] [0/2] Basic stats for cgroups V2
Date: Tue, 8 Apr 2008 19:19:14 +0530
Message-ID: <200804081919.14601.balajirrao@gmail.com>
References: <200804052339.42474.balajirrao@gmail.com> <6599ad830804080036h5496e3bdv9ac2dedf0f04f9bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755107AbYDHN4F@vger.kernel.org>
In-Reply-To: <6599ad830804080036h5496e3bdv9ac2dedf0f04f9bc@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, balbir@in.ibm.com, a.p.zijlstra@chello.nl, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Tuesday 08 April 2008 01:06:17 pm Paul Menage wrote:
> 
> One of the important API choices would be whether the stats API was
> fixed in header files shared with userspace, or whether it would be
> possible for stats to be added and dynamically discovered/used by
> userspace without needing fixed header file descriptions.
> 
The second idea is much better, I feel.

> The difference would be a bit like the old sysctl API (where each
> sysctl entry had to be enumerated in a header file) versus the newer
> /proc/sys approach where numerical values aren't used and userspace
> can determine which entries are supported at runtime, and even access
> new previously-unknown entries.
> 

<snip>

> 
> Thoughts?

Overall the idea looks good to me.

We are also looking at a generic framework in cgroups that would delegate the 
job of handling statistics to the cgroup framework itself. This would avoid 
code duplication across various controllers.

-- 
regards,
Balaji Rao
