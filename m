From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/3] capabilities: per-process capbset
Date: Mon, 1 Oct 2007 16:03:38 -0700 (PDT)
Message-ID: <Xine.LNX.4.64.0710011601330.7099@us.intercode.com.au>
References: <20071001144031.GA24683@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20071001144031.GA24683@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: containers@lists.osdl.org, Andrew Morgan <morgan@kernel.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Mon, 1 Oct 2007, Serge E. Hallyn wrote:

> Here is a new per-process capability bounding set patchset
> which I expect to send to linux-kernel soon.  It makes
> the capbset per-process.  A process can only permanently
> remove bits from it's bounding set, not add them.  To
> remove bits, CAP_SYS_ADMIN is currently needed.  Maybe
> that's not the best choice, but some privilege should
> probably be required.

I'm not clear on why privilege would required for a process to remove 
capability bits from its set.  (Sure, if running setuid).

Doesn't that just make it more difficult to write safe applications ?


-- 
James Morris
<jmorris@namei.org>
