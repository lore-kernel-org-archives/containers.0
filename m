From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 08:03:39 -0700
Message-ID: <877hxro7jo.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com> <20090729133606.GB31730@us.ibm.com>
	<87bpn3o87o.fsf@caffeine.danplanet.com>
	<20090729145927.GA8377@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090729145927.GA8377@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 29 Jul 2009 09\:59\:27 -0500")
Sender: netdev-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org, netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

SH> Ok well if a join is not a connect then ignore me.

Well, it's closer to a socketpair() than a connect(), I'd say.

For now, I'll put a comment in there noting that we may need a
security hook to remind us to revisit it.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
