From: C Anthony Risinger <anthony-iwZaZ8Eb++w@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 13 Mar 2012 11:30:46 -0500
Message-ID: <CAGAVQTG_jUi3PffWQHc9jR6wA9gsEUXMMvb4LiimbpUZaxdGcw@mail.gmail.com>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com>
	<1331590938.18960.57.camel@twins> <20120312222817.GI23255@google.com>
	<1331591568.18960.61.camel@twins> <20120312223944.GJ23255@google.com>
	<1331592241.18960.64.camel@twins> <20120312230416.GM23255@google.com>
	<20120313141032.GD29169@redhat.com>
	<CAGAVQTGus7LUWV3AdhAFy--gr=uJRWtSGjuP69-EckBiXy0qVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGAVQTGus7LUWV3AdhAFy--gr=uJRWtSGjuP69-EckBiXy0qVg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 13, 2012 at 11:11 AM, C Anthony Risinger <anthony-iwZaZ8Eb++w@public.gmane.org> wrote:
>
> # what controllers are available for this process?
> $ cat /proc/self/tags/TYPE
^^^^^ should list of controllers either assigned to TYPE or not masked by MASK

> # explicit assign `users` 50 shares
> $ echo 50 > /proc/self/tags/admin.cpuacct.cpu.shares
                                               ^^^^^ s,admin,users,

> # `name`'s priority relative to sibling `name` groups (like shares)
> $ echo 100 > /proc/self/tags/admin.cpuacct.cpu.PRIORITY
^^^^^ maybe redundant, my original reasoning for it escapes me, but
could be useful for controllers that accept multiple `name`s

-- 

C Anthony
