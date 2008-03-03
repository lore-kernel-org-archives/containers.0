From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Mon, 03 Mar 2008 15:29:29 +0530
Message-ID: <47CBCC01.6080504@linux.vnet.ibm.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com> <20080228132142.4d4b1eef.akpm@linux-foundation.org> <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com> <20080228213319.GC1232@vino.hallyn.com> <6599ad830802281406s512ee32bkeb2b0387a7737a87@mail.gmail.com> <6599ad830803030038p2d81883bu895260a96fedaec6@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755198AbYCCKBt@vger.kernel.org>
In-Reply-To: <6599ad830803030038p2d81883bu895260a96fedaec6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: serge@hallyn.com, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, xemul@openvz.org, pj@sgi.com
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Thu, Feb 28, 2008 at 2:06 PM, Paul Menage <menage@google.com> wrote:
>> On Thu, Feb 28, 2008 at 1:33 PM,  <serge@hallyn.com> wrote:
>>  >
>>  >  You said the set of files belong to cgroup itself is likely to increase
>>  >  - do you have some candidates in mind?
>>
>>  Nothing concrete right now. One example that I already proposed was
>>  the "cgroup.api" file but that's shelved for now, until such time as I
>>  actually propose the binary API that it was intended to help support.
>>
> 
> One likely new file that people agreed a while ago could be useful
> would be a "procs" file, similar to "tasks", but acting (and
> reporting) on thread groups rather than individual tasks.
> 
> Paul

Yes, I remember this. This feature would be extremely useful.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
