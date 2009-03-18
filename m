From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v3)
Date: Wed, 18 Mar 2009 06:30:36 -0700
Message-ID: <87d4cf556r.fsf@caffeine.danplanet.com>
References: <1237306139-23075-1-git-send-email-danms@us.ibm.com>
	<49C0BD63.7000309@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C0BD63.7000309-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed, 18 Mar 2009 05:22:43 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

OL> The length of ->nodename etc may change in the future. It's
OL> probably safer to also add the length of the field as well (see
OL> for instance how task->comm is saved).

Ah, good point.  I'll fix it up.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
