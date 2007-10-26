From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take 2)
Date: Fri, 26 Oct 2007 16:34:28 -0600
Message-ID: <m1abq5y07f.fsf@ebiederm.dsl.xmission.com>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765727AbXJZWfI@vger.kernel.org>
In-Reply-To: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>
	(Kir Kolyshkin's message of "Fri, 26 Oct 2007 16:58:32 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Kir Kolyshkin <kir@openvz.org>
Cc: containers@lists.osdl.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
List-Id: containers.vger.kernel.org

"Kir Kolyshkin" <kir@swsoft.com> writes:

> Speaking of this particular patch -- I don't understand how you fix
> "innumerable little bugs" by providing stubs instead of real functions.

I think it would be a disaster to use pid namespaces as currently
implemented 2.6.24-rc1 in a production environment.

There are lots of little bugs and I am certain know one knows what
they are all right now.

Therefore not creating more then the initial pid namespace in a
production environment sounds like the responsible thing to do for
2.6.24.

This patch enables people to guarantee they don't run software
that will create additional pid namespaces and expose them to
the bugs we have not yet found, and it says look out.  Don't
mess with this unless you know what you are doing.

That message of Look out be careful is what I really care
about sending to users of the kernel. 

The best way I know to do that is to mark the feature
(EXPERIMENTAL) and have a config option for the feature
that depends on CONFIG_EXPERIMENTAL.

Eric
