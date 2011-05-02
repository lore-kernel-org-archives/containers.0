From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [C/R PATCH] reject checkpoint of fd subject to F_SETSIG
Date: Mon, 02 May 2011 13:34:56 -0500
Message-ID: <1304361296.6609.22.camel@tp-t61>
References: <1304112454-24641-1-git-send-email-ntl@pobox.com>
	<20110502131824.GC9375@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110502131824.GC9375-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2011-05-02 at 08:18 -0500, Serge Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > Similar to our handling of fds that have been subject to F_SETOWN,
> > detect when an fd has had its f_owner->signum changed from the
> > default.
> > 
> > Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> Hey Nathan,
> 
> Can you give more motivation for this?  Do you just feel that it
> isn't worth the risk of mis-coding the check at restart?

The principle here is that we should try to catch at checkpoint time
that which we don't handle correctly at restart.  Right now checkpoint
apparently succeeds, but doing a fcntl(F_GETSIG) after a restart will
show that the signal set before checkpoint has not been preserved.


> For safety check, what about forcing such a task to be restarted
> in a private pidns?

Sorry, I'm not making the connection between this concern and F_SETSIG
and F_GETSIG.  
