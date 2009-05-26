From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Tue, 26 May 2009 18:44:36 -0500
Message-ID: <20090526234436.GB23806__20466.2033626393$1243382167$gmane$org@hallyn.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090526193503.GB11909-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> And since you guys showed that just idea of in-kernel checkpointing is not
> rejected outright, it doesn't mean that you can drag every single idea too.

Can you rephrase here?  I have no idea what you mean by 'drag every single
idea'

> Because history shows, that once something (especially user-visible,
> like restart syscall semantics) is in kernel it's nearly impossible
> to cut it out, so it's very-very important to get it right from the very
> beginning.

Absolutely agree (at least in terms of the API for sys_restart() and
sys_checkpoint(), not for inane other stuff like whether there is a
CKPT_OBJ_RESTART_BLOCK).  That is why 6 months ago we were trying to
get to an agreement with Andrey Mirkin about a precise API that would
definately suit both approaches (in-kernel and userspace task recreation
at sys_restart).  That way the basics could go upstream and the rest
could get settled later as we see the fallout from either decision.

-serge
