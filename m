From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH][RFC] fs/exec.c: provide the correct process pid to the
	pipe helper
Date: Thu, 16 Sep 2010 13:12:31 -0700
Message-ID: <m1zkvh4fdc.fsf__45812.9188548357$1284668091$gmane$org@fess.ebiederm.org>
References: <1284663599-3549-1-git-send-email-wad@chromium.org>
	<20100916193543.GA11016@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100916193543.GA11016-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Thu, 16 Sep 2010 21:35:43 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 09/16, Will Drewry wrote:
>>
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1467,6 +1467,13 @@ static int format_corename(char *corename, long signr)
>>  	char *const out_end = corename + CORENAME_MAX_SIZE;
>>  	int rc;
>>  	int pid_in_pattern = 0;
>> +	pid_t pid = task_tgid_vnr(current);
>> +
>> +	/* The pipe helper runs in the init namespace and should
>> +	 * receive the matching pid until that changes.
>> +	 */
>> +	if (ispipe)
>> +		pid = task_tgid_nr(current);
>
> Agreed, it doesn't make sense to pass the "local" pid to the init ns.

Yes, passing the local pid to the init pid namespace doesn't make a lot
of sense.  I have recently fixed unix domain sockets to avoid doing that
kind of silliness.

That said I don't think this is a complete fix.  We also potentially
have the same issue with the uts namespace and the user namespace.

I believe the core file holds all of this information relative to the
process that is dying, one elf note or other so we don't need to worry
about information loss.

As for how to implement this for the pid case can we simply grab the
namespace at the ispipe stage and use task_tgid_nr_ns.  Something like:
pid_ns = current->nsproxy->pid_ns;
if (is_pipe)
	pid_ns = &init_pid_ns;

....
	/* pid */
	case 'p':
		pid_in_pattern = 1;
		rc = snprintf(out_ptr, out_end - out_ptr,
			      "%d", task_tgid_pid_nr_ns(pid_ns, current));
		if (rc > out_end - out_ptr)
			goto out;
		out_ptr += rc;
		break;

Will you were saying something about complex namespacing (in particular
the network namespace giving you problems).  The network namespace has
no influence over pipes so how does that come into play?

I can imagine that it would be nice to have different core patterns
depending on where you are in the process tree, so a container can
do something different than the system outside of the container.  Are
you thinking along those lines, or are you imagining something else?

Eric
