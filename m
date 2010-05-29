From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC] user-cr: Routing information in userspace
Date: Sat, 29 May 2010 11:09:45 -0700
Message-ID: <87r5kua8ba.fsf@caffeine.danplanet.com>
References: <1274884956-21005-1-git-send-email-danms@us.ibm.com>
	<20100529031349.GA10541@nibiru.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100529031349.GA10541-q9I3ByPDOfiE+EvaaNYduQ@public.gmane.org> (Enrico Weigelt's message
	of "Sat\, 29 May 2010 05\:13\:50 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: weigelt-EU+a56NjgY8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

EW> I'd prefer the routing tables being available via sysfs
EW> (eg. /sys/net/ipv4/routes). Containers could live under their own
EW> subdirectory (eg. /sys/containers/<id>/).

Well, that's a bit of extra work.  IIRC, the multiple routing table
implementations converge at about the RTNL layer, making it rather
difficult to expose them via another interface.

Regardless, it wouldn't change this patch set but by a couple of
lines.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
