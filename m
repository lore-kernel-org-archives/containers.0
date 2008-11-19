From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task
	directories
Date: Wed, 19 Nov 2008 03:07:49 +0300
Message-ID: <20081119000749.GA2912@x200.localdomain>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org> <m1abcd2kqk.fsf@frodo.ebiederm.org> <20081106172617.dd51d0af.akpm@linux-foundation.org> <m1abccxpc5.fsf@frodo.ebiederm.org> <20081106184945.179c248a.akpm@linux-foundation.org> <m1iqr0urb8.fsf@frodo.ebiederm.org> <20081106202822.a1af8a6e.akpm@linux-foundation.org> <m1d4h7v8jf.fsf@frodo.ebiederm.org> <20081107080529.6f4de3ad.akpm@linux-foundation.org> <m1zlk3kxfj.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753591AbYKSAEX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zlk3kxfj.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, Nov 13, 2008 at 03:39:44PM -0800, Eric W. Biederman wrote:
> On this patchset it looks like the conversation has wound down with no
> real objects except that some very simple pieces of the code appear
> magic.
> 
> 
> What looks to be the best path for getting this set of patches merged
> into /proc?

Al's ACK minimum.

> Alexy will you pick this up in your /proc tree as Andrew suggested?

Yep, doing it right now.

> Do I need to keep my own tree?

No need.

> Can I have some clear guidance on which hurdles to jump through to
> make forward progress?
