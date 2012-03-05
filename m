From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 05 Mar 2012 20:58:28 +0100
Message-ID: <1330977508.7391.7.camel@marge.simpson.net>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com> <20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins> <1330006399.11248.20.camel@twins>
	<4F4FAF89.3090706@redhat.com>
	<1330633603.7414.49.camel@marge.simpson.net>
	<20120301210213.GF13533@redhat.com>
	<1330639448.7414.97.camel@marge.simpson.net>
	<20120305124310.GD10929@tango.0pointer.de>
	<1330962421.7368.69.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1330962421.7368.69.camel-YqMYhexLQo31wTEvPJ5Q0F6hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2012-03-05 at 16:47 +0100, Mike Galbraith wrote: 
> On Mon, 2012-03-05 at 13:43 +0100, Lennart Poettering wrote: 

> > Just set DefaultControllers= in /etc/systemd/system.conf to an empty
> > string and systemd will not make use of any hierarchy beyond its private
> > name=systemd named hierarchy.
> 
> I updated my laptop to openSUSE 12.1 over the weekend, so tried it.  It
> didn't work

Bah, yes it did, subdir is gone.  I shouldn't multitask.

-Mike
