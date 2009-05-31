From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Mon, 1 Jun 2009 00:56:32 +0400
Message-ID: <20090531205632.GA19741@x200.localdomain>
References: <20090529223229.GA14536@us.ibm.com> <20090529223319.GE14602@us.ibm.com> <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d4f050d30905311326i59bf5e2fjfa837f2720d076dc@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Andrew G. Morgan" <morgan@kernel.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Sun, May 31, 2009 at 01:26:21PM -0700, Andrew G. Morgan wrote:
> I'm not sure I'm too happy with hard coding the 64-bitness of
> capability sets. It may well be a very long time before we increase
> their size, but couldn't you prepare for that with some reference to
> the prevailing magic numbers for the current ABI representation?

Yes, please, use BUILD_BUG_ON or something
