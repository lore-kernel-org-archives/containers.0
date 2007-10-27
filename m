From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take 2)
Date: Sat, 27 Oct 2007 06:03:46 +0200
Message-ID: <20071027040346.GQ30533@stusta.de>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com> <m1ve8ty1tq.fsf@ebiederm.dsl.xmission.com> <20071027002448.GH30533@stusta.de> <m18x5puyw7.fsf@ebiederm.dsl.xmission.com> <20071027020408.GO30533@stusta.de> <20071026191845.fd0f75c8.akpm@linux-foundation.org> <m18x5pte18.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752535AbXJ0EDf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m18x5pte18.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kir@swsoft.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, kir@openvz.org, Cedric Le Goater <clg@fr.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@us.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, Oct 26, 2007 at 09:46:59PM -0600, Eric W. Biederman wrote:
>...
> It hurts me to even ponder what thinking makes it that 
> CONFIG_EXPERIMENTAL isn't enough to keep a stable distro
> from shipping the code in their stable kernel, and locking us into
> trouble.
>...

There isn't any hard semantics behind what is marked EXPERIMENTAL and 
what not. In it's current state, we could even consider removing the 
EXPERIMENTAL option and all dependencies on EXPERIMENTAL.

Currently CONFIG_EXPERIMENTAL=n would cost a distribution a three digit 
number of device drivers plus several features like e.g. NFSv4.

> Eric

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
