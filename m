From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 09:24:55 -0700
Message-ID: <1237393495.8286.161.camel@nimitz>
References: <20090317062754.GA2377@us.ibm.com>
	<20090317063940.GF2377@us.ibm.com> <49C0B6FF.5030104@cs.columbia.edu>
	<20090318135953.GE22636@us.ibm.com> <49C11E61.4010505@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C11E61.4010505-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-03-18 at 12:16 -0400, Oren Laadan wrote:
> My suggestions works for this two: we add a flag CR_CTX_DRYRUN; a task
> can ask to checkpoint itself, or another task, with CR_CTX_DRYRUN and
> the checkpoint code runs without actual effect. (If we don't want to
> expose the actual flag to userspace, then we simply use it in an
> implementation of a /proc/PID/checkpointable operation).

This mostly falls short answering the question "Where/when did I go
wrong?"  Personally, I think that is critical for getting good bug
reports out of normal Joes that might not really be interested in c/r
development itself.  It is like lockdep.  The guys/gals posting those
reports really don't know about kernel locking, but they are able to
improve it anyway.

-- Dave
