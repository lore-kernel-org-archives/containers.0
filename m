From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Skip down interfaces (v2)
Date: Thu, 01 Apr 2010 08:49:53 -0700
Message-ID: <87sk7fcgv2.fsf@caffeine.danplanet.com>
References: <1270052634-8170-1-git-send-email-danms@us.ibm.com>
	<4BB4BA26.1050707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BB4BA26.1050707-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Thu\,
	01 Apr 2010 11\:22\:14 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

BH> But devices that are not IFF_UP can still have addresses
BH> associated with them, wouldn't this cause those addresses to not
BH> be checkpointed?

Yes.  This was discussed on IRC a bit as being a reasonable
compromise.  Right now, there are several pernet devices that could
show up in a new network namespace that will prevent a checkpoint from
completing.  Since you can't easily, and at runtime, get rid of these
devices without recompiling the kernel, you're kinda stuck.  So, we
discussed this as something that will let you out of that situation
for interfaces that are down.

We could, I suppose, inspect the interfaces a bit to see if they have
any addresses configured before we agree to skip them.  However, that
could falsely trigger a failure because of autoconf addresses, I would
think.

The plan is to have a "strict mode" flag that will attempt to
checkpoint and fail on down but unsupported interfaces to make sure we
don't save an inaccurate representation of the netns that the
application is in.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
