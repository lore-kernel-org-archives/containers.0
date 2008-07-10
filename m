From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 - Object creation
	with a specified id)
Date: Thu, 10 Jul 2008 12:06:34 -0700
Message-ID: <1215716794.9398.41.camel@nimitz>
References: <20080418054459.891481000@bull.net>
	<20080422193612.GA15835@martell.zuzino.mipt.ru>
	<1208890580.17117.14.camel@nimitz.home.sr71.net>
	<20080422210130.GA15937@martell.zuzino.mipt.ru>
	<1208904967.17117.51.camel@nimitz.home.sr71.net>
	<480ED9D5.1010906@parallels.com> <480FE037.2010302@cs.columbia.edu>
	<m1y74a7b4w.fsf@frodo.ebiederm.org> <1215709949.9398.15.camel@nimitz>
	<20080710173246.GA1857@us.ibm.com> <m163rd1sd5.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m163rd1sd5.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-07-10 at 11:55 -0700, Eric W. Biederman wrote:
> 
> > If we do checkpoint-as-a-coredump, then we need userspace to coordinate
> > a kernel-generated coredump with a user-generated (?) swapfile snapshot.
> > But I guess we figure that out later.
> 
> Well it is a matter of which VMAs you dump.  For things that are file backed
> you need to dump them.

Are we talking about the VMA itself, or the memory backing the VMA?

-- Dave
