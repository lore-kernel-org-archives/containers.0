From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/5] Add common socket helpers to unify the security
	hooks
Date: Tue, 4 Aug 2009 14:58:50 -0500
Message-ID: <20090804195850.GA11746@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-4-git-send-email-danms@us.ibm.com> <20090804192036.GC10275@us.ibm.com> <87d47bl60r.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d47bl60r.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> My only concern here is whether 0 should be passed in by the
> SH> caller?  (Not sure, just wondering)
> 
> I just figured I'd split up the 0/1 case into getname and getpeer,
> mirroring the libc calls.  I don't care either way.

Oh, sounds sensible.

-serge
