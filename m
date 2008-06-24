From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/8] CGroup Files: Add write_string cgroup control file
	method
Date: Tue, 24 Jun 2008 16:26:21 -0700
Message-ID: <6599ad830806241626q51933106v7de4a2445d3a45fe__24225.5250145265$1214350193$gmane$org@mail.gmail.com>
References: <20080620234358.182933000@menage.corp.google.com>
	<20080621000730.052131000@menage.corp.google.com>
	<20080624161923.449ecea4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080624161923.449ecea4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

On Tue, Jun 24, 2008 at 4:19 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>>       /*
>> +      * write_string() is passed a nul-terminated kernelspace
>> +      * buffer of maximum length determined by max_write_len.
>> +      * Returns 0 or -ve error code.
>> +      */
>> +     int (*write_string)(struct cgroup *cgrp, struct cftype *cft,
>> +                         const char *buffer);
>
> Everything seems to use size_t (or ssize_t?) except for the ->write_string
> return value.  Can any of this be improved?

What other things are you including as "everything"?

write_string() returns 0 on success or a -ve error code on failure -
it doesn't have the concept of writing some fraction of the passed
bytes.

The functions that deal in size_t/ssize_t (along with userspace
buffers, files and position pointers) are the glue that interfaces
with the filesystem layer. My aim (which is furthered by this patch
series) is to keep as much of that as possible in the cgroup layer
itself, and to reduce filesystem glue in the cgroup subsystems. The
raw file interface is still exposed by cgroups for those subsystems
that really need it, but it should be the exception rather than the
rule.

Paul
