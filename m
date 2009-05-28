From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Thu, 28 May 2009 13:17:15 -0500
Message-ID: <20090528181715.GA2384__16879.0067117245$1243534402$gmane$org@hallyn.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<20090526234436.GB23806@hallyn.com>
	<20090528153852.GC18256@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090528153852.GC18256-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> On Tue, May 26, 2009 at 06:44:36PM -0500, Serge E. Hallyn wrote:
> > Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > > And since you guys showed that just idea of in-kernel checkpointing is not
> > > rejected outright, it doesn't mean that you can drag every single idea too.
> > 
> > Can you rephrase here?  I have no idea what you mean by 'drag every single
> > idea'
> 
>   									complexity
>  +-|------------------------------------------------|----------------------|-->
> hypervisor C/R					in-kernel C/R	C/R for unpriviledged
> 								C/R with "leaks"
> 
> I personally thought in-kernel C/R will be rejected outright, but it wasn't.
> This in theory doesn't mean other two issues should be accepted.

Note again that leaving c/R unprivileged was suggested (By Arnd)
as a way to keep us on our toes.  When it actually goes upstream
I would prefer it be under a new CAP_CHECKPOINT_RESTART capability,
not CAP_SYS_ADMIN.

-serge
