From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v3)
Date: Wed, 4 Mar 2009 09:05:19 -0600
Message-ID: <20090304150519.GB10186@us.ibm.com>
References: <1236095764-19325-1-git-send-email-danms@us.ibm.com> <1236095764-19325-3-git-send-email-danms@us.ibm.com> <1236097332.22399.8.camel@nimitz> <878wnmrtp9.fsf@caffeine.danplanet.com> <1236128437.22399.31.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755609AbZCDPL7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1236128437.22399.31.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave@linux.vnet.ibm.com):
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

I maintain however that two strong advantages of moving the checkpoint
and restart of simple registers etc into a single function are:

	1. we won't forget to add (or accidentally lose) one or the
		other
	2. any actual special handling at checkpoint or restart, like
		the loading of access registers at restart on s390x,
		stand out

-serge
