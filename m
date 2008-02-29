From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] [PATCH] Re: Prefixing cgroup generic control filenames
 with "cgroup."
Date: Fri, 29 Feb 2008 00:20:51 -0600
Message-ID: <20080229002051.86de45a5.pj@sgi.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<20080228132142.4d4b1eef.akpm@linux-foundation.org>
	<6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
	<20080228134027.05b2aa87.akpm@linux-foundation.org>
	<6599ad830802281406t38e486d8g267df1873bc754c2@mail.gmail.com>
	<20080228142100.2dce0e46.akpm@linux-foundation.org>
	<47C79F39.5080005@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758829AbYB2GVP@vger.kernel.org>
In-Reply-To: <47C79F39.5080005@google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org
List-Id: containers.vger.kernel.org

Paul M wrote:
> Thoughts? Is this a direction we want to go in? As an option, or by default?

So ... this proposal adds a 'groups' subdirectory in each cgroup, and places
the user generated subgroups in there.

It looks like an unnecessary, incompatible and complicating change to me.

For example, what would have been cgroup:

	/mnt/cgroup/user_created_groupname1/user_created_groupname2

now becomes:

	/mnt/cgroup/cgroups/user_created_groupname1/cgroups/user_created_groupname2

Right?

Why would you do this?

There is no problem with the current implementation, no bug we're
having trouble coding a fix for, no feature we're have trouble adding.
The current code, that simply doesn't allow colliding user names
because the kernel provided names are already there, works just fine.

You're doing this just to "protect the user from themself", to make
it more difficult for them to rely on some name that in a future
version is no longer available.

It annoys users, and rightfully so, to have to permanently deal with
interface warts, because the computer is trying to protect the user
from some hypothetical scenario that is not a problem the user needs
solving.

There is really a trivial resolution to this ... stake out what
additional kernel generated names might ever be added ... some
pattern(s) of characters which all future names will match, which
leave wide swaths of names safely available, in perpetuity, for
user created names, with no risk of future collision.

And did I say incompatible with released versions?

Hopefully Paul M isn't too surprised that I'm not endorsing this one ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
