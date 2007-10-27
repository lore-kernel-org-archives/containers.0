From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take 2)
Date: Fri, 26 Oct 2007 22:40:12 -0600
Message-ID: <m14pgdtbkj.fsf@ebiederm.dsl.xmission.com>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>
	<m1ve8ty1tq.fsf@ebiederm.dsl.xmission.com>
	<20071027002448.GH30533@stusta.de>
	<m18x5puyw7.fsf@ebiederm.dsl.xmission.com>
	<20071027020408.GO30533@stusta.de>
	<20071026191845.fd0f75c8.akpm@linux-foundation.org>
	<m18x5pte18.fsf@ebiederm.dsl.xmission.com>
	<20071027040346.GQ30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752607AbXJ0ElW@vger.kernel.org>
In-Reply-To: <20071027040346.GQ30533@stusta.de> (Adrian Bunk's message of
	"Sat, 27 Oct 2007 06:03:46 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kir@swsoft.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, kir@openvz.org, Cedric Le Goater <clg@fr.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@us.ibm.com>
List-Id: containers.vger.kernel.org

Adrian Bunk <bunk@kernel.org> writes:

> There isn't any hard semantics behind what is marked EXPERIMENTAL and 
> what not. In it's current state, we could even consider removing the 
> EXPERIMENTAL option and all dependencies on EXPERIMENTAL.

Well I do know at least some of the things that depend on experimental
are legitimate.

I wonder if the problem is that we don't police experimental well
enough.

> Currently CONFIG_EXPERIMENTAL=n would cost a distribution a three digit 
> number of device drivers plus several features like e.g. NFSv4.

I can see a distribution carefully cherry picking things, that the
have an intimate knowledge about out of experimental but it doesn't
sound right for taking things out of EXPERIMENTAL to be routine.

I know I'm a little slow about getting around to it but when ever I
have a feature that isn't EXPERIMENTAL anymore I remove the tag.

Eric
