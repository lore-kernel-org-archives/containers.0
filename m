From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty
 limits
Date: Tue, 5 Oct 2010 11:31:57 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010051131290.11568@chino.kir.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com> <1286175485-30643-9-git-send-email-gthelen@google.com> <20101005161340.9bb7382e.kamezawa.hiroyu@jp.fujitsu.com> <xr93r5g5w0uc.fsf@ninji.mtv.corp.google.com>
 <20101005091836.GA1698@linux.develer.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101005091836.GA1698@linux.develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-Id: containers.vger.kernel.org

On Tue, 5 Oct 2010, Andrea Righi wrote:

> mmh... looking at the code it seems the same behaviour, but in
> Documentation/sysctl/vm.txt we say a different thing (i.e., for
> dirty_bytes):
> 
> "If dirty_bytes is written, dirty_ratio becomes a function of its value
> (dirty_bytes / the amount of dirtyable system memory)."
> 
> However, in dirty_bytes_handler()/dirty_ratio_handler() we actually set
> the counterpart value as 0.
> 
> I think we should clarify the documentation.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for cc'ing me on this, Andrea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
