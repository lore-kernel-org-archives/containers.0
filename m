From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC/PATCH 6/8]: CGroup Files: Remove cpuset_common_file_write()
Date: Tue, 13 May 2008 14:27:24 -0700
Message-ID: <6599ad830805131427t6ea1fdf3g6772225bb781b0c5__36480.6337202483$1210714181$gmane$org@mail.gmail.com>
References: <20080513063707.049448000@menage.corp.google.com>
	<20080513071522.984545000@menage.corp.google.com>
	<20080513131134.8b1cefe2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080513131134.8b1cefe2.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

On Tue, May 13, 2008 at 1:11 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Mon, 12 May 2008 23:37:13 -0700
>  menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org wrote:
>
>  > @@ -1412,14 +1355,18 @@ static struct cftype files[] = {
>  >       {
>  >               .name = "cpus",
>  >               .read = cpuset_common_file_read,
>  > -             .write = cpuset_common_file_write,
>  > +             .write_string = update_cpumask,
>  > +             .max_write_len = (100U + 6 * NR_CPUS),
>
>  hm, magic handwavy surely-enough-for-anyone constants.

This is just a movement of the check previously in cpuset_common_file_write():

	/* Crude upper limit on largest legitimate cpulist user might write. */
	if (nbytes > 100U + 6 * max(NR_CPUS, MAX_NUMNODES))
		return -E2BIG;

I'll add more comments. But I think it's a reasonable limit - assuming
that you wastefully enumerate each cpu individually, separated by
commas, 6 * NR_CPUS is enough for 100K CPUs.

Paul
