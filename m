From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns49
Date: Fri, 28 Sep 2007 11:14:27 -0600
Message-ID: <m1d4w2btl8.fsf@ebiederm.dsl.xmission.com>
References: <46FD1A3B.3060306@fr.ibm.com>
	<m1ir5uergf.fsf@ebiederm.dsl.xmission.com>
	<46FD1E9F.4000200@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FD1E9F.4000200-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Fri,
	28 Sep 2007 17:32:47 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> I think Denis and I we reached a complete patch posted a couple of hours
> ago. Finally I didn't put the exit method in the inet_timewait_sock.c file but I
> added it to the tcp.c file. There is a comment about that in the header of the
> patch.

Yes.  I saw that.  At first glance it looks good and next time I'm through
that part of the code I will add your patches to my tree.

My priority list of the moment is:
rtnetlink, pf_packet, and improving /proc so I don't confuse find.

I'm really trying to reach the point where at a bare bones level
people can play with the functionality that is merged into the
net-2.6.24 tree and therefore into 2.6.24.  That should make it
easier for more people to play with and test this code.

My ipv4 patches are at the very least going to require a reordering
and a careful review before I am satisfied with them.  They aren't
exactly wrong but I think things could be done in a more obvious
and deliberate manner.

Eric
