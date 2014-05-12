From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Staring with 3.14 devices.allow can't be opened in read-write mode
Date: Mon, 12 May 2014 11:19:08 -0400
Message-ID: <20140512151908.GC1421__38052.5492052131$1399907967$gmane$org@htj.dyndns.org>
References: <CANaxB-xUm3rJ-Cbp72q-rQJO5mZe1qK6qXsQM=vh0U8upJ44+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANaxB-xUm3rJ-Cbp72q-rQJO5mZe1qK6qXsQM=vh0U8upJ44+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Wagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, May 12, 2014 at 03:10:12PM +0400, Andrey Wagin wrote:
> I found the "devices.allow" file can't be opened in read-write mode on
> the 3.14 kernel. I uses libcgroup, which opens devices.allow with
> O_RDWR. This works fine before 3.14 and fails one 3.14. This files has

Urgh... great.

> write-only permissions. I have tried to create a regular file with the
> same permission and kernel allows to open it with O_RDWR.
> So what do you think is it a problem, which must be fixed?

That's vfs skipping permission check because the opener is root.
sysfs traditionally enforced the same permission check on root too.
cgroup switched over to kernfs and now share the same open logic with
sysfs and is now getting open failure from permission check on root
opens too.

I'll bring kernfs's behavior closer to regular files.

Thanks.

-- 
tejun
