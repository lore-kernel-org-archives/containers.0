From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: LTP result output for container-init
Date: Wed, 16 Jan 2008 09:31:58 -0800
Message-ID: <20080116173158.GA19456@us.ibm.com>
References: <1200497268.3999.17.camel@localhost.localdomain>
	<1200502497.22674.163.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1200502497.22674.163.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Poornima.Nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen [haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| On Wed, 2008-01-16 at 20:57 +0530, Rishikesh K. Rajak wrote:
| > These failures are conceding with 2.6.23-mm1 itself. Just wanted to
| > know if someone is working on this still.

I think Rishi is referring to these failures when running LTP in
a child pid namespace. That is a known problem. Its not a regression
but a pending task in pid namespace cleanup.

| > 
| >   fcntl11                        FAIL
| >   fcntl14                        FAIL
| >   fcntl17                        FAIL
| >   fcntl19                        FAIL
| >   fcntl20                        FAIL
| >   fcntl21                        FAIL
| 
| Do you mean that these are happening with 2.6.23-mm1, even without any
| lxc patches?
| 
| Have you reported these to LKML or to Andrew Morton?  If not, please do.
| You can make sure to garner attention by putting something like,
| 
| 	2.6.23-mm1 fcntl regressions
| 
| as the subject.  But, please do make sure they're regressions, and
| pinpoint the versions where they occur.  You should also be prepared to
| do a bisection of the patches in -mm to find it.
| 
| -- Dave
