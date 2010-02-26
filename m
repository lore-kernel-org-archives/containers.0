From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/4] cr_tests/ptree1: wait for background tasks to exit
Date: Fri, 26 Feb 2010 15:03:00 -0600
Message-ID: <1267218180.15300.120.camel@localhost.localdomain>
References: <1267213914-32219-1-git-send-email-ntl@pobox.com>
	<1267213914-32219-3-git-send-email-ntl@pobox.com>
	<20100226205659.GE20106@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100226205659.GE20106-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2010-02-26 at 12:56 -0800, Matt Helsley wrote:
> On Fri, Feb 26, 2010 at 01:51:53PM -0600, Nathan Lynch wrote:
> > It is more reliable and usually faster to wait for the shell's
> > notification that background tasks have exited than it is to assume
> > they have exited after three seconds have passed.
> 
> Yes, a wait should normally do the trick here.
> 
> What happens if thaw fails and the task to wait for is still frozen?
> We'd need a "wait or timeout" here to gracefully handle that. However,
> I suppose it's arguable whether thaw failing is worth worrying about
> here...

I think it's not, unless this scenario could occur in the absence of
kernel or testcase bugs?
