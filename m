From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Kernel Summit Discussion Checkpoint/Restart
Date: Sun, 03 Aug 2008 13:14:50 -0700
Message-ID: <1217794490.20260.75.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren and Andrey,

Would you mind sending your patches to LKML as well when you send them?
Ted's suggestion sounds like a good one to me: it would nice to have
some vetting of the ideas before the kernel summit.

-------- Forwarded Message --------
From: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
To: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: ksummit-2008-discuss-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: Re: [Ksummit-2008-discuss] Suggested Topic: Checkpoint/Restart
design
Date: Sun, 3 Aug 2008 07:57:02 -0400

On Fri, Aug 01, 2008 at 12:19:50PM -0500, Serge E. Hallyn wrote:
> It may be getting late to propose agenda items, but this one could
> be very short.  At the checkpoint/restart part of the containers
> mini-summit at OLS, it was generally agreed that a mostly kernel-
> orchestrated checkpoint and restart, using new system calls
> sys_checkpoint() and sys_restart(), would be the best design and
> most likely to be accepted upstream.  
> 
> An example of a first patchset is at
> https://lists.linux-foundation.org/pipermail/containers/2008-July/012046.html
> 
> Such patches will hopefully hit lkml pretty soon....

I'd strongly recommend sending patches and a description of what is
motivating checkpoint/restart to LKML very soon.  Until we find out
the general LKML reaction, it's hard for us to decide whether or not
it should be a topic for the kernel summit.  Obviously, it's far more
useful if people have a chance to absorb the idea and contemplate the
code far in advance of the kernel summit.  Hitting folks with the idea
for the first time at the summit is not going to be helpful; and
please keep in mind that having an idea spring forth fully formed from
the belly of a non-LKML mailing list has not worked all that well in
the past....

    	      	      	  	    	      - Ted
_______________________________________________
Ksummit-2008-discuss mailing list
Ksummit-2008-discuss-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/ksummit-2008-discuss
-- Dave
