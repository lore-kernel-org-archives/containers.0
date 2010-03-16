From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/10] cr_tests: Add dry-run
Date: Mon, 15 Mar 2010 23:25:50 -0700
Message-ID: <20100316062550.GE3037@count0.beaverton.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<1268695941.4397.135.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268695941.4397.135.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 06:32:21PM -0500, Nathan Lynch wrote:
> On Mon, 2010-03-15 at 16:01 -0700, Matt Helsley wrote:
> > Make the cgroup freezer and do_ckpt() no-ops in order to do dry-runs of the
> > tests. This allows us to establish a baseline for those tests that can do
> > dry-runsi (i.e. have a dry-run option and use it to avoid restarting checkpoint
> > images).
> 
> I like this idea and I think this will be useful.
> 
> However, is there a reason we shouldn't freeze and thaw as part of the
> dry run?  I don't have strong feelings on this; just thinking we should
> try to minimize the differences in behavior and code coverage.

Well, honestly my main reason was lazyness :). Also, the goal was to make
those portions of the testcases which should be like no-ops actually be
no-ops. Then we know the test case is very likely testing the feature 
(e.g. eventfd) we want and not some prepatory step needed for checkpoint.

But your point is reasonable. We may want to know that the tests are frozen/
thawed correctly without doing checkpoint. It also probably requires fewer
changes so I think, at least as a first step I'll go with your suggestion.

Again, I'll reply with the changed patch rather than repost the series
unless someone tells me they'd prefer otherwise.

Cheers,
	-Matt Helsley
