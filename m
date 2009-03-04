From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v3)
Date: Wed, 4 Mar 2009 13:53:14 -0600
Message-ID: <20090304135314.618ad07e@thinkcentre.lan>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com>
 <1236095764-19325-3-git-send-email-danms@us.ibm.com>
 <1236097332.22399.8.camel@nimitz> <878wnmrtp9.fsf@caffeine.danplanet.com>
 <1236128437.22399.31.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757842AbZCDTxn@vger.kernel.org>
In-Reply-To: <1236128437.22399.31.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 03 Mar 2009 17:00:37 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Tue, 2009-03-03 at 16:57 -0800, Dan Smith wrote:
> > DH> Did you convince Nathan that this ends up being a good idea?
> > 
> > Technically he hasn't seen this version, but my hopes are not high
> > that he will change his mind.  If the feedback is that they're not
> > liked, I'll happily remove them.
> 
> I just figure if Nathan feels that strongly that we'll encounter more
> people who feel even more so.  So, I was curious if he changed his mind
> somehow.

No, not really, sorry.

I understand why it's nice for the developer to have this sort of
helper, but I don't think it's nice for someone trying to review or
debug the code.

Surely discussing these macros has already consumed more developer time
than they would ever save?  :)
