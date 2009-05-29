From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Fri, 29 May 2009 10:06:16 -0700
Message-ID: <20090529170616.GA12597@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528173019.GB26183@us.ibm.com>
	<4A1F228C.2020201@cs.columbia.edu>
	<20090529030558.GA2548@us.ibm.com>
	<4A1F72A1.4070103@cs.columbia.edu>
	<20090529054645.GA3344@us.ibm.com>
	<4A1F78AF.6030404@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1F78AF.6030404-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

| > | I should have mentioned earlier, but there is also the case of
| > | CLONE_NEWPID. If CLONE_NEWPID is given, then @nesting should be
| > | plus one, _and_ the corresponding pid must be 1 or 0.
| > 
| > Right. do_fork_with_pids() checks if CLONE_NEWPID is specified with
| > target_pids and returns -EINVAL for now.
| 
| Any reason not to handle this case already ?

The only reason was that we are not planning on supporting C/R of
nested containers for a while, but yes, we don't need to restrict
clone_with_pids().

| 
| I have a simpler suggestion than above: pass the clone_flags to
| copy_target_pids(), and in there, if CLONE_NEWPID is set, then
| you should allocate an array +1 in size, and force last slot to
| be 0 (or 1). User doesn't have to pass a larger array.

Looks like it would be cleaner code-wise, to always allocate an
extra element in the target_pids list and leave the last one set
to 0. If CLONE_NEWPID is set, alloc_pid() will assign the first pid
in the new namespace. If it is not set, the last element will never
be referenced in alloc_pid().
