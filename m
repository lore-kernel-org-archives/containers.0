From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 24/29] c/r: Add CR_COPY() macro (v4)
Date: Thu, 2 Apr 2009 14:06:12 -0500
Message-ID: <20090402190612.GA24390@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-25-git-send-email-orenl@cs.columbia.edu>
	<20090401232013.GA31361@us.ibm.com>
	<87vdpmnan2.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vdpmnan2.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> SH> #define CR_COPY_ARRAY(op, SAVE, LIVE, count)				\
> SH> 	do {								\
> SH> 		__must_be_array(SAVE);					\
> SH> 		__must_be_array(LIVE);					\
> SH> 		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
> SH> 		if (op == CR_CPT)					\
> SH> 			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
> SH> 		else							\
> SH> 			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
> SH> 	} while (0)
> 
> SH> Putting the __must_be_array()s inside the condition seems really weird.
> 
> I thought I explained this somewhere.  You'll get a compile warning if

Oh, probably on irc...

> you make __must_be_array() a statement without an lvalue.  If you try
> to stuff the result into a variable that you don't use, you'll get a
> warning about an unused variable.  I did what I did because it seemed
> like a sane way to sidestep both of those issues.
> 
> Maybe a comment is warranted? :)

That's sucky...  yeah i would say a comment, though of course it could
be one of those cases where everyone but me already knows...

-serge
