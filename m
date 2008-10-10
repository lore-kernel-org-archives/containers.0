From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 12:27:50 +0200
Message-ID: <48EF2E26.3020200__14641.0809401006$1223634804$gmane$org@fr.ibm.com>
References: <20081009190405.13A253CB@kernel>	<20081009190406.1B257119@kernel>
	<20081009194350.GA31214@us.ibm.com>
	<1223585671.11830.40.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1223585671.11830.40.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Thu, 2008-10-09 at 14:43 -0500, Serge E. Hallyn wrote:
>> Hmm, I don't know too much about aio, but is it possible to succeed with
>> io_getevents if we didn't first do a submit?  It looks like the contexts
>> are looked up out of current->mm, so I don't think we need this call
>> here.
>>
>> Otherwise, this is neat.
> 
> Good question.  I know nothing, either. :)
> 
> My thought was that any process *trying* to do aio stuff of any kind is
> going to be really confused if it gets checkpointed.  Or, it might try
> to submit an aio right after it checks the list of them.  I thought it
> best to be cautious and say, if you screw with aio, no checkpointing for
> you!

IMO, the right path would be to deny checkpoint if you have aio requests
pending but if you have not, aio's are not an issue for checkpoint anymore.

but that's one easy one to track ...

C.
