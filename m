From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: define s390-specific checkpoint-restart code (v5)
Date: Tue, 24 Feb 2009 15:49:27 -0600
Message-ID: <20090224214927.GA29993@us.ibm.com>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
	<1235500639-9597-3-git-send-email-danms@us.ibm.com>
	<20090224193737.GB24007@us.ibm.com>
	<1235504805.26788.298.camel@nimitz>
	<20090224200430.GA26259@us.ibm.com>
	<1235510471.26788.317.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1235510471.26788.317.camel@nimitz>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Tue, 2009-02-24 at 14:04 -0600, Serge E. Hallyn wrote:
> > OTOH I'm not eager to make such a change right now only to find
> > months later that there was a good reason to keep it in the hdr
> > after all  :)
> 
> The thing that bothers me about all of these things is that we can't
> truly evaluate them on their merits because we can't see how they are
> expected to be used in the future.  Surely there are multiple ways we
> can implement details of the incremental checkpoint.
> 
> -- Dave

Oh I think that was a bogus guess on my part anyway.

Like I say I don't want to encourage churn for the sake of churn
at this point, but you've got me thinking that moving parent into
the details and giving it a more useful name could *really*
dilute some of the mystery in these patches.

It's sounding good to me...

-serge
