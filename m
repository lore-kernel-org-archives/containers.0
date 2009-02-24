From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: define s390-specific checkpoint-restart code (v5)
Date: Tue, 24 Feb 2009 14:09:39 -0600
Message-ID: <20090224200939.GB26259@us.ibm.com>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
	<1235500639-9597-3-git-send-email-danms@us.ibm.com>
	<20090224193737.GB24007@us.ibm.com>
	<87k57flib8.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k57flib8.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >> +struct cr_hdr_cpu {
> >> +	__u64 args[1];
> 
> SH> Dave wanted this to not be an array, right?
> 
> I think he was okay with it since it matched what is in the rest of
> the s390 code.  I think that the use of the CR_COPY() macros makes it
> nicer to have matching types as closely as possible.

Ok with me.  Dave can speak up if he needs to :)

> >> +	union {
> >> +		float f;
> >> +		double d;
> >> +		__u64 ui;
> 
> SH> Since this is a union, and you don't deal with its members but
> SH> just memcpy it, why not just change it to
> 
> That's a fair argument, although I was thinking that there was some
> expectation of being able to include this in userspace at some point
> to inspect the contents of the CR stream.  The #ifdef __KERNEL__ at
> the top of the file makes me think that's true.  If so, does it make
> sense to leave this as-is for easier inspection of the contents?

But what is userspace supposed to gain from seeing that in the
headers?  No matter how many other ways we represent the data
containined in a fprs union, all we know based on the checkpoint
image is what the size of NUM_FPRS*sizeof(*fprs) is, right?

Or do you mean the programmers will see that and be able to tell
more easiliy where in ptrace.h the corresponding union is?

-serge
