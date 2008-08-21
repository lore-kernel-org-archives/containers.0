From: Solofo.Ramangalahy-6ktuUTfB/bM@public.gmane.org
Subject: Re: [Bugme-new] [Bug 11381] New: default shmmax
Date: Thu, 21 Aug 2008 09:58:53 +0200
Message-ID: <18605.8253.81960.581255@frecb006361.adech.frec.bull.fr>
References: <bug-11381-10286@http.bugzilla.kernel.org/>
	<20080820120043.e6e7e436.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820120043.e6e7e436.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Pierre Peiffer <peifferp-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>, Solofo Ramangalahy <Solofo.Ramangalahy-6ktuUTfB/bM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Nadia.Derbey-6ktuUTfB/bM@public.gmane.org Derbey" <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, peter_e-hi6Y0CQ0nG0@public.gmane.org
List-Id: containers.vger.kernel.org

>>>>> On Wed, 20 Aug 2008 12:00:43 -0700, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> said:
    Andrew>I don't think anybody has even thought about the shmmax default in
    Andrew> years.

IIRC, Matt (explicit CC: added) did a review of IPC tunables and how
they are changed in the distributions.

    Andrew> It would be useful to get distro input on this.  Do they
    Andrew> override the kernel default at boot time?  If so, what do
    Andrew> they do?

OpenSuse (11.0 at least) has this:
-#define SHMMAX 0x2000000                /* max shared seg size (bytes) */
+#define SHMMAX ULONG_MAX                /* max shared seg size (bytes) */
