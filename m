From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 10:36:58 -0700
Message-ID: <m2wre2d83p.fsf@firstfloor.org>
References: <20110824085329.GL29452@sun> <4E551331.1010709@acm.org>
	<4E551693.5030400@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E551693.5030400@parallels.com> (Pavel Emelyanov's message of
	"Wed, 24 Aug 2011 19:19:47 +0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Zan Lynx <zlynx@acm.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:
>
> No and this is the trick - when you readlink it - it give you trash, but
> when you open one - you get exactly the same file as the map points to.

Isn't that a minor security hole?

For example if I pass a file descriptor into a chroot process for
reading, and with this interface you can open it for writing too.
I could see this causing problems.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
