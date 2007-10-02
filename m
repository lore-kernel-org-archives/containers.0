From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/3] capabilities: per-process capbset
Date: Mon, 1 Oct 2007 22:24:03 -0500
Message-ID: <20071002032403.GA7848@sergelap.austin.ibm.com>
References: <20071001144031.GA24683@sergelap.austin.ibm.com> <Xine.LNX.4.64.0710011601330.7099@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.64.0710011601330.7099@us.intercode.com.au>
Sender: linux-security-module-owner@vger.kernel.org
To: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, containers@lists.osdl.org, Andrew Morgan <morgan@kernel.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting James Morris (jmorris@namei.org):
> On Mon, 1 Oct 2007, Serge E. Hallyn wrote:
> 
> > Here is a new per-process capability bounding set patchset
> > which I expect to send to linux-kernel soon.  It makes
> > the capbset per-process.  A process can only permanently
> > remove bits from it's bounding set, not add them.  To
> > remove bits, CAP_SYS_ADMIN is currently needed.  Maybe
> > that's not the best choice, but some privilege should
> > probably be required.
> 
> I'm not clear on why privilege would required for a process to remove 
> capability bits from its set.  (Sure, if running setuid).

I don't know what you mean by "Sure, if running setuid."

> Doesn't that just make it more difficult to write safe applications ?

My concern is that an unprivileged user could find a setuid root
application that will partially run but fail unsafely if it can get,
say, CAP_SETUID but not CAP_CHOWN, and is fooled in completing part of
it's privileged operation, then quitting or dying due to lack additional
privs, leaving the operation in an exploitable state.

No concrete examples offhand, but it feels like by not requiring
privilege we're inviting things similar to the old sendmail capabilities
bug.  (I don't think that exact flow is possible, but something
similar)  After all the setuid root applications assume that if
they ran as root, then they have full capabilities.

-serge
