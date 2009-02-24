From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: define s390-specific checkpoint-restart code (v5)
Date: Tue, 24 Feb 2009 11:46:45 -0800
Message-ID: <1235504805.26788.298.camel@nimitz>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
	<1235500639-9597-3-git-send-email-danms@us.ibm.com>
	<20090224193737.GB24007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224193737.GB24007-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-02-24 at 13:37 -0600, Serge E. Hallyn wrote:
> 
> > +/* dump the cpu state and registers of a given task */
> > +int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
> > +{
> > +     struct cr_hdr h;
> > +     struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
> > +     int ret;
> > +
> > +     h.type = CR_HDR_CPU;
> > +     h.len = sizeof(*hh);
> > +     h.parent = task_pid_vnr(t);
> 
> BTW - I know Dave mentioened using a generic helper for this
> often-used stanza above, but I continue to be against that
> bc the helper ends up having to take a bunch of eye-numbing
> arguments and I think the code ends up hard to read.  But
> maybe you can think of a way to make that clearer...

Yeah, that's true.  The plethora of types also makes it hard to do with
a function.  For plain readability you can't beat what we already have
there.

But, I do still wonder why we need the .parent member in the cr_hdr
itself.  Shouldn't that be something that gets pushed down to where we
can actually describe it, like in the cr_hdr_foo structures?

-- Dave
