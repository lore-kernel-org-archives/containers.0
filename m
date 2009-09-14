From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Make sure we free the struct socket of SOCK_DEAD
	sockets
Date: Mon, 14 Sep 2009 12:31:02 -0700
Message-ID: <87iqfljpc9.fsf@caffeine.danplanet.com>
References: <1252946924-4401-1-git-send-email-danms@us.ibm.com>
	<1252946924-4401-4-git-send-email-danms@us.ibm.com>
	<4AAE94D7.6060802@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AAE94D7.6060802-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Mon\,
	14 Sep 2009 15\:09\:11 -0400")
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

OL> This works well for the case of successful restart, but I suspect it
OL> doesn't cover two other cases:

OL> 1) Malicious user removes the SOCK_DEAD marking off a socket.
OL> 2) Restart fails after a socket is restored but before it is
OL> attached to a process.

Aww, come on... when are users ever malicious? :)

Okay, I think I can handle both of these with a carefully-crafted
obj->ops->drop() replacement.  I don't want to get back to the
orphan-all-by-default situation because it becomes hard to ensure that
the socket object we later allocate receives proper treatment.

Thanks.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
