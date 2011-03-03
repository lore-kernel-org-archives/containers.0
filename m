From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Payloads and transient filesystem support for user-cr
Date: Thu, 03 Mar 2011 10:30:48 -0800
Message-ID: <878vww83af.fsf@caffeine.danplanet.com>
References: <1299101725-17603-1-git-send-email-danms@us.ibm.com>
	<4D6EBF24.4000601@free.fr> <877hch6oi2.fsf@caffeine.danplanet.com>
	<4D6F52DF.1040808@free.fr> <87vd005ks5.fsf@caffeine.danplanet.com>
	<4D6FDB71.7050603@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6FDB71.7050603-GANU6spQydw@public.gmane.org> (Daniel Lezcano's message of "Thu, 03
	Mar 2011 19:18:25 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

DL> Don't blame them. They may have missed the test case but you missed
DL> the CR of the posix semaphore, far away from a couple of parsecs ;)

I'm not sure I follow that one.  Any apps that had the semaphore open
before checkpoint still have it and it behaves as it should.  Any app
that opens the semaphore after checkpoint works just fine as well.  The
only problem is between two apps, one that opened it before and one that
opens it after the c/r cycle.  The semaphores are no longer "the same".

But, as I said, that's not something we can solve without the unlinked
bits (which aren't finished yet).  Aaaand, as I said, this doesn't work
for linux-cr yet for other reasons, so nobody is asking Oren to apply
this set yet anyway.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
