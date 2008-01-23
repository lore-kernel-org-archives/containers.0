From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: OLS paper topics
Date: Wed, 23 Jan 2008 13:57:36 -0600
Message-ID: <20080123195736.GA7823@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

here is a list of topics which I believe people are interested in
writing papers on.  I'm listing names of those who I think are
interested in writing them.  Sorry if I leave anyone off of a topic
they're interested in.  However it seems to me it would be best if we
can agree on one person or two people to drive each topic, so everyone
doesn't sit around expecting someone else to submit the abstract.

Am I missing any?

mini-summit:
	I will submit for a 1-day mini-summit.  Some interesting
	remaining topics for the mini-summit would include device
	namespaces, ttys and syslog, and lots of checkpoint/restart.

	Does anyone think we don't need one of these at ols?  Or that
	we do?

	Is anyone interested in organizing the summit - coming out
	with an agenda, sending out announcements, etc - either
	alone or with my help?

pidns: (Pavel and Suka)
	I've heard it called a tutorial, though I think some of the
	technical details are interesting in and of themselves.  Its
	also an important area to make sure other developers - i.e
	people working with flocks or kthreads - understand.
	netns: denis driving, daniel, benjamin

namespaces status: Pavel and Cedric
	There was no ns status update last year it may be of
	interest.  Instead of a separate pidns paper, pidns could
	also be mentioned here.

namespace entering: Cedric and serge?
	This *probably* isn't enough for a full paper.  So it could
	go under namespace status paper.  But there is quite a bit
	to say just by listing the existing proposed solutions (at
	least 4 I can think of offhand) and their shortcomings.

memory c/r: Dave Hansen, serge interested
	I suspect many people on this list have their own ideas on
	how to go about the checkpoint and restart.  I suppose they
	could each write their own paper, or work together on a single
	combined paper laying out the possibilities

user namespace approaches: serge

cgroups and containers: Paul Menage driving?, Balbir?
	A cgroups update could either be its own paper or joined
	with the namespaces status paper.
	
	Paul were you considering a separate paper to discuss
	the cgroups and namespace management as laid out in
	your Sep 03 2007 email "Thoughts on Namespace / Subsystem
	unification"?

thanks,
-serge
