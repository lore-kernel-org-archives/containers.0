From: Paul Menage <menage@google.com>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 13:55:33 -0800
Message-ID: <6599ad830811051355n5765a115mbd6eb389504d125d@mail.gmail.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	 <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0811042036000.31167@quilx.com>
	 <20081104190505.769b93ec.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0811050747040.11867@quilx.com>
	 <20081105104145.abd6fc91.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0811051415360.31450@quilx.com>
	 <20081105123150.d6628805.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0811051434300.31450@quilx.com>
	 <20081105125603.36d0c222.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755811AbYKEVzu@vger.kernel.org>
In-Reply-To: <20081105125603.36d0c222.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, peterz@infradead.org, rientjes@google.com, npiggin@suse.de, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, Nov 5, 2008 at 12:56 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>>
>> 1. Reduce the global dirty ratios so that the number of dirty pages in a
>> cpuset cannot become too high.
>
> That would be less than the smallest node's memory capacity, I guess.

Even that doesn't work - if there's a single global limit on dirty
pages, then any cpuset/cgroup with access to enough memory can exhaust
that limit and cause other processes to block when they try to write
to disk. You need independent dirty counts to avoid that, whether it
be per-node or per-cgroup.

Paul
