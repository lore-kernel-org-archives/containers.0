From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/5] Add a ckpt_read_string() function to allow reading
	of a	variable-length (but length-capped) string from the checkpoint
	stream.
Date: Thu, 23 Jul 2009 21:32:16 -0400
Message-ID: <4A690F20.4080508@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>	<1248295301-30930-4-git-send-email-danms@us.ibm.com>	<4A67E4EC.3070509@librato.com>
	<87y6qfnxoq.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y6qfnxoq.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> You can avoid the memcpy() if you first read only the header, allocate
> OL> the string, and then read data into it.
> 
> I've changed it to a _ckpt_read_obj_type(.., NULL, ..) and a
> ckpt_kread() to avoid the memcpy().
> 
> OL> On top of this you can have ckpt_read_string() that will verify that
> OL> the buffer is of non-zero length and null terminated ?
> 
> What I had ensured a null-terminated string (kzalloc() and len+1). 

Of course: that's what _ckpt_read_obj_string() does, and why I
suggested ckpt_read_string(), otherwise it's redundant.

> 
> Is this really the appropriate place to ensure that the string is
> non-zero length?  Maybe not in the realm of paths and socket names,
> but I can see other places where writing a zero-length string might be
> appropriate...

I used the term "buffer":  a zero-length string is a buffer of length 1.
A zero-length buffer becomes (e.g. empty pipe buffer) causes no allocation
and returns a NULL pointer. Callers that deal with strings will likely
not expect this behavior.

Thanks,

Oren.
