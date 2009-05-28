From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 11:00:57 -0700
Message-ID: <20090528180057.GA27191@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528151444.GA17772@us.ibm.com>
	<20090528170103.GA26183@us.ibm.com>
	<20090528174708.GA2236@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090528174708.GA2236-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org] wrote:
| 
| If a container at pidns level 2, with 1 more pidns underneath it,
| is checkpointed, then the checkpoint image should only reflect
| the base and child pidns.  The two ancestor pidns levels should
| not be there.

Agree. I meant to say that we would need to specify more than 2
pids when checkpoint/restarting apps with deeply nested namespaces
if any :-)

Specifying bottom-up may solve the problem I guess.
