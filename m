From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/17] ckpt_write_err: use single format with %(T)
	style tokens
Date: Fri, 30 Oct 2009 08:33:29 -0500
Message-ID: <20091030133329.GA9138@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<1256849682-858-2-git-send-email-serue@us.ibm.com>
	<20091030063712.GA409@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091030063712.GA409-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | 
> | Matt Helsley originally suggested this to avoid having two
> | format strings.  This is not bisect-safe and therefore not
> | even compile-tested.  Every call to ckpt_write_err must be
> | updated to use a single format.
> 
> It maybe easier to review this patch if this is broken up into smaller
> patches:
> 
> 	- move the code to new place
> 	- leave the fmt0 parameter to ckpt_generate_fmt() but ensure it
> 	  is unused.
> 	- finally remove the unused parameters from ckpt_generate_fmt()
> 	  and the callers. 

That's going a bit far...  I did leave the moving of the code in a separate
patch up until this last posting, but the new and old versions of
ckpt_generate_fmt() don't look alike enough to be able to compare side by
side anyway imo.

One thing which would help however imo would be if I keep a non-rebased
tagged tree alongside the rebased tree, so you can see what changes I'm
making over the last posting.  I'll do that as of today.

-serge
