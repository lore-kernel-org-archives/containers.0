From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Fri, 29 May 2009 10:26:27 -0700
Message-ID: <1243617988.14679.69.camel__24193.9008389183$1243618086$gmane$org@nimitz>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<4A1DA8FB.3000306@cs.columbia.edu>
	<20090527221753.GB8321@x200.localdomain>
	<4A1DC270.8080807@cs.columbia.edu>
	<20090528153322.GB18256@x200.localdomain>
	<4A1F0E29.2040506@cs.columbia.edu>
	<20090529060131.GA5504@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529060131.GA5504-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-05-29 at 10:01 +0400, Alexey Dobriyan wrote:
>                 if (ctx->dump_live)
>                         down_read(&uts_sem);
>                 strncpy(i->sysname, (const char *)uts_ns->name.sysname, 64);
>                 strncpy(i->nodename, (const char *)uts_ns->name.nodename, 64);
>                 strncpy(i->release, (const char *)uts_ns->name.release, 64);
>                 strncpy(i->version, (const char *)uts_ns->name.version, 64);
>                 strncpy(i->machine, (const char *)uts_ns->name.machine, 64);
>                 strncpy(i->domainname, (const char *)uts_ns->name.domainname, 64);
>                 if (ctx->dump_live)
>                         up_read(&uts_sem);

Doesn't this turn a minor bug (like a task getting accidentally
unfrozen) into a oopsable bug?

I mean, doing this without a lock is nice and all, but it adds code to
make it selectable.  What's the purpose of avoiding the semaphore
anyway?  Performance?

-- Dave
