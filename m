From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 2/4] pidns: Call pid_ns_prepare_proc
	from	create_pid_namespace
Date: Mon, 31 Jan 2011 15:21:16 +0100
Message-ID: <4D46C55C.1050200__34488.045416265$1296483734$gmane$org@free.fr>
References: <1296469525-30111-1-git-send-email-daniel.lezcano@free.fr>
	<1296469525-30111-3-git-send-email-daniel.lezcano@free.fr>
	<20110131132207.GA26995@redhat.com> <4D46BA25.8080201@free.fr>
	<20110131140257.GA28827@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110131140257.GA28827-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/31/2011 03:02 PM, Oleg Nesterov wrote:
> On 01/31, Daniel Lezcano wrote:
>> On 01/31/2011 02:22 PM, Oleg Nesterov wrote:
>>> On 01/31, Daniel Lezcano wrote:
>>>> @@ -96,6 +97,9 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
>>>>    	for (i = 1; i<   PIDMAP_ENTRIES; i++)
>>>>    		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
>>>>
>>>> +	if (pid_ns_prepare_proc(ns))
>>>> +		goto out_free_map;
>>>> +
>>>>    	return ns;
>>> This is not right, afaics. I already sent the similar patches, but
>>> they were ignored ;)
>>>
>>> Please see http://marc.info/?l=linux-kernel&m=127697484000334
>>>
>>> If pid_ns_prepare_proc() fails we shouldn't blindly return ENOMEM
>>> and, more importantly, we need put_pid_ns(parent_ns).
>> Oh, ok. Right. Thanks for the pointer.
>>
>> Are you ok if I replace the patch 2/4 with your patch ?
> My patch depends on 1/4, http://marc.info/?l=linux-kernel&m=127697468632667
>
> Your change looks very similar to 1/4 + 3/4. Just fix the problem
> in create_pid_namespace(), no need to replace.

Ok, will do.

Thanks Oleg.

   -- Daniel
