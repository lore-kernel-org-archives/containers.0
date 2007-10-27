From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take 2)
Date: Fri, 26 Oct 2007 19:18:45 -0700
Message-ID: <20071026191845.fd0f75c8.akpm@linux-foundation.org>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>
	<m1ve8ty1tq.fsf@ebiederm.dsl.xmission.com>
	<20071027002448.GH30533@stusta.de>
	<m18x5puyw7.fsf@ebiederm.dsl.xmission.com>
	<20071027020408.GO30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754313AbXJ0CTT@vger.kernel.org>
In-Reply-To: <20071027020408.GO30533@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Cc: ebiederm@xmission.com, kir@swsoft.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, kir@openvz.org
List-Id: containers.vger.kernel.org

> On Sat, 27 Oct 2007 04:04:08 +0200 Adrian Bunk <bunk@kernel.org> wrote:
> > be happy to hear if someone has a better idea.
> 
> There is a difference between "complete the feature" and "early adopters 
> to start playing with the feature" on the one side, and making something 
> available in a released kernel on the other side.
> 
> For development and playing with it it can depend on BROKEN (perhaps 
> with the dependency removed through the first -rc kernels), but as soon 
> as it's available in a -final kernel the ABI is fixed.
> 

Yes, if we're not 100% certain that the interfaces are correnct and unchanging
and that the implementation is solid, we should disable the feature at Kconfig time.

The best option would be to fix things asap.  But assuming that option isn't
reasonable and/or safe, we can slip a `depends on BROKEN' into -rc6 then
resume development for 2.6.25.
