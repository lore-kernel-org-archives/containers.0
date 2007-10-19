From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/3] [NETNS49] Add struct net to all calls for
	rt_cache_flush
Date: Fri, 19 Oct 2007 13:23:42 -0600
Message-ID: <m11wbqhps1.fsf@ebiederm.dsl.xmission.com>
References: <20071018100330.GA23415@iris.sw.ru> <471764A9.2080703@fr.ibm.com>
	<47177070.4000700@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47177070.4000700-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Thu, 18
	Oct 2007 18:40:48 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:


> I think that this is quite boring. It is impossible to get the namespace almost
> anywhere even when it is safe to use this :(

Well for sysctl is my intention to eventually have:
/proc/sys -> /proc/self/sys
/proc/<pid>/sys

So it doesn't depend on who you are so much as who you are doing the work
for.  Especially in the networking context.

The goal for filesystem interfaces to namespaces is that long term we
should not care who is accessing the file but rather which file is being
accessed.  This allows for monitoring and control applications outsides
the container.  Applications like the planetlab monitoring framework where
the monitoring applications runs in a low privilege container and can
still monitor the entire box.

I don't quite have the user interface side of the network namspace proc
and sysctl interfaces sorted out but I do have the internal interfaces
working in a way that supports this.

> extra2 is a bad place, as it has a conventional meaning for other kernel. For
> example it is used for quite a lot of sysctl-s anywhere.

extra1 and extra2 are defined to be whatever the user of that sysctl table
entry want them to be.  Frequently they are used for min/max behavior
but if your sysctl has another use for them that is fine.

Eric
