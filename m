From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Deny external checkpoint unless frozen
Date: Mon, 23 Feb 2009 17:18:03 -0800
Message-ID: <1235438283.26788.219.camel@nimitz>
References: <20090221201317.GB13532@us.ibm.com>
	<20090223230438.GA2590@us.ibm.com> <1235435947.26788.216.camel@nimitz>
	<20090224010945.GA4797@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224010945.GA4797-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-02-23 at 19:09 -0600, Serge E. Hallyn wrote:
> 
> > > Agreed.  I personally would like to just get rid of support
> > > for t==current, but don't expect to get anywhere with that
> > > argument :)
> > 
> > Along the lines of what Ingo has been asking for, do we need to expose
> > this logic in some way?  Do we need a /proc/$$/checkpointable file which
> > says, "I'm not checkpointable because I'm not frozen"?
> 
> I really like that.
> 
> > Or, is this just a core part of the API: you have to freeze before
> > checkpointing?  As such, we'll never move to a place where we're not
> > frozen when checkpointing, so we might as well not even track or expose
> > it.  
> 
> the only way that would make sense is if sys_checkpoint went ahead
> and frozen them all, right?

Yeah, I agree with that.

Does this mean Suka has to do the patch? ;)

-- Dave
