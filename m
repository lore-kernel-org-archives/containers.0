From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 28 Jul 2009 20:56:53 -0500
Message-ID: <20090729015653.GA31730@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com> <1248295301-30930-6-git-send-email-danms@us.ibm.com> <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ljm8czsf.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org, netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> OL> Unless/until we decide otherwise, let's keep all ckpt_hdr_xxx
> OL> definitions in a single place -- checkpoint_hdr.h
> 
> That's how I initially had it, but Serge asked for it to be moved into
> the network headers.  Serge?

Yes, it seems to me we want to keep those close to the maintainer's
code rather than expect them to go browsing through cr headers when
they change their own code.

Of course just putting ckpt_hdr_xxx into the subsystems' headers
isn't sufficient - we need to have better discussions with the
maintainers about ways to make maintaining their subsystems with
cr pretty much the same as it was without cr.

-serge
