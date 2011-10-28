From: Adrian Reber <adrian-5+Cda9B46AM@public.gmane.org>
Subject: Re: linux-cr ported to 3.1
Date: Fri, 28 Oct 2011 14:52:19 +0200
Message-ID: <20111028125219.GZ20908@lisas.de>
References: <20111027142731.GT20908@lisas.de>
	<20111027144125.GA14452@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111027144125.GA14452-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 27, 2011 at 02:41:25PM +0000, Serge E. Hallyn wrote:
> Quoting Adrian Reber (adrian-5+Cda9B46AM@public.gmane.org):
> > 
> > I  have ported the linux-cr patches from www.linux-cr.org/pub/git/linux-cr.git
> > to the latest kernel (3.1). What I have tested so far it still seems to work.
> 
> Wow, that's great!
> 
> Since you went to the trouble of doing this, can we assume you have a pretty
> strong interest in this set? :)  If so, 

Yes, I have.

> > Can anybody tell me what the latest state of these patches was?
> > Development seemed to have stopped after 2.6.37 and with the wiki[1] being
> > down I do not know if anybody is still working on these patches. What
> 
> Matt and Dan, if there is outside interest, are you able to help out at
> all?  Are you still using this set at all?
> 
> Oren, what's your status?
> 
> > was the latest status about those patches being integrated into
> > mainline? Is someone still trying to get it included?
> 
> There is a new upstream effort based around pushing smaller debugging-style
> patches, which rather than adding a 'sys_checkpoint' syscall, allow userspace
> to get the information they need to reconstruct a process set.  Several people,
> Daniel (Cc:d) included, seem to prefer this approach.  See
> http://lwn.net/Articles/452184/ for instance.
> 
> You might peruse the recent lkml threads (and the above article).  If you are
> ok with that approach, you might consider joining them.  AFAICS they've not
> done much in the last few months, though I may just have missed it.

I interested in whatever approach works best. I just choose the linux-cr
tree because it seemed to be the most recent development and it worked.

		Adrian
