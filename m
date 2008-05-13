From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC/PATCH 2/8]: CGroup Files: Add a cgroup write_string control
	file method
Date: Tue, 13 May 2008 14:01:01 -0700
Message-ID: <6599ad830805131401v29217cf7h71f712efde94d383__3131.23739692873$1210712801$gmane$org@mail.gmail.com>
References: <20080513063707.049448000@menage.corp.google.com>
	<20080513071522.301139000@menage.corp.google.com>
	<20080513130710.36bc65f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080513130710.36bc65f7.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 13, 2008 at 1:07 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>  >
>  > +     /* If non-zero, defines the maximum length of string that can
>  > +      * be passed to write_string; defaults to 64 */
>  > +     int max_write_len;
>
>  would size_t be a more appropriate type?
>

Probably overkill, but I guess it's technically more correct. Updated
for the next version of these patches.

>
>  s/) (/)(/ would be more conventional.
>

OK, I've updated this and the other extraneous spaces in a separate patch.

>
>  > +     /*
>  > +      * write_string() is passed a nul-terminated kernelspace
>  > +      * buffer of maximum length determined by max_write_len
>  > +      */
>  > +     int (*write_string) (struct cgroup *cgrp, struct cftype *cft,
>  > +                          char *buffer);
>
>  Should these return size_t?

No, it returns 0 or a -ve error code. I've added a comment to this effect.
>  >       char *buffer = static_buffer;
>  > -     ssize_t max_bytes = sizeof(static_buffer) - 1;
>  > +     ssize_t max_bytes =  cft->max_write_len ?: sizeof(static_buffer) - 1;
>
>  A blank line between end-of-locals and start-of-code is conventional
>  and, IMO, easier on the eye.
>
>  Does gcc actually generate better code with that x?:y thing?

I doubt it - but I felt that it made the code a bit clearer since it
reduces repetition. I can change it to

	size_t max_bytes =  cft->max_write_len;

	if (!max_bytes)
		max_bytes = sizeof(static_buffer) - 1;

Paul
