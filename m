From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Tue, 4 Nov 2008 15:36:10 -0800
Message-ID: <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	<20081104124753.fb1dde5a.akpm@linux-foundation.org>
	<1225831988.7803.1939.camel@twins>
	<20081104131637.68fbe055.akpm@linux-foundation.org>
	<1225833710.7803.1993.camel@twins>
	<20081104135004.f1717fcf.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041601100.5077@quilx.com>
	<20081104143534.b5c16147.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041648350.6254@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755818AbYKDXgf@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811041648350.6254@quilx.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Tue, 4 Nov 2008 16:52:48 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 4 Nov 2008, Andrew Morton wrote:
> 
> > To fix this with a memcg-based throttling, the operator would need to
> > be able to create memcg's which have pages only from particular nodes.
> > (That's a bit indirect relative to what they want to do, but is
> > presumably workable).
> 
> The system would need to have the capability to find the memcg groups that 
> have dirty pages for a certain inode. Files are not constrained to nodes 
> or memcg groups.

Ah, we're talking about different things.

In a memcg implementation what we would implement is "throttle
page-dirtying tasks in this memcg when the memcg's dirty memory reaches
40% of its total".

But that doesn't solve the problem which this patchset is trying to
solve, which is "don't let all the memory in all this group of nodes
get dirty".


Yes?  Someone help me out here.  I don't yet have my head around the
overlaps and incompatibilities here.  Perhaps the containers guys will
wake up and put their thinking caps on?



What happens if cpuset A uses nodes 0,1,2,3,4,5,6,7,8,9 and cpuset B
uses nodes 0,1?  Can activity in cpuset A cause ooms in cpuset B?
