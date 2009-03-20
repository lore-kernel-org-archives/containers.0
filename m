From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 17/23] Record 'struct file' object instead
	of the file name for VMAs
Date: Fri, 20 Mar 2009 18:02:27 -0400
Message-ID: <49C41273.5000202@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>	
	<1237574868-3371-18-git-send-email-orenl@cs.columbia.edu>	
	<1237582675.8286.281.camel@nimitz>
	<49C40893.1060602@cs.columbia.edu>
	<1237584650.8286.310.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237584650.8286.310.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Fri, 2009-03-20 at 17:20 -0400, Oren Laadan wrote:
>> What you suggest will reverse the order ... so while we expect to find
>> a vma, we'll find a file object. I'm wonder if it's worth changing the
>> format and logic for this.
> 
> It makes logical sense to me to do this.  You depend on the file to
> create the VMA.  It makes sense to see dependencies before the object
> that is doing the depending.
> 
> -- Dave
> 

Or: you look at the vma header to know that you depend on the file...
(not that I really care how logic reads)

Anyway, the down side that I was hoping to avoid on restart, is to need
to expect "either...or" values of 'struct cr_hdr'->type instead of a
single deterministic value. That's the extra burden that I was referring
to.

Oren.
