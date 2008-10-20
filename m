From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Mon, 20 Oct 2008 08:55:05 -0700
Message-ID: <1224518105.1848.93.camel__12294.1594491296$1224536481$gmane$org@nimitz>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1224286383.1848.65.camel@nimitz> <200810201614.36911.major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810201614.36911.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-10-20 at 16:14 +0400, Andrey Mirkin wrote:
> Right now my patchset (v2) provides an ability to checkpoint and restart a 
> group of processes. The process of checkpointing and restart can be initiated 
> from external process (not from the process which should be checkpointed).

Absolutely.  Oren's code does it this way to make for a smaller patch at
first.  The syscall takes a pid argument so it is surely expected to be
expanded upon later. 

> Also I think that all the restart job (including process forking) should be 
> done in kernel, as in this case we will not depend on user space and will be 
> more secure. This is also implemented in my patchset.

Do you think that this is an approach that Oren's patches are married
to, or is this a "feature" we can add on later?

I don't care which patch set we end up sticking in the kernel.  I'm
trying to figure out which code we can more easily build upon in the
future.  The fact that Oren's or yours can't do certain little things
right now does not bother me.

Honestly, I'm a little more confident that everyone can work with Oren
since he managed to get 7 revisions of his patch out and make some
pretty large changes while in the same time the OpenVZ patch was only
released twice.  I'm not sure what has changed in the OpenVZ patch
between releases, either.

Are there any reasons that you absolutely can not use the code Oren
posted?  Will it not fulfill your needs somehow?  If so, could you
please elaborate on how?

-- Dave
