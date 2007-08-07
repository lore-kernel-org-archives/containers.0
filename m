From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC, PATCH] handle the multi-threaded init's exit() properly
Date: Tue, 7 Aug 2007 00:32:28 -0700
Message-ID: <20070807003228.60d047b4.akpm@linux-foundation.org>
References: <20070802212009.GA516@tv-sign.ru>
	<20070806131345.3322c99e.akpm@linux-foundation.org>
	<20070806203326.GA188@tv-sign.ru>
	<20070806221824.22a78312.akpm@linux-foundation.org>
	<20070807063431.GB23036@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757989AbXHGHdm@vger.kernel.org>
In-Reply-To: <20070807063431.GB23036@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Oleg Nesterov <oleg@tv-sign.ru>, "Eric W. Biederman" <ebiederm@xmission.com>, Roland McGrath <roland@redhat.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Mon, 6 Aug 2007 23:34:31 -0700 sukadev@us.ibm.com wrote:

> | The downside of this approach is that
> | handle-the-multi-threaded-inits-exit-properly.patch looks more 2.6.24-ready
> | than all the container stuff (based just on overall impact and
> | speculativeness)
> 
> Well, if it will help, we can drop these two patches from -mm, take Oleg's
> patch and I can then resend these along with other pid ns patches. 
> 
> 	pid-namespaces-define-and-use-task_active_pid_ns-wrapper.patch.
> 	pid-namespaces-rename-child_reaper-function.patch

I'm reasonably sure that what I ended up with is OK.  I'll send those two
out again for double-checking, please.
