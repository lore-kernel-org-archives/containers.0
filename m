From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Clear the objhash before completing restart,
	but delay free until later
Date: Mon, 18 Oct 2010 08:03:13 -0700
Message-ID: <87eibnr1am.fsf@caffeine.danplanet.com>
References: <1287156039-31496-1-git-send-email-danms@us.ibm.com>
	<20101017225507.GA10119@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101017225507.GA10119-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org> (Matt Helsley's
	message of "Sun\, 17 Oct 2010 15\:55\:07 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

MH> If we postpone clearing the object hash until restart returns to
MH> userspace there can be a race where the restarted tasks behave
MH> differently due to the references held by the objhash.  One
MH> specific example of this is restarting half-closed pipes.  Without
MH> this patch we've got a race between the coordinator -- about to
MH> clear the object hash -- and two restarted tasks connected via a
MH> half-closed pipe. Because the object hash contains a reference to
MH> both ends of the pipe one end of the pipe will not be closed and
MH> EPIPE/SIGPIPE won't be handled when the reading from the pipe for
MH> instance. As far as the restarted userspace task can tell the pipe
MH> may briefly appear to re-open. Moving the object hash clear
MH> prevents this race and others like it.

MH> Note that eventually the coordinator would close the pipe and
MH> correct behavior would be restored. Thus this bug would only
MH> affect the correctness of userspace -- after a close() the pipe
MH> may briefly re-open and allow more data to be sent before
MH> automatically closing again.

Sure, this sounds fine and I'll be glad to put it into the patch
header.

MH> You might simplify this by making the queue portion into a
MH> separate patch. Then we can discuss that independently of moving
MH> the objhash clear call.

Hmm, I'm not sure what you mean exactly.  The only thing in the patch
other than the queue, is the one-line additional call to _clear().
Without the additional call, the queue is nothing but overhead...

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
