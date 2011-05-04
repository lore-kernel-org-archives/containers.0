From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R PATCH] reject checkpoint of fd subject to F_SETSIG
Date: Wed, 04 May 2011 00:53:30 -0400
Message-ID: <4DC0DBCA.4060309@cs.columbia.edu>
References: <1304112454-24641-1-git-send-email-ntl@pobox.com>	<20110502131824.GC9375@mail.hallyn.com>	<1304361296.6609.22.camel@tp-t61>	<20110502185448.GA32506@mail.hallyn.com>
	<20110503184031.GD8093@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110503184031.GD8093-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



On 05/03/2011 02:40 PM, Sukadev Bhattiprolu wrote:
> Serge Hallyn [serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org] wrote:
> | Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> | > On Mon, 2011-05-02 at 08:18 -0500, Serge Hallyn wrote:
> | > > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> | > > > Similar to our handling of fds that have been subject to F_SETOWN,
> | > > > detect when an fd has had its f_owner->signum changed from the
> | > > > default.
> | > > > 
> | > > > Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> | > > 
> | > > Hey Nathan,
> | > > 
> | > > Can you give more motivation for this?  Do you just feel that it
> | > > isn't worth the risk of mis-coding the check at restart?
> | > 
> | > The principle here is that we should try to catch at checkpoint time
> | > that which we don't handle correctly at restart.  Right now checkpoint
> | > apparently succeeds, but doing a fcntl(F_GETSIG) after a restart will
> | > show that the signal set before checkpoint has not been preserved.
> | 
> | Really?  I thought for sure Suka had addressed that.
> 
> I did post patches for C/R of file owner (along with file locks), but
> don't believe they were merged.  IIRC, the file-owner patches were
> blocked on the struct pid changes.

Suka: the pid-as-objects changes are now stable and included in the
tree. What would it take to get the file-owner patches working on it ?

> | 
> | So if you don't mind, please add 'because we do not reset it at restart'
> | to the end of your description?
> | 
> | > > For safety check, what about forcing such a task to be restarted
> | > > in a private pidns?
> | > 
> | > Sorry, I'm not making the connection between this concern and F_SETSIG
> | > and F_GETSIG.  
> | 
> | The signal signum will only be sent to the task identified, by pid,
> | as the owner.  If we weren't doing things right at restart, then
> | a malicious restarter could cause any signal to be sent to a pid
> | which it shouldn't be able to kill.
> 
> We tried to have reset() use the same interface as the original fcntl()
> so we would do the same permssion checks.
> 
> But for F_SETSIG, there are no permission checks during fcntl(). 
> 
> The permission checks are done at the time of actually sending the signal,
> so even if restart says SIGKILL, it will not necessarily be delivered ?

Sounds ok to me. 

Thanks,

Oren.
