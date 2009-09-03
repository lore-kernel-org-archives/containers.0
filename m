From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them (v2)
Date: Thu, 03 Sep 2009 08:21:39 -0700
Message-ID: <87ws4gxddo.fsf@caffeine.danplanet.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
	<1251915760-20118-2-git-send-email-danms@us.ibm.com>
	<4A9F0E96.70106@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A9F0E96.70106-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Wed\,
	02 Sep 2009 20\:32\:22 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> As it is, it simplifies the code. However, how can we be certain
OL> that grafting a dead socket doesn't break any assumptions
OL> elsewhere ?  For instance, unix_sock_destructor() will spit a
OL> warning if it finds
sk-> sk_socket != NULL. There may be other places (per protocol ?).

I think that in most cases the grafted struct socket is short-lived
and therefore shouldn't be a problem with something like the
destructor.

I definitely prefer assuming we have an sk->sk_socket elsewhere and
will be happy to remove the other checks, unless there's a compelling
reason not to.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
