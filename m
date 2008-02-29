From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] [PATCH] Re: Prefixing cgroup generic control filenames with "cgroup."
Date: Fri, 29 Feb 2008 01:34:37 -0800
Message-ID: <6599ad830802290134u4cdfba44v39fd725b5c422720@mail.gmail.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	 <20080228132142.4d4b1eef.akpm@linux-foundation.org>
	 <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
	 <20080228134027.05b2aa87.akpm@linux-foundation.org>
	 <6599ad830802281406t38e486d8g267df1873bc754c2@mail.gmail.com>
	 <20080228142100.2dce0e46.akpm@linux-foundation.org>
	 <47C79F39.5080005@google.com> <20080229002051.86de45a5.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756096AbYB2Je4@vger.kernel.org>
In-Reply-To: <20080229002051.86de45a5.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Thu, Feb 28, 2008 at 10:20 PM, Paul Jackson <pj@sgi.com> wrote:
>
>  For example, what would have been cgroup:
>
>         /mnt/cgroup/user_created_groupname1/user_created_groupname2
>
>  now becomes:
>
>         /mnt/cgroup/cgroups/user_created_groupname1/cgroups/user_created_groupname2
>
>  Right?

Well, the additional components are called "groups" not "cgroups", but
basically yes.

>
>  You're doing this just to "protect the user from themself", to make
>  it more difficult for them to rely on some name that in a future
>  version is no longer available.

Correct. "Future-proofing" and "Forward planning" are two
alternatively-nuanced ways of describing this ...

>
>  There is really a trivial resolution to this ... stake out what
>  additional kernel generated names might ever be added ... some
>  pattern(s) of characters which all future names will match, which
>  leave wide swaths of names safely available, in perpetuity, for
>  user created names, with no risk of future collision.

Yes, we could just say "the kernel reserves the right to use any names
that begin with a lower-case letter, and no others", and be done with
it. That leaves a bit of an ugly taste in my mouth, but if people seem
to prefer that approach we can go for it.

>
>  And did I say incompatible with released versions?

Not at all incompatible if it requires a mount option to enable it ...

Paul
