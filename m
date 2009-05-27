From: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Wed, 27 May 2009 11:52:17 -0700
Message-ID: <1243450337.8071.155.camel__19655.3342896097$1243450481$gmane$org@nimitz>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-05-26 at 23:35 +0400, Alexey Dobriyan wrote:
> The other part, is that I looked at Oren patchset, found quite a lot of
> suspicious, broken and unclean places and decided that it'd be faster
> to start from scratch because sending patches will overhaul like 85% of
> the code.

I know the feeling.  I get sudden urges to rewrite the whole patch set,
but I'm working on getting past them too. :)

As long as we have two patch sets, *nobody* is going to get their
patches in, that's virtually guaranteed.  Just look at the poor I/O
controller.

The OpenVZ users are almost certainly the most important container and
c/r users out there today.  Meeting their needs with whatever we come up
with should be a top priority and I know I'm counting on you to help us
do that.

But, I'm having a really hard time culling the OpenVZ user needs from
your patch set.  If we really need to rewrite 85% of Oren's stuff to
meet the OpenVZ needs, then by all means let's do it.  I'm even willing
to help you.  But, I honestly don't know what you need.

Can we talk about specifics?

-- Dave
