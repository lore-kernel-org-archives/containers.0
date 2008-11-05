From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 15:28:31 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811051526050.5132@quilx.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
 <20081104124753.fb1dde5a.akpm@linux-foundation.org> <1225831988.7803.1939.camel@twins>
 <20081104131637.68fbe055.akpm@linux-foundation.org> <1225833710.7803.1993.camel@twins>
 <20081104135004.f1717fcf.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041601100.5077@quilx.com>
 <20081104143534.b5c16147.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041648350.6254@quilx.com>
 <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811042036000.31167@quilx.com> <20081104190505.769b93ec.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811050747040.11867@quilx.com> <20081105104145.abd6fc91.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811051415360.31450@quilx.com> <20081105123150.d6628805.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811051434300.31450@quilx.com> <20081105125603.36d0c222.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756675AbYKEV3V@vger.kernel.org>
In-Reply-To: <20081105125603.36d0c222.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, travis@sgi.com, steiner@sgi.com
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008, Andrew Morton wrote:

> See, here's my problem: we have a pile of new code which fixes some
> problem.  But the problem seems to be fairly small - it only affects a
> small number of sophisticated users and they already have workarounds
> in place.

Well yes... Great situation with those workarounds.

> So the world wouldn't end if we just didn't merge it.  Those users
> stick with their workarounds and the kernel remains simpler and
> smaller.
>
> How do we work out which is the best choice here?  I don't have enough
> information to do this.

Not sure how to treat this. I am not involved with large NUMA at this
point. So the people who are interested need to speak up if they want
this.
