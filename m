From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC/PATCH 1/8]: CGroup Files: Add locking mode to cgroups
	control files
Date: Tue, 13 May 2008 20:59:52 -0500
Message-ID: <20080513205952.8ad44617.pj__44992.2461448752$1210730561$gmane$org@sgi.com>
References: <20080513063707.049448000@menage.corp.google.com>
	<20080513071522.133586000@menage.corp.google.com>
	<20080513130127.fcd46a41.akpm@linux-foundation.org>
	<6599ad830805131417m4f8cc2e6iac42c0fb089a8cb1@mail.gmail.com>
	<20080513143206.ef259829.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080513143206.ef259829.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew wrote:
> As Matt observed, this is just a poorly-named variable.

How about the following code for cgroup_file_write():


	char buf[64];		/* avoid kmalloc() in small cases */
	char *p;		/* buf[] or kmalloc'd buffer */

	...

	if (nbytes < sizeof(buf)) {
		p = buf;
	} else {
		p = kmalloc(nbytes + 1, GFP_KERNEL);
		if (p == NULL)
			return -ENOMEM;
	}


Possible advantages of above code:

  * Uses short names for local variables of limited scope.

  * Doesn't set p until needed, so as:
	1) to highlight the symmetry of its setting, to either buf[]
	   (small cases) or to a kmalloc'd buffer (large cases), and
	2) to avoid implying that p needs to be set in the intervening
	   "..." code above.

  * Comments variable declarations.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
